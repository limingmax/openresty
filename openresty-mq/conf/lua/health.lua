local function get_redis_conn()
	return redis:new({host=redis_host, port=redis_port, timeout=redis_timeout})
end



local function health()
	local redis_conn = get_redis_conn()
	local uri = string.sub(ngx.var.uri, 8, -1)
	local limit_key = 'LIMIT_AISVR_' .. uri
	local limit_num = redis_conn:get(limit_key)
	--ngx.log(ngx.ERR, "URI", uri);
	if not limit_num then
		return '{"status": "DOWN"}'
	else
		return '{"status": "UP"}'
	end

end


local status, info = pcall(health)
if status then
	ngx.say(info)
else
	ngx.say('{"code": 1, "msg": "' .. info .. '"}')
end


