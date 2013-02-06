server = require './server'
router = require './router'
request_handlers = require './request_handlers'
tag_handler = require './tag_handler'

handle = { }

handle["/"] = request_handlers.start
handle["/quotes"] = request_handlers.quotes
handle["/fetch"]  = request_handlers.fetch_stocks
handle["/tags_web_score"] = tag_handler.fetch_tags_web_score
handle["/single_tag_rank"] = tag_handler.single_tag_rank

server.start(router.route, handle)
