local cjson = require 'cjson'
local inspect = require 'inspect'

local tables = {
	['classes'] = "Classes",
	['securities'] = "Instruments",

	['trade_accounts'] = "Trading accounts",
	['client_codes'] = "Client codes",

	['orders'] = "Orders",
	['stop_orders'] = "Stop orders",
	['trades'] = "Trades",

	['depo_limits'] = "Positions in instruments",
	['account_balance'] = "Participant's positions on trading accounts",
	['account_positions'] = "Participant's cash positions",
	['money_limits'] = "Cash positions",
	['futures_client_holding'] = "Client account positions (Futures)",
	['futures_client_limits'] = "Client account limits",

	['firms'] = "Firms",
	['neg_deals'] = "Negotiated deal orders",
	['neg_trades'] = "Trades for execution",
	['neg_deal_reports'] = "Reports on trades for execution",
	['firm_holding'] = "Participant's positions in instruments",
	['ccp_holdings'] = "Asset commitments and claims",
	['rm_holdings'] = "Currency: commitments and demands",

	['all_trades'] = "Anonymous trades",
}

local function trace(fmt, ...) PrintDbgStr("QLua[items] " .. string.format(fmt, ...)) end
-- local mt = {
-- 	log = function(file, fmt, ...)
-- 		file:write( string.format(fmt, ...))
-- 	end
-- }
local dumpEx = require('dump').extended
--local dump = function(v) return inspect(v, {newline=' ',indent=''}) end
local dump = function(obj) return cjson.encode(obj) end

