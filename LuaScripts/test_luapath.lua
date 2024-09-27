message = message or print
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

getWorkingFolder = getWorkingFolder or function() return "." end

local filename = getScriptPath and "test_luapath_quik.txt" or "test_luapath_interpreter.txt"

function main()
	local file = assert(io.open(getWorkingFolder() .. "\\Logs\\" .. filename, "w"))

	file:write(getWorkingFolder() .. "\n\n")

	file:write("package.path\n")
	file:write(package.path)
	file:write("\n\n")
	path = package.path
	path = path:gsub(getWorkingFolder(), "QUIK")
	for line in path:gmatch("[^;]+;") do
		file:write(line)
		file:write("\n")
	end

	file:write("\n\n")

	file:write("package.cpath\n")
	file:write(package.cpath)
	file:write("\n\n")
	path = package.cpath
	path = path:gsub(getWorkingFolder(), "QUIK")
	for line in path:gmatch("[^;]+;") do
		file:write(line)
		file:write("\n")
	end

	file:write("\n")

	file:close()
end

if not getScriptPath then
	main()
end
