http = require 'http'
http.globalAgent.maxSockets = 50
request     = require 'request'
logger      = require './logger'
mysql       = require('./db').mysql
jsdom       = require 'jsdom'
env         = require './config/environment'


jsdom.defaultDocumentFeatures = 
  FetchExternalResources: false,
  ProcessExternalResources: false

validate_proxies = (response, query) ->
  request     = request.defaults {'proxy': "http://198.102.29.195:3128"}
  request.get "https://twitter.com", (error, res, body) ->
    if error 
      logger.error "[tag:fame:error] can't open twitter"
    else
      logger.info body 
  response.end()

exports.validate_proxies = validate_proxies
