// Generated by CoffeeScript 1.3.3
(function() {
  var route;

  route = function(handle, response, pathname, query) {
    if ((typeof handle[pathname]) === 'function') {
      return handle[pathname](response, query);
    } else {
      response.statusCode = 404;
      response.setHeader("Content-Type", "text/html");
      return response.end();
    }
  };

  exports.route = route;

}).call(this);
