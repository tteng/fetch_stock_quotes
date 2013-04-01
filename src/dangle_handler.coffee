http = require 'http'
http.globalAgent.maxSockets = 10
request     = require 'request'
logger      = require './logger'
mysql       = require('./db').mysql
env         = require './config/environment'
fs          = require 'fs'

verify_proxies = (response, query) ->
  get_total_count_sql = "select count(*) as count from http_proxies"
  mysql.query get_total_count_sql, null, (err, results) ->
    if err
      console.error "[mysql error] Count http_proxies failed for #{err}"
      return response.end()
    else
      total_count = results[0].count
      console.log "[mysql http_proxies_total_count] #{total_count}"
      [step, completed_count, proxy_count_per_request] = [0, 0, 1]
      if total_count > 0
        loop
          get_proxy_sql = "select id, ip, country, port from http_proxies limit #{proxy_count_per_request} offset #{step * proxy_count_per_request}"
          mysql.query get_proxy_sql, null, (error, rs) ->
            if error 
              console.log "[mysql error] Get http proxy to verify failed for #{error}"
            else
              if typeof rs[0] is "undefined"
                console.error "[mysql error] http proxies table is blank"
                console.log " direct return ... "
                return
              update_proxy_sql = "update http_proxies set available = ?, verified_at = now() where id = ?" 
              id = rs[0].id
              ip = rs[0].ip
              country = rs[0].country 
              port = rs[0].port
              console.log "ip: #{ip}:#{port}, country: #{country}"
              available = false # by default, a proxy is unavailable
              # SourceCountry = Hash.new(2)
              # SourceCountry["china"] = 0
              # SourceCountry["united states"] = 1
              url = "http://www.baidu.com"
              #customize cookie
              j = request.jar()
              cookie = request.cookie "#{Math.random()}myr@nd0mYUEWR#{Math.random()}" 
              j.add cookie
              request.get(
                {
                  uri: url,
                  proxy: "http://#{ip}:#{port}",
                  timeout: 30000000, #默认超时时间设置为30000秒 
                  headers: {"User-Agent": "Safari 10.2"},
                  jar: j
                },(error, res, body) ->
                     feasible = false
                     if error || typeof res is "undefined"
                       console.error "[proxy request error] #{error}"  if error
                       console.error "response undefined ..." if typeof res is "undefined"
                       mysql.query update_proxy_sql, [feasible, id], (err, results) ->
                                                                        console.log "[mysql error] update http_proxies##{id} available failed for #{err}" if err
                     else
                       console.log "[proxy statuscode] #{typeof res.statusCode} #{res.statusCode}"
                       if res.statusCode is 200  
                         reg_pat =  /zhidao\.baidu\.com/m
                         match = reg_pat.exec body
                         if match == null 
                           feasible = true
                         else
                           feasible = false
                         mysql.query update_proxy_sql, [feasible, id], (err, results) ->
              )
          #break # debug usage
          step++ 
          break if (step * proxy_count_per_request >= total_count)
  response.end()

dcn_download = (response, query) ->
  response.writeHeader 200, {"Content-Type": "text/html"}
  get_proxy_sql = "select id, ip, port from http_proxies where available = true order by id desc limit 1"
  mysql.query get_proxy_sql, null, (error, rs) ->
    console.log " ===================================== "
    if error 
      console.log "[mysql error] Get http proxy to verify failed for #{error}"
    else
      if typeof rs[0] is "undefined"
        response.write "no available proxy"
        return response.end()
      id = rs[0].id
      ip = rs[0].ip
      port = rs[0].port
      #url = "http://ng.d.cn/game/downs_654_1074_67221.html"
      options = 
        #host: "192.168.90.166",
        #port: 3000,
        #path: "/equips"
        host: "ng.d.cn",
        port: 80,
        path: "/game/downs_654_1074_67221.html"
        headers: 
          "User-Agent": "Mozilla/5.0 (Linux; U; Android 2.2; en-gb; GT-P1000 Build/FROYO) AppleWebKit/533.1 (KHTML, like Gecko) Version/4.0 Mobile Safari/533.1",
          "REMOTE_ADDR": "#{Math.floor(Math.random() * 252 + 1)}.#{Math.floor(Math.random() * 252 + 1)}.#{Math.floor(Math.random() * 252 + 1)}.#{Math.floor(Math.random() * 252 + 1)}"
          "X-Forwarded-For": "#{Math.floor(Math.random() * 252 + 1)}.#{Math.floor(Math.random() * 252 + 1)}.#{Math.floor(Math.random() * 252 + 1)}.#{Math.floor(Math.random() * 252 + 1)}"
      http.get(options, (res) ->
         console.log "status code: #{res.statusCode}"
         res.on 'end', (chunk) ->
           console.log 'response going to end'
           response.end()
      ).on 'error', (e) ->
       cosole.log "error: #{e}"
       response.end()

dcn_mad = (response, query) ->
  ary = [1..10000]
  for i in ary
    request.get 'http://localhost:8888/dcn_download', (err, res, body) ->
  response.end()
         
dcn_score = (response, query) ->
  ary = [1..2000]
  for i in ary
    options = 
      host: "ng.d.cn",
      port: 80,
      #path: "/game/downs_654_1074_67221.html"
      path: "/channel-asyc/?act=mark&id=654&score=10"
      headers: 
        "User-Agent": "Mozilla/5.0 (Linux; U; Android 2.2; en-gb; GT-P1000 Build/FROYO) AppleWebKit/533.1 (KHTML, like Gecko) Version/4.0 Mobile Safari/533.1",
        "REMOTE_ADDR": "#{Math.floor(Math.random() * 252 + 1)}.#{Math.floor(Math.random() * 252 + 1)}.#{Math.floor(Math.random() * 252 + 1)}.#{Math.floor(Math.random() * 252 + 1)}"
        "X-Forwarded-For": "#{Math.floor(Math.random() * 252 + 1)}.#{Math.floor(Math.random() * 252 + 1)}.#{Math.floor(Math.random() * 252 + 1)}.#{Math.floor(Math.random() * 252 + 1)}"
    http.get(options, (res) ->
       console.log "status code: #{res.statusCode}"
       res.on 'end', (chunk) ->
         console.log 'response going to end'
    ).on 'error', (e) ->
     cosole.log "error: #{e}"
  response.end() 


exports.verify_proxies = verify_proxies
exports.dcn_download = dcn_download
exports.dcn_mad = dcn_mad
exports.dcn_score = dcn_score
