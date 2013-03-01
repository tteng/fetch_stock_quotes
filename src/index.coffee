server              =  require './server'
router              =  require './router'
quotes_handler      =  require './quotes_handler'
weibo_tag_handler   =  require './weibo_tag_handler'
google_tag_handler  =  require './google_tag_handler'
proxy_handler       =  require './proxy_handler'

handle = { }

handle["/"]                             =     quotes_handler.start
# stock quotes
handle["/fetch_all_quotes"]             =     quotes_handler.fetch_all_quotes
handle["/fetch_single_quote"]           =     quotes_handler.fetch_single_quote

# weibo tag rank
handle["/tags_weibo_score"]             =     weibo_tag_handler.fetch_tags_weibo_score
handle["/single_tag_weibo_rank"]        =     weibo_tag_handler.single_tag_weibo_rank
handle["/calc_top_hundred_weibo_score"] =     weibo_tag_handler.calc_top_hundred_weibo_score

# google tag rank
handle["/tags_google_score"]             =     google_tag_handler.fetch_tags_google_score
handle["/single_tag_google_rank"]        =     google_tag_handler.single_tag_google_rank
handle["/calc_top_hundred_google_score"] =     google_tag_handler.calc_top_hundred_google_score


# proxies
handle["/verify_proxies"]               =     proxy_handler.verify_proxies
handle["/test_proxy"]                   =     proxy_handler.test_proxy

server.start(router.route, handle)

