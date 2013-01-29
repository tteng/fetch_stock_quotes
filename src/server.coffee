http = require 'http'
url  = require 'url'

start = (route, handle)->

  on_request = (request, response) ->
    pathname = url.parse(request.url).pathname
    console.log "Request for #{pathname} received."
    query_string = url.parse(request.url).query 
    #
    # parse设置为true时返回一个对象作为结果
    # query_string = url.parse(request.url, true).query 
    #
    console.log "Request for #{query_string} received."
    route handle, response, pathname, query_string

  http.createServer(on_request).listen 8888

exports.start = start
