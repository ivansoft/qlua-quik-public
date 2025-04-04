message = message or print
-- local isRunningFromQuik = message ~= print
message("test_luaenv")

local dump = require("dump").extended
-- local inspect = require('inspect')
-- local dump = inspect

-- To avoid polluting the global space, either define all operations inside table or use local

local function getVersion()
	--[=[
	local version = 'Lua 5.0'
	--[[]=]
	local n = '8'; repeat n = n*n until n == n*n
	local t = {'Lua 5.1', nil,
		[-1/0] = 'Lua 5.2',
		[1/0]  = 'Lua 5.3',
		[2]    = 'LuaJIT'}
	local version = t[2] or t[#'\z'] or t[n/'-0'] or 'Lua 5.4'
	--]]
	return version
end

local function writeArgs(file)
	local i_min = 0
	if arg ~= nil then
		while arg[ i_min ] do i_min = i_min - 1 end
		i_min = i_min + 1   -- so that i_min is the lowest int index for which arg is not nil

		for i = i_min, #arg do
			file:write( string.format( "arg[%d] = %s\n", i, arg[ i ] ) )
		end
	else
		file:write("global 'arg' is nil")
	end

end

local function _listFunctions(object, owner, result, passed)
	passed = passed or {}       -- initial value
	for k,v in pairs(object) do
		if type(v) == 'function' then
			result[#result+1] = string.format("%s%s()", owner, k)
		elseif type(v) == 'table' and not passed[k] then
			passed[k] = true
			_listFunctions(v, k .. '.', result, passed)
		end
	end
	return result
end
local function listFunctions(object)
	local result = {}               -- string buffer
	_listFunctions(object, '', result);
	table.sort(result)
	return table.concat(result, '\n')
end

getWorkingFolder = getWorkingFolder or function() return io.popen("cd"):read('l') end

local filename = getScriptPath and "test_luaenv_quik.txt" or "test_luaenv_lua.txt"

function main( )
	local file = assert(io.open(getWorkingFolder() .. "\\Logs\\" .. filename, "w"))

	message(filename)

	file:write("_VERSION = " .. _VERSION .. "\n")
	file:write("getVersion() = " .. getVersion() .. "\n")
	writeArgs(file)
	file:write("\n")

	file:write("\n- - - -" .. "\n\n")
	file:write(listFunctions(_ENV))

	file:write("\n- - - -" .. "\n\n")
	_ENV["luaenv_str"] = ""
	_ENV["luaenv_tbl"] = {}
	_ENV["luaenv_int"] = 1
	_ENV["luaenv_bool"] = false
	_ENV.package.path = _ENV.package.path:gsub(getWorkingFolder(), "QUIK")
	_ENV.package.cpath = _ENV.package.cpath:gsub(getWorkingFolder(), "QUIK")
	file:write("_ENV = " .. dump(_ENV,'_ENV') .. "\n")

	file:close()
end

if not getScriptPath then
	main()
end
