-- load module
redis = require "resty.redis_iresty"
json = require "cjson.safe"

redis_host = REDIS_IP
redis_port = REDIS_PORT
redis_timeout = 180
get_task_timeout = 120
