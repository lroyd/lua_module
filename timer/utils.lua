sformat = string.format
tinsert = table.insert
tremove = table.remove
tconcat = table.concat
mfloor = math.floor
local _M = {}

function _M.bind(func, ...)
	local args = {...}
	return function(...)
		func(unpack(args), ...)
	end
end

function _M.dump(value, dep)
	dep = dep or ""
	local ret = ""
	if type(value) == "table" then
		ret = ret .. "{\n"
		for k, v in pairs(value) do
			ret = sformat("%s%s\t[%s] = %s\n", ret, dep, k, dump(v, dep .. "\t"))
		end
		ret = ret .. dep .. "},\n"
	else
		ret = ret .. tostring(value) .. ", "
	end
	return ret
end

function _M.clone(src)
	local ret = {}
	if type(src) == "table" then
		for k, v in pairs(src) do
			ret[k] = _M.clone(v)
		end
	else
		ret = src
	end
	return ret
end

function _M.tinsert_n(src, val, n)
	for i = 1, n do
		tinsert(src, _M.clone(val))
	end
end

function _M.ms2t(cycle)
	local s = mfloor(cycle / 1000)
	local m = mfloor(cycle / 60000)
	local h = mfloor(cycle / 3600000)
	local ms = cycle - h * 3600000 - m * 60000 - s * 1000
	return mfloor(h % 24), mfloor(m % 60), mfloor(s % 60), mfloor(ms % 1000)
end

function _M.t2ms(h, m, s, ms)
	return h * 3600000 + m * 60000 + s * 1000 + ms
end

return _M