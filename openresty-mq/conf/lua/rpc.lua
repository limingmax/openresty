local function get_redis_conn()
	return redis:new({host=redis_host, port=redis_port, timeout=redis_timeout})
end

local function check_task_num(redis_conn, uri)
	local key = 'AISVR_' .. uri
	local limit_key = 'LIMIT_AISVR_' .. uri
	local limit_num = redis_conn:get(limit_key)
	--ngx.log(ngx.ERR, "limit num", limit_num);
	if not limit_num then
		return false, 'not exist'
	end
	local limit_num = tonumber(limit_num)
	--ngx.log(ngx.ERR, "limit num", limit_num);

	local len, err = redis_conn:llen(key)
	if len > limit_num then
		return false, 'request more than limit'
	end
	return true, 'ok'
end


local function get_task_id(redis_conn, key)
	local incrid_key = 'INCRID_' .. key
	local id, err = redis_conn:incr(incrid_key)
	if not id then
		ngx.log(ngx.ERR, "failed to incr ", incrid_key, " err:", err);
		redis_conn:del(incrid_key)
		id, err = redis_conn:incr(incrid_key)
	end
	return 'TASK_' .. incrid_key .. '_' .. id
end


local function do_post()
	local uri = ngx.var.uri
	local key = 'AISVR_' .. uri
	local redis_conn = get_redis_conn()
	local flag, info = check_task_num(redis_conn, uri)
	if not flag then
		return '{"code": 1, "msg": "path:' .. uri .. ' ' .. info ..'"}'
	end

	local task_id = get_task_id(redis_conn, key)

	ngx.req.read_body()
	local task = {
		taskId = task_id,
		uri = uri,
		data = json.decode(ngx.req.get_body_data())
	}

	redis_conn:lpush(key, json.encode(task))
	local r = redis_conn:brpop(task_id, get_task_timeout)
	if not r then
		return '{"code": 1, "msg": "timeout"}'
	end
	return r[2]
end



local function do_get()
	local uri = ngx.var.uri
	local key = 'AISVR_' .. uri
	local redis_conn = get_redis_conn()
	local flag, info = check_task_num(redis_conn, uri)
	if not flag then
		return '{"code": 1, "msg": "path:' .. uri .. ' ' .. info ..'"}'
	end

	local task_id = get_task_id(redis_conn, key)

	local task = {
		taskId = task_id,
		uri = uri,
		data = ngx.req.get_uri_args()
	}

	redis_conn:lpush(key, json.encode(task))
	local r = redis_conn:brpop(task_id, get_task_timeout)
	if not r then
		return '{"code": 1, "msg": "timeout"}'
	end
	return r[2]
end



local function do_http()
	local request_method = ngx.var.request_method
	if request_method == 'POST' then
		return do_post()
	elseif request_method == 'GET' then
		return do_get()
	end
	return '{"code": 1, "msg": "request method not support"}'
end



local status, info = pcall(do_http)
if status then
	ngx.say(info)
else
	ngx.say('{"code": 1, "msg": "' .. info .. '"}')
end