function main( ... )
	local timestamp = os.date('%Y%m%d%H%M%S')
	local file = assert(io.open(getWorkingFolder() .."\\Logs\\".. ("test_quikitems_%s.txt"):format(timestamp), "w"))
	-- trace("%s", inspect(file))
	-- trace("%s", inspect(debug.getmetatable(file)))
	-- local mt = debug.getmetatable(file)
	-- mt.__index.log = function(file, fmt, ...)
	-- 	file:write(string.format(fmt, ...))
	-- end
	-- trace("%s", inspect(debug.getmetatable(file)))
	local log = function(fmt, ...)
		file:write(string.format(fmt, ...))
		file:write("\n")
	end
	-- log("%s", "test2")

	local customcounts = {
		['classes']=999,
		['firms']=5,
		['trade_accounts']=999, ['client_codes']=999,
		['depo_limits']=10, ['money_limits']=50, ['futures_client_limits']=10,
		['orders']=999, ['stop_orders']=20, ['trades']=999,
	}

	local dumptables = function(tables)
		log(string.rep('-', 84))
		local maxlen = 0
		for _,table_name in ipairs(tables) do
			maxlen = math.max(table_name:len(), maxlen)
		end
		for _,table_name in ipairs(tables) do
			--local count = load('return ' .. tostring(params and params[table_name] or 5-1))
			--local count = params and params[table_name] or 5
			local count = customcounts[table_name] or 5
			--trace('%s %d %d  #%d', table_name, count, math.max(math.min(count,getNumberOf(table_name)),5), getNumberOf(table_name))
			for i=0,math.max(math.min(count-1,getNumberOf(table_name)-1),5-1) do
				log("%".. maxlen .. "s[%d] : %s", table_name, i, dump(getItem(table_name,i)))
			end
		end
	end

	dumptables({ 'classes','securities','firms' })
	dumptables({ 'trade_accounts','client_codes' })
	dumptables({ 'account_balance','account_positions','futures_client_holding' })
	dumptables({ 'depo_limits','money_limits','futures_client_limits' })
	dumptables({ 'orders','stop_orders','trades' })
	dumptables({ 'neg_deals','neg_trades','neg_deal_reports' })
	dumptables({ 'firm_holding','ccp_holdings','rm_holdings' })
	dumptables({ 'all_trades' })


	local futures = {}
	local futures_arr = {}
	local day = 24 * 60 * 60
	local nowdate = tonumber(os.date('%Y%m%d', os.time() + day))
	trace(os.date('%Y-%m-%d %H:%M:%S', os.time() + day))
	local filter = function(class_code, base_active_seccode, mat_date)
		return class_code == 'SPBFUT' and nowdate < mat_date -- and base_active_seccode == 'GAZR'
	end
	local filtered_ids = SearchItems('securities', 0, getNumberOf('securities')-1, filter, 'class_code,base_active_seccode,mat_date')
	log(string.rep('-', 84))
	do
		local min_mat_date = {}
		for _,id in ipairs(filtered_ids) do
			local tbl = getItem('securities',id)
			min_mat_date[tbl.base_active_seccode] = math.min(min_mat_date[tbl.base_active_seccode] or math.huge, tbl.mat_date)
		end
		trace(dump(min_mat_date))
		local count = 0
		for _,id in ipairs(filtered_ids) do
			local tbl = getItem('securities',id)
			if min_mat_date[tbl.base_active_seccode] == tbl.mat_date then
				futures[tbl.base_active_seccode] = tbl
				count = count + 1
				futures_arr[count] = tbl.base_active_seccode
			end
		end
		--futures_arr:sort()
		table.sort(futures_arr)
		local sortf = function(a, b)
			return a:upper() < b:upper()
		end
		table.sort(futures_arr, sortf)
		trace(dump(futures_arr))
	end
	--log(inspect(futures_arr))
	for k,v in pairs(futures) do
		log("%11s : %21s : %s", ("[%s]"):format(k), ("%7s %13s"):format(v.sec_code, v.name), dump(v))
	end


	log(string.rep('-', 84))
	do
		local filter = function(class_code, flags)
			return class_code == 'SPBFUT' and (bit.test(flags,0))
		end
		local filtered_ids = SearchItems('orders', 0, getNumberOf('orders')-1, filter, 'class_code,flags')
		if filtered_ids then
			for i,id in ipairs(filtered_ids) do
				--if i == 1 then
					local tbl = getItem('orders',id)
					log("orders[%d] : %s : %s", id, ("%s %s %s"):format(tbl.sec_code, tbl.qty, tbl.order_num), dump(tbl))
					log(dumpEx(tbl))
					--trace(dumpEx(tbl))
				--end
			end
		end
	end

	log(string.rep('-', 84))
	do
		--class_code == 'SPBFUT' --and (bit.test(flags,0)) -- or bit.test(flags,5) or bit.test(flags,15))
		--os.time() - os.time(order_date_time) <= 3600  -- created in last 30 days  -- class_code == 'SPBFUT' and
		--firmid ~= 'MC0003300000'
		--[[
			Важно!
			если поле, переданное в SearchItems отсутствует в структуре
			то все параметры смещаются !!!!
			такое поле не передается в filter-функцию
			и все параметры за таким полем смещяются влево
			пример - 'order_date_time' - ?? есть для stop-order фондовой секции, но отсутствует в срочной ??
			     вообще, есть
		]]
		local filter = function(class_code, flags)
			return class_code=='SPBFUT' and (bit.test(flags,0) or bit.test(flags,5) or bit.test(flags,15))
		end
		local filtered_ids = SearchItems('stop_orders', 0, getNumberOf('stop_orders')-1, filter, 'class_code,flags')
		if filtered_ids then
			for i,id in ipairs(filtered_ids) do
				--if i == 2 then
					local tbl = getItem('stop_orders',id)
					log("stop_orders[%d] : %s : %s", id, ("%s %s %s"):format(tbl.sec_code, tbl.qty, tbl.order_num), dump(tbl))
					log(dumpEx(tbl))
					--trace(dumpEx(tbl))
				--end
			end
		else
			trace("no stop orders")
		end
	end

	log(string.rep('-', 84))
	do
		local filter = function(class_code)
			return class_code == 'SPBFUT'
		end
		local filtered_ids = SearchItems('trades', 0, getNumberOf('trades')-1, filter, 'class_code')
		if filtered_ids then
			for i,id in ipairs(filtered_ids) do
				--if i == 1 then
					local tbl = getItem('trades',id)
					log("trades[%d] : %s : %s", id, ("%s %s"):format(tbl.sec_code, tbl.qty), dump(tbl))
					log(dumpEx(tbl))
					--trace(dumpEx(tbl))
				--end
			end
		end
	end

	file:close()
end