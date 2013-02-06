http = require 'http'
http.globalAgent.maxSockets = 50
request     = require 'request'
sprintf     = require('sprintf').sprintf
logger      = require './logger'
mysql       = require('./db').mysql
options     = require('./weibo_request_properties').query_options
jsdom       = require 'jsdom'
date_utils  = require 'date-utils'
env         = require './config/environment'

jsdom.defaultDocumentFeatures = 
  FetchExternalResources: false,
  ProcessExternalResources: false

fetch_tags_web_score = (response, query) ->
  get_total_count_sql = "select count(*) as count from tags"
  total_count = 0
  mysql.query get_total_count_sql, null, (err, results) ->
    if err
      consloe.log "[mysql error] Count tags failed for #{err}"
      return response.end()
    else
      total_count = results[0].count
      console.log "[mysql tags_total_count] #{total_count} #{typeof total_count}"
      [step, completed_count, tag_count_per_request] = [0, 0, 1]
      loop 
        get_tag_sql = "select title from tags order by id limit #{tag_count_per_request} offset #{step * tag_count_per_request}"
        mysql.query get_tag_sql, null, (err, results) ->
          if err
            console.log "[mysql error] Query tag failed for #{err}"
          else
            http.get("http://localhost:8888/single_tag_rank?tag=#{results[0].title}",  (res) ->
              completed_count++
              logger.info "[completed_count]: #{completed_count}"
              update_all_tags_weibo_score() if completed_count >= total_count
            ).on 'error', (e) ->
                            console.log "[server error] batch fetch sinle tag rank failed caused by #{e}"
                            completed_count++
                            update_all_tags_weibo_score() if completed_count > total_count
      
        step++
        break if step * tag_count_per_request >= total_count
    
  console.log "Request handler start was called"
  response.writeHead  200, {"Content-Type": "text/plain"}
  response.write 'Going to fetch tag score one by one.'
  response.end()

update_all_tags_weibo_score = ->
  console.log "[tags:weibo:ranks] all tags' weibo rank updated" 
  hot_tags_count = env.WEIBO_HOT_TAGS_COUNT
  update_tags_score_sql = "update tags as a inner join 
                               (select l.id, @curRow := @curRow -1  as row_number from tags l join (select @curRow := #{hot_tags_count + 1}) r order by l.weibo_rank desc limit #{hot_tags_count}) as b
                               on a.id = b.id set a.weibo_score = b.row_number"
  mysql.query update_tags_score_sql, null, (err, results) ->
    if err
      console.log "[mysql error] update tags weibo score failed for #{err}"
    else
      console.log "tags weibo score updated"

single_tag_rank = (response, query) ->
  tag = query.split('=')[1]
  date = new Date()
  today = date.toFormat "YYYY-MM-DD"
  #logger.info "today: #{today}"
  
  yesterday = Date.yesterday().toFormat "YYYY-MM-DD"
  #logger.info "yesterday: #{yesterday}"

  dest_url = sprintf options.realtime_uri, tag, prefix=(if date.getHours() < 10 then yesterday else today), today
  #logger.info "--- going to query #{dest_url}"

  update_sql = "update tags set weibo_rank=?, updated_at=now() where title=?"

  request.get dest_url, (error, res, body) ->
    if error 
      logger.error "[tag:fame:error] can't open #{dest_url}"
    else
      jsdom.env {html: body}, (error, window) ->
                                if error 
                                  logger.error "[tag:fame:error] can't get #{tag} total count" 
                                else
                                  reg_pat =  /totalNum.*\s+((\d{1,},?)+\s)/m
                                  match = reg_pat.exec body
                                  unless match == null 
                                    score = match[1].replace(/,/,'')
                                    logger.info score
                                    mysql.query update_sql, [score, decodeURI(tag)], (err, results) ->
                                      if err
                                        consloe.log "[mysql error] update weibo rank failed for #{err}"
                                window.close()
      
  response.end()

exports.single_tag_rank = single_tag_rank
exports.fetch_tags_web_score = fetch_tags_web_score
