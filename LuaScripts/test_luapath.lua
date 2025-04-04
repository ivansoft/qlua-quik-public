message = message or print
-- local isRunningFromQuik = message ~= print
message("test_luapath")

message(package.path)
-- QUIK\lua\?.lua
-- QUIK\lua\?\init.lua
-- QUIK\?.lua
-- QUIK\?\init.lua
-- QUIK\..\share\lua\5.3\?.lua
-- QUIK\..\share\lua\5.3\?\init.lua
-- .\?.lua
-- .\?\init.lua

message(package.cpath)
-- QUIK\?.dll
-- QUIK\..\lib\lua\5.3\?.dll
-- QUIK\loadall.dll
-- .\?.dll

-- функции getWorkingFolder и getScriptPath есть только в окружении квика

getWorkingFolder = getWorkingFolder or function() return io.popen("cd"):read('l') end

local filename = getScriptPath and "test_luapath_quik.txt" or "test_luapath_lua.txt"

function main()
	local file = assert(io.open(getWorkingFolder() .. "\\Logs\\" .. filename, "w"))

	-- message(filename)

	local wordir = getWorkingFolder()
	wordir = wordir:gsub(os.getenv("USERPROFILE"), "%%USERPROFILE%%")
	file:write(wordir .. "\n\n")

	local path = package.path
	path = path:gsub(getWorkingFolder(), "QUIK")
	file:write("package.path\n")
	file:write(path)
	file:write("\n\n")
	for line in path:gmatch("[^;]+;") do
		file:write(line)
		file:write("\n")
	end

	file:write("\n\n")

	local cpath = package.cpath
	cpath = cpath:gsub(getWorkingFolder(), "QUIK")
	file:write("package.cpath\n")
	file:write(cpath)
	file:write("\n\n")
	for line in cpath:gmatch("[^;]+;") do
		file:write(line)
		file:write("\n")
	end

	file:write("\n")

	file:close()
end

if not getScriptPath then
	main()
end
