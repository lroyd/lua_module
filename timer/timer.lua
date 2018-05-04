sformat = string.format
tinsert = table.insert
tremove = table.remove
tconcat = table.concat
mfloor = math.floor
local utils = require("utils")
local _M = {	_slots = nil, 
				_cycle = nil,	}

function _M.Init(self, cycle)
	if not self._slots then
		self._slots = {}
		self._slots[1] = {}
		self._slots[2] = {}
		self._slots[3] = {}
		self._slots[4] = {}
		utils.tinsert_n(self._slots[1], {}, 24)
		utils.tinsert_n(self._slots[2], {}, 60)
		utils.tinsert_n(self._slots[3], {}, 60)
		utils.tinsert_n(self._slots[4], {}, 1000)
	end
	if not self._cycle then
		self._cycle = cycle
	end
end

function _M.Update(self, cycle)
	local h1, m1, s1, ms1 = utils.ms2t(self._cycle)
	self._cycle = cycle
	local h2, m2, s2, ms2 = utils.ms2t(self._cycle)
	self:__UpdateT__(24, 1, h1, h2, utils.bind(self.__UpdateH__, self))
	self:__UpdateT__(60, 2, m1, m2, utils.bind(self.__UpdateM__, self))
	self:__UpdateT__(60, 3, s1, s2, utils.bind(self.__UpdateS__, self))
	self:__UpdateT__(1000, 4, ms1, ms2, utils.bind(self.__UpdateMS__, self))
end

function _M.AddTimer(self, delay, func)
	self:__Insert__(delay + 1, func)
end

function _M.__Insert__(self, delay, func)
	if 0 == delay then
		func()
	else
		local h1, m1, s1, ms1 = utils.ms2t(delay)
		local h2, m2, s2, ms2 = utils.ms2t(delay + self._cycle)
		local tick = {	func = func, 
						time = { h = h2, m = m2, s = s2, ms = ms2 } }
		if h1 ~= 0 then
			tinsert(self._slots[1][h2 == 0 and 24 or h2], tick)
		elseif m1 ~= 0 then
			tinsert(self._slots[2][m2 == 0 and 60 or m2], tick)
		elseif s1 ~= 0 then
			tinsert(self._slots[3][s2 == 0 and 60 or s2], tick)
		elseif ms1 ~= 0 then
			tinsert(self._slots[4][ms2 == 0 and 1000 or ms2], tick)
		end
	end
end

function _M.__UpdateT__(self, cycle, index, first, last, func)
	local slots = self._slots[index]
	while first ~= last do
		first = first + 1
		for i = 1, #slots[first] do
			func(slots[first][i])
		end
		slots[first] = {}
		first = first % cycle
	end
end

function _M.__UpdateH__(self, v)
	self:__Insert__(utils.t2ms(0, v.time.m, v.time.s, v.time.ms), v.func)
end

function _M.__UpdateM__(self, v)
	self:__Insert__(utils.t2ms(0, 0, v.time.s, v.time.ms), v.func)
end

function _M.__UpdateS__(self, v)
	self:__Insert__(utils.t2ms(0, 0, 0, v.time.ms), v.func)
end

function _M.__UpdateMS__(self, v)
	self:__Insert__(utils.t2ms(0, 0, 0, 0), v.func)
end

return _M