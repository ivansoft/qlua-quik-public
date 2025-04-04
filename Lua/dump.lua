local function iif(expr, trueval, falseval) if (expr) then return trueval else return falseval end end

----------------------------------------------
--                 Helpers                  --
----------------------------------------------

local GROUP_NAMES_CORE = {"constants", "functions", "objects"}
local GROUP_NAMES_ALL = {"constants", "functions", "objects","specials"}
local GROUP_NAME_DEFAULT = "objects"
local GROUP_FILTERS = {
	["constants"] = function(v) return type(v) == 'number' or type(v) == 'string' or type(v) == 'boolean' end,
	["functions"] = function(v) return type(v) == 'function' end,
	["objects"] = nil, -- function(v) return type(v) == 'table' or type(v) == 'userdata' or type(v) == 'thread' or type(v) == 'nil' end,
}
local GROUP_SPECIALS = {
	function(obj,k,list) return (obj == _ENV or obj == package.loaded) and k == '_G', #list+1 end,
	function(obj,k,list) return obj == _ENV and k == 'package', 1 end,
	function(obj,k,list) return tostring(k):match("^luaenv"), iif(#list>0,#list,1) end,
}

local function groupby_keys(object)
	local groups = {}
	for _,v in ipairs(GROUP_NAMES_ALL) do groups[v] = {} end
	for k,v in pairs(object) do
		local found, pos = false, nil
		for _,filterfunc in ipairs(GROUP_SPECIALS) do
			if filterfunc then
				found, pos = filterfunc(object, k, groups["specials"])
				if found then
					table.insert(groups["specials"], pos, k)
					break
				end
			end
		end
		if not found then
			for name,filterfunc in pairs(GROUP_FILTERS) do
				if filterfunc then
					found = filterfunc(v)
					if found then
						table.insert(groups[name], k)
						break
					end
				end
			end
		end
		if not found then
			table.insert(groups[GROUP_NAME_DEFAULT], k)
		end
	end
	for _,k in ipairs(GROUP_NAMES_CORE) do table.sort(groups[k]) end
	return groups
end


local function dump(object, path, tab, space, crlf, indent, passed)
	local passed = passed or {}       -- initial value
	local tab = tab or '  '
	local space = space or ' '
	local crlf = crlf or '\n'
	local indent = indent or ''
	local path = path or 'root'
	if type(object) == 'table' then
		local fmtkeyval = function(fmtk, fmtv, key,value) return string.format(string.format("%s%s%s%s=%s%s", indent, tab, fmtk, space, space, fmtv), key, value) end
		local fmtfunc = function(fmtk, key) return string.format(string.format("%s%s%s", indent, tab, fmtk), key) end
		local groups = groupby_keys(object)
		local result = {}             -- string buffer
		result[#result + 1] = '{'     -- convention to start arrays with index 1
		for _,gname in ipairs(GROUP_NAMES_ALL) do
			for _,k in ipairs(groups[gname]) do
				local v = object[k]
				if object == package.loaded and k == '_G' then
					result[#result + 1] = fmtkeyval("[%q]","%s", k, "_ENV._G")
				elseif tostring(k):match("^luaenv") then
					passed[v] = path ..'.'.. k
					result[#result + 1] = fmtkeyval("[%s]","%s", k, dump(v, passed[v], tab, space, crlf, indent .. tab, passed))
				elseif type(v) == 'string' then
					result[#result + 1] = fmtkeyval("[%s]","%s", k, string.gsub(v,"\n","\\n"))
				elseif type(v) == 'number' or type(v) == 'boolean' then
					result[#result + 1] = fmtkeyval("[%s]","%s", k, v)
				else
					if passed[v] then
						result[#result + 1] = fmtkeyval("[%q]","%s", k, passed[v])
					else
						passed[v] = path ..'.'.. k
						if gname == "functions" then
							result[#result + 1] = fmtfunc("%s()", k)
						else
							result[#result + 1] = fmtkeyval("[%s]","%s", k, dump(v, passed[v], tab, space, crlf, indent .. tab, passed))
						end
					end
				end
			end
		end
		local mt = getmetatable(object)
		if mt then
			passed[mt] = path ..'.'.. "<metatable>"
			result[#result + 1] = fmtkeyval("%s","%s", "<metatable>", dump(mt, passed[mt], tab, space, crlf, indent .. tab, passed))
		end
		if #result == 1 then return '{}' end
		result[#result + 1] = indent .. '}'
		return table.concat(result, crlf)
	else
		local v = tostring(object)
		local mt = getmetatable(object)
		if mt then
			passed[mt] = path ..'.'.. "<metatable>"
			return string.format("%s,%s%s%s=%s%s", v, space, "<metatable>", space, space, dump(mt, passed[mt], tab, space, crlf, indent, passed))
		end
		return v
	end
end

-- TOOD: _ENV = {,[INTERVAL_D1]=1440, ...},}
--       remove commas, remove braces []
local function dump_compact(object, path)
	return dump(object, path, '', '', ',')
end

local function dump_extended(object, path)
	return dump(object, path, '   ')
end

----------------------------------------------

local function dump_old(object, passed)
	local passed = passed or {}       -- initial value
	if type(object) == 'table' then
		local il = #object > 0
		local result = {}             -- string buffer
		result[#result + 1] = iif(il,'{','[')     -- convention to start arrays with index 1
		for k,v in pairs(object) do
			if #result > 1 then result[#result + 1] = ',' end
			if passed[k] then         -- value already passed?
				result[#result + 1] = string.format("%s=%s", k, v)
			else
				passed[k] = true
				result[#result + 1] = string.format("%s=%s", k, dump_old(v, passed))
			end
		end
		if #result == 1 then return iif(il,'{}','[]') end
		result[#result + 1] = iif(il,'}',']')
		return table.concat(result)
	else
		return tostring(object)
	end
end

local function dump_compact_old(object, path)
	return dump_old(object)
end

----------------------------------------------

return {
	compact=dump_compact_old,
	extended=dump_extended,
}
