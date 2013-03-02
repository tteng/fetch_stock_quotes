http = require 'http'
http.globalAgent.maxSockets = 10
request     = require 'request'
logger      = require './logger'
mysql       = require('./db').mysql
env         = require './config/environment'
jsdom       = require 'jsdom'

jsdom.defaultDocumentFeatures = 
  FetchExternalResources: false,
  ProcessExternalResources: false

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
              chinese_hot_key = env.CHINESE_HOT_KEYS.sort(-> 0.5-Math.random())[4] #从配置文件的中文热门词里随机取一个出来
              console.log " hot key: #{chinese_hot_key}"
              url = switch country
                      when 1 then "http://www.google.com.au/search?q=#{chinese_hot_key}"  #hard-code, 用谷歌搜索一下随机词汇看能不能返回数据
                      else "http://s.weibo.com/weibo/#{chinese_hot_key}&xsort=time&Refer=STopic_box" #同理，用微博搜索
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
                         #feasible = true
                         jsdom.env {html: body}, (error, window) ->
                           if error 
                             feasible = false
                             console.log " ------ jsdomerror ----- #{error}"
                           else
                             reg_pat =  /veri_code/m
                             match = reg_pat.exec body
                             if match == null 
                               feasible = true
                             else
                               feasible = false
                           window.close()
                           mysql.query update_proxy_sql, [feasible, id], (err, results) ->
                                                                        console.log "[mysql error] update http_proxies##{id} available failed for #{err}" if err
              )
          #break # debug usage
          step++ 
          break if (step * proxy_count_per_request >= total_count)
  response.end()


test_proxy = (response, query) ->
  response.writeHeader 200, {"Content-Type": "text/html"}
  get_proxy_sql = "select id, ip, country, port from http_proxies where available = true order by speed limit 1"
  mysql.query get_proxy_sql, null, (error, rs) ->
    if error 
      console.log "[mysql error] Get http proxy to verify failed for #{error}"
    else
      if typeof rs[0] is "undefined"
        response.write "no available proxy"
        return response.end()
      id = rs[0].id
      ip = rs[0].ip
      country = rs[0].country 
      port = rs[0].port
      response.write "ip: #{ip}:#{port}, country: #{country} \n"
      # SourceCountry = Hash.new(2)
      # SourceCountry["china"] = 0
      # SourceCountry["united states"] = 1
      chinese_hot_key = env.CHINESE_HOT_KEYS.sort(-> 0.5-Math.random())[4] #从配置文件的中文热门词里随机取一个出来
      url = switch country
              when 1 then "http://www.google.com.au/search?q=#{chinese_hot_key}"  #hard-code, 用谷歌搜索一下随机词汇看能不能返回数据
              else "http://s.weibo.com/weibo/#{chinese_hot_key}&xsort=time&Refer=STopic_box" #同理，用微博搜索
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
             response.write "[proxy response error] #{error} \n" if error
             if typeof res is "undefined"
               response.write "response is undefined \n"
             else
               response.write "[proxy statuscode] #{typeof res.statusCode} #{res.statusCode} \n"
               if !error && res.statusCode is 200  
                 jsdom.env {html: body}, (error, window) ->
                          if error 
                            console.error "[proxy:error] can't get #{tag} total count" 
                          else
                            reg_pat =  /veri_code/m
                            match = reg_pat.exec body
                            if match == null 
                              response.write "可用\n"
                            else
                              response.write "不可用\n"
                          window.close()
                 response.write body
             response.end()
      )

exports.verify_proxies = verify_proxies
exports.test_proxy = test_proxy
