###
# 封装 Redis 连接进行封装
###

## Module dependencies
redis  = require "redis"
logger = require "./logger"
env    = require './config/environment'

## Private helpers
# 如果发生错误，提示错误信息，并自动重连
handleError = (error) -> logger.error "[redis_util:handleError] #{error}"

# 如果客户端中断的话，自动重连
handleEnd = -> logger.info "[redis_util:handleEnd]"

# 数据库连接正常
handleReady = ->
  isRedisReady = true
  logger.info "[redis_util:handleReady] Connected to Redis."

# 如果 TCP 连接阻塞，警告命令队列的长度
handleReconnecting = (info) ->
  logger.info "[redis_util:handleReconnecting] Reconnect to datastore... delay: #{info.delay}, attempt: #{info.attempt}"

handleAuth = (error) ->
  if error
    logger.error "[redis_util:handleAuth] #{error}"
  else
    logger.info "[redis_util:handleAuth] Connection authenticated."

## Exports
exports.createClient = ->
  client = redis.createClient env.redisPort, env.redisHost
  client.debug_mode = env.debug
  client.on "ready", handleReady
  client.on "error", handleError
  client.on "end", handleEnd
  client.on "reconnecting", handleReconnecting
  client.auth env.redisPassword, handleAuth if env.redisPassword
  client

