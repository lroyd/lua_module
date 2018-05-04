local utils = require("utils")
local Timer = require("timer")

local timer = utils.clone(Timer)

local loop = true
local ticks = 0

local function Loop()
	timer:Update(mfloor(os.clock() * 1000))
	return true
end




local locks = 0
local target_ticks = 0
local ticks = 0
local retry_cnt = 0
--[0解除/-1限制]超时检测
function check_timeout()
	ret = -1

	if locks == 1 then
		--检测时间
		ticks = os.time()
		if ticks >= target_ticks then
			--解除超时
			locks = 0
			retry_cnt = 0
			target_ticks = 0
			ret = 0
		end
	else
		if retry_cnt == 5 then
			--失败最大上限
			locks = 1
			target_ticks = os.time() + 10
			
		end	
		ret = 0
	end
	return ret	
end


function callback(i)
	--[[ticks = os.time()
	print(ticks)
	timer:AddTimer(1000, callback)
	--loop = false]]

	
	timer:AddTimer(1000, callback)	
	ret = check_timeout()
	if ret == -1 then
		--限制发送，直接失败
		print('locks')
		return 
	end	
	print('send!!!')
	retry_cnt = retry_cnt + 1
	print('retry_cnt:'..retry_cnt)
	check_timeout()

end

local function Main()
	timer:Init(os.clock() * 1000)

	timer:AddTimer(1000, callback)

	local last = os.clock()
	
	while loop do
		local time = os.clock()
		if time - last > 0.016 then
			last = time
			timer:Update(mfloor(os.clock() * 1000))
			--loop = Loop()
		end
	end
	print("wo cao")
end

Main()