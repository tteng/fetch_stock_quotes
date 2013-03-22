route = (handle, response, pathname, query) ->
  if (typeof handle[pathname]) == 'function'
    handle[pathname](response, query) 
  else  
    #console.log("No request handler found for " + pathname);
    #return "404 Not found";
    response.statusCode = 404
    response.setHeader "Content-Type", "text/html"
    response.end()

exports.route = route

