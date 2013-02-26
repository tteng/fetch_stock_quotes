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

  # 中文测试代理是否工作的热门关键词
  CHINESE_HOT_KEYS: ["同学", "李天一", "李双江", "小霸王", "逛街", "足球", "篮球", "彩票", "出租车", "今天", "相亲", "吃饭", "出门", "帅哥", "美女", "视频", "故事", "车", "房子", "儿子", "女儿", "工资", "国家", "报纸", "广播", "图片", "博客", "活动", "应用"]

module.exports = settings
#console.dir settings
