// Generated by CoffeeScript 1.3.3
(function() {
  var calc_top_hundred_score, date_utils, env, fetch_tags_cn21_score, http, jsdom, logger, mysql, options, request, single_tag_cn21_rank, sprintf, update_all_tags_cn21_score;

  http = require('http');

  http.globalAgent.maxSockets = 10;

  request = require('request');

  sprintf = require('sprintf').sprintf;

  logger = require('./logger');

  mysql = require('./db').mysql;

  options = require('./cn21_request_properties').query_options;

  jsdom = require('jsdom');

  date_utils = require('date-utils');

  env = require('./config/environment');

  jsdom.defaultDocumentFeatures = {
    FetchExternalResources: false,
    ProcessExternalResources: false
  };

  fetch_tags_cn21_score = function(response, query) {
    var get_tags_total_count_sql, proxies_total_count, tags_total_count, _ref;
    get_tags_total_count_sql = "select count(*) as count from tags";
    _ref = [0, 0], tags_total_count = _ref[0], proxies_total_count = _ref[1];
    mysql.query(get_tags_total_count_sql, null, function(err, results) {
      var completed_count, get_proxies_total_count_sql, step_idx, tag_count_per_request, _ref1;
      if (err) {
        consloe.log("[mysql error] Count tags failed for " + err);
        return response.end();
      } else {
        tags_total_count = results[0].count;
        console.log("[mysql tags_tags_total_count] " + tags_total_count + " " + (typeof tags_total_count));
        _ref1 = [0, 0, 1], step_idx = _ref1[0], completed_count = _ref1[1], tag_count_per_request = _ref1[2];
        get_proxies_total_count_sql = "select count(*) as count from http_proxies where available=true";
        return mysql.query(get_proxies_total_count_sql, null, function(err, results) {
          var get_tag_sql, step, _i, _ref2, _results;
          if (err) {
            return consloe.log("[mysql error] Count proxies failed for " + err);
          } else {
            proxies_total_count = results[0].count;
            console.log("[proxies_total_count]: " + proxies_total_count);
            if (proxies_total_count > 0) {
              _results = [];
              for (step = _i = 0, _ref2 = tags_total_count - 1; 0 <= _ref2 ? _i <= _ref2 : _i >= _ref2; step = 0 <= _ref2 ? ++_i : --_i) {
                get_tag_sql = "select name from tags order by id limit " + tag_count_per_request + " offset " + (step * tag_count_per_request);
                _results.push(mysql.query(get_tag_sql, null, function(err, tag_results) {
                  var get_proxy_sql;
                  if (err) {
                    return console.log("[mysql error] Query tag failed for " + err);
                  } else {
                    get_proxy_sql = "select ip, port from http_proxies where available = true limit " + tag_count_per_request + " offset " + (step_idx * tag_count_per_request % proxies_total_count);
                    mysql.query(get_proxy_sql, null, function(err, results) {
                      var proxy_ip, proxy_port;
                      if (err) {
                        return console.error("[mysql_error:fetch_tags_cn21_score] can't find available proxy by " + err);
                      } else {
                        proxy_ip = results[0].ip;
                        proxy_port = results[0].port;
                        console.info("[proxy_str]: " + proxy_ip + ":" + proxy_port);
                        return request.get({
                          uri: "http://localhost:8888/single_tag_cn21_rank?tag=" + tag_results[0].name + "&proxy=" + proxy_ip + "&port=" + proxy_port,
                          timeout: 30000000
                        }, function(error, res, body) {
                          completed_count++;
                          logger.info("[completed_count]: " + completed_count);
                          if (completed_count >= tags_total_count) {
                            return update_all_tags_cn21_score();
                          }
                        });
                      }
                    });
                    return step_idx++;
                  }
                }));
              }
              return _results;
            }
          }
        });
      }
    });
    console.log("Request handler start was called");
    response.writeHead(200, {
      "Content-Type": "text/plain"
    });
    response.write('Going to fetch tag score one by one.');
    return response.end();
  };

  update_all_tags_cn21_score = function() {
    var update_tags_score_sql;
    console.log("[tags:cn21:ranks] all tags' cn21 rank updated");
    update_tags_score_sql = "call prcd_update_tags_cn21_score();";
    return mysql.query(update_tags_score_sql, null, function(err, results) {
      if (err) {
        return console.log("[mysql error] update tags cn21 score failed for " + err);
      } else {
        return console.log("tags cn21 score updated");
      }
    });
  };

  single_tag_cn21_rank = function(response, query) {
    var dest_url, k, query_option, str, tag, update_sql, v, _i, _len, _ref, _ref1;
    query_option = {};
    _ref = query.split('&');
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      str = _ref[_i];
      _ref1 = str.split('='), k = _ref1[0], v = _ref1[1];
      query_option[k] = v;
    }
    tag = query_option.tag;
    console.info(decodeURI(tag));
    dest_url = sprintf(options.default_uri, tag);
    logger.info("--- going to query " + dest_url);
    update_sql = "update tags set cn21_rank=?, updated_at=now() where name=?";
    return request.post({
      uri: dest_url,
      timeout: 30000000,
      headers: {
        "User-Agent": "Safari 10.2"
      },
      form: {
        "query": decodeURI(tag)
      }
    }, function(error, res, body) {
      if (error) {
        logger.error("[tag:fame:error] can't open " + dest_url + " with " + query_option.proxy + ":" + query_option.port);
        return response.end();
      } else {
        return jsdom.env({
          html: body
        }, function(error, window) {
          var match, reg_pat, score;
          if (error) {
            logger.error("[tag:fame:error] can't get " + (decodeURI(tag)) + " total count");
            return response.end();
          } else {
            reg_pat = /去重后，共\D*(\d+)\D*条信息/m;
            match = reg_pat.exec(body);
            if (match !== null) {
              score = match[1].replace(/,/, '');
              logger.info(score);
              return mysql.query(update_sql, [score, decodeURI(tag)], function(err, results) {
                if (err) {
                  consloe.log("[mysql error] update cn21 rank failed for " + err);
                }
                window.close();
                return response.end();
              });
            } else {
              logger.info("tag " + tag + " total_num_not_found");
              window.close();
              return response.end();
            }
          }
        });
      }
    });
  };

  calc_top_hundred_score = function(response, query) {
    update_all_tags_cn21_score();
    response.write("all tags cn21 score will be updated");
    return response.end();
  };

  exports.single_tag_cn21_rank = single_tag_cn21_rank;

  exports.fetch_tags_cn21_score = fetch_tags_cn21_score;

  exports.calc_top_hundred_cn21_score = calc_top_hundred_score;

}).call(this);
