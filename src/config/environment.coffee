path = require "path"
# 设置表
settings =

  LOG_PATH: path.join(__dirname, "logs/stock_quotes.log")

  DEBUG: true

  # MySQL 数据库地址
  MYSQL_HOST: "127.0.0.1"

  # MySQL 数据库端口
  MYSQL_PORT: 3306

  # MySQL 的 SOCK
  # MYSQL_SOCK: "/var/run/mysqld/mysqld.sock"

  # MySQL 数据库的用户名
  MYSQL_USERNAME: "root"

  # MySQL 数据库的用户密码
  MYSQL_PASSWORD: "root"

  # MySQL 数据库的名字
  MYSQL_DATABASE: "sns_demo_development"

  # Memcached 地址
  MEMCACHED_HOST: "127.0.0.1"

  # Memcached 端口
  MEMCACHED_PORT: 11211

  # Memcached Namespace, 需与rails memcache namespace设置为相同
  # Sample:
  #   config/environments/production.rb: config.cache_store = :mem_cache_store, "localhost:11211", {:namespace => "sns_demo"}
  MEMCACHED_NAMESPACE: 'sns_demo'
  
  # 股票价格过期时间,毫秒
  STOCK_PRICE_EXPIRES: 600000  #10分钟

  # 微博热门tag数，最热的tag将得到这个数字对应的分数，最低的是1分
  WEIBO_HOT_TAGS_COUNT: 100

  # 用来找代理服务器的代理跳板
  PROXY_START_POINT: "http://200.146.34.44:3128"

module.exports = settings
#console.dir settings
