env         = require './config/environment'
redis       = require('./redis_util').createClient()
date_utils  = require 'date-utils'

tracking = (response, query) ->
  response.writeHeader 200, {"Content-Type": "text/html"}
  query_str = decodeURIComponent(query).split(/^request_url=/)[1]
  query_reg = /([^?]+)\?query=(.*)&user_id=(.*)$/
  console.log "query is #{query}"
  match = query_reg.exec query_str
  unless match == null
    path = match[1]
    params = match[2]
    user_id = match[3]

    console.log "origin path: #{path}"
    console.log "origin params: #{params}"
    console.log "origin user_id: #{user_id}"

    unless path == null
      unless params == null
        decoded_params = {}
        decodeURIComponent(params).split('&').forEach (line) -> 
          [k, v] = line.split '='
          if k && v
            decoded_params[k] = v           
       
        unless decoded_params["page"] == undefined
          path += "?page=#{decoded_params["page"]}"
    
      date = new Date() 
      today = date.toFormat "YYYY-MM-DD"
      url_key = "#{env.redisNamespace}:url:#{today}"

      console.log "path: #{path}"
      console.log "url_key: #{url_key}"

      redis.zincrby url_key, 1, path, (err, response) ->
        console.log "[redis error]: #{err}"

      if user_id
        user_key = "#{env.redisNamespace}:u#{user_id}:#{today}"
        console.log "user_key: #{user_key}"
        redis.zincrby user_key, 1, path, (err, response) ->
          console.log "[redis error]: #{err}"

  response.end()

exports.tracking = tracking
