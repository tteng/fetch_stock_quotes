server = require './server'
router = require './router'
request_handlers = require './request_handlers'

handle = { }

handle["/"] = request_handlers.start
handle["/quotes"] = request_handlers.quotes
handle["/fetch"]  = request_handlers.fetch_stocks

server.start(router.route, handle)
