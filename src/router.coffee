route = (handle, response, pathname, query) ->
  if (typeof handle[pathname]) == 'function'
    handle[pathname](response, query) 
  else  
    console.log("No request handler found for " + pathname);
    return "404 Not found";

exports.route = route

