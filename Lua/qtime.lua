-- https://quikluacsharp.ru/qlua-osnovy/data-vremya-v-qlua-lua/
local function parseTime(str)
	local time = {}
	time.hour, time.min, time.sec = string.match(str,"(%d?%d)(%d%d)(%d%d)")
	return time.hour * 3600 + time.min * 60 + time.sec
end

local function extractTime(time)
	return time.hour * 3600 + time.min * 60 + time.sec
end


-- {year, month, day, week_day, hour, min, sec, ms, count}
local function formatTime(fmt, struct)
	-- pcall(os.time, nil) will return current time
	if not struct then
		return nil, "nil"
	end
	-- os.time
	-- must have fields -- year, month, and day
	-- may have fields -- hour (default is 12), min (default is 0), sec (default is 0),
	--                    isdst (default is nil)
	-- other fields are ignored
	local succeed, result = pcall(os.time, struct)  -- can be 1601 year
	if succeed then
		local epoch = result
		return os.date(fmt, epoch)
	end
	local error = result
	return nil, error
end

return {
	format = formatTime,
}