{Pool} = require 'generic-pool'
mysql = require 'mysql'
env = require './config/environment'
logger = require './logger'

## MySQL 数据库连接
# Create a MySQL connection pool with
# a max of 10 connections, a min of 2, and a 30 second max idle time
pool = Pool
  name: 'mysql',
  create: (callback) ->
    #console.log env
    c = mysql.createConnection
      host: env.MYSQL_HOST
      port: env.MYSQL_PORT
      user: env.MYSQL_USERNAME
      password: env.MYSQL_PASSWORD
      database: env.MYSQL_DATABASE
      #insecureAuth: true if env.MYSQL_INSECUREAUTH
      # debug: env.DEBUG
    c.connect (error) ->
      if not error
        logger.info "[db:mysql:connectToMySQL] MySQL client is ready."
      callback null, c
    c.on 'error', (error) ->
      return logger.error "[db.connectToMySQL] Error: #{error}" if !error.fatal
      # throw error if error.code != "PROTOCOL_CONNECTION_LOST"
      logger.error "[db.connectToMySQL] Fatal: #{error}. Destroy this MySQL client..."
      pool.destroy c

  destroy: (client) ->
    client.removeAllListeners()
    client.end()

  max: 5
  # FIXME
  # Cause a memory leak warning when running mocha tests
  # min: 2
  # specifies how long a resource can stay idle in pool before being removed
  idleTimeoutMillis: 5 * 60 * 1000  # Five minutes
  # frequency to check for idle resources (default 1000)
  reapIntervalMillis: 5 * 1000 # Five seconds
   # if true, logs via console.log - can also be a function
  log: false # env.DEBUG and logger.log

_mysql =
  # A proxy function to query database
  query: (sql, values, callback) ->
    now = Date.now()
    options = {}
    if typeof sql == "object"
      # query options, callback
      options = sql
      callback = values
      values = options.values
      delete options.values
    else if typeof values == "function"
      # query sql, callback
      callback = values
      options.sql = sql
      values = undefined
    else
      # query sql, values, callback
      options.sql = sql
      options.values = values

    pool.acquire (error, client) ->
      if error
        logger.error "[db.pool.acquire] Failed to acquire MySQL client. #{error}"
        callback error if callback
        return
      query = client.query options, wrapQueryCallback(callback, client)
      query._timestamp = now # if env.DEBUG

# 返回一个回调函数，在 Query 执行完成之后，释放客户端连接
wrapQueryCallback = (callback, client) ->
  ->
    logger.info "#{@sql} (spent: #{(Date.now() - @_timestamp)}ms)" if @_timestamp?
    pool.release client
    try
      callback arguments... if callback
    catch error
      logger.error "[db:wrapQueryCallback] Error: #{error.stack}"

exports.mysql = _mysql
