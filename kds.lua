is_run = true
id = 0
kds = 0

function OnInit(script_path)
    is_run = true
    id = AllocTable()
    AddColumn(id, 1, "Ñ÷¸ò", true, QTABLE_CACHED_STRING_TYPE, 18)
	AddColumn(id, 2, "ÊÄÑ", true, QTABLE_DOUBLE_TYPE, 10)
	AddColumn(id, 3, "Òðåáîâàíèå (äî ÊÄÑ = 0)", true, QTABLE_DOUBLE_TYPE, 30)
    CreateWindow(id)
    SetWindowCaption(id,"Ðàñ÷åò ÊÄÑ")
	SetWindowPos(id,600,50,360,500)

	for i = 0, getNumberOf("futures_client_limits") - 1 do
	   if getItem("futures_client_limits",i).limit_type == 0 then
	      InsertRow(id, -1)
	   end 
    end
end

function round(num, idp)
  local mult = 10^(idp or 0)
    if num >= 0 then
     	return math.floor(num * mult + 0.5) / mult
    else 
	    return math.ceil(num * mult - 0.5) / mult 
	end
end

function main()
j = 1
    while is_run do
            sleep(100)
			if IsWindowClosed(id) then is_run = false end
			for i = 0, getNumberOf("futures_client_limits") - 1 do
			    if getItem("futures_client_limits",i).limit_type == 0 then
				   fcl = getItem("futures_client_limits",i)
 				    if (fcl.cbplimit + fcl.accruedint) ~= 0 then
					    kds = round((fcl.cbplimit + fcl.accruedint + fcl.options_premium - fcl.cbplused_for_positions + fcl.varmargin)/math.abs(fcl.cbplimit + fcl.accruedint + fcl.options_premium),2)
                            if kds >= 0.00 and kds <= 0.20 then
								SetColor(id, j, 2, RGB(255, 255, 0) ,QTABLE_DEFAULT_COLOR, QTABLE_DEFAULT_COLOR, QTABLE_DEFAULT_COLOR)
							else 
							    if kds < 0.00 then
								SetColor(id, j, 2, RGB(255, 0, 0) ,QTABLE_DEFAULT_COLOR, QTABLE_DEFAULT_COLOR, QTABLE_DEFAULT_COLOR)
							else 
								SetColor(id, j, 2, RGB(0, 255, 0) ,QTABLE_DEFAULT_COLOR, QTABLE_DEFAULT_COLOR, QTABLE_DEFAULT_COLOR) 
								end
						    end 
								SetCell(id, j, 1, tostring(fcl.trdaccid),0)
								SetCell(id, j, 2, tostring(kds),kds)
							if kds < 0.00 then
								margin_zero = round(fcl.cbplused_for_positions - (fcl.cbplimit + fcl.accruedint + fcl.varmargin + fcl.options_premium),2)
								SetColor(id, j, 3, RGB(255, 0, 0) ,QTABLE_DEFAULT_COLOR, QTABLE_DEFAULT_COLOR, QTABLE_DEFAULT_COLOR)
								SetCell(id, j, 3, tostring(margin_zero), margin_zero)
							else
								margin = 0
								SetColor(id, j, 3, RGB(0, 255, 0) ,QTABLE_DEFAULT_COLOR, QTABLE_DEFAULT_COLOR, QTABLE_DEFAULT_COLOR)
								SetCell(id, j, 3, tostring(margin), margin)
							end 
					else 
					    kds = 1
						SetColor(id, j, 2, RGB(0, 255, 0) ,QTABLE_DEFAULT_COLOR, QTABLE_DEFAULT_COLOR, QTABLE_DEFAULT_COLOR)
					    SetCell(id, j, 1, tostring(fcl.trdaccid),0)
			            SetCell(id, j, 2, tostring(kds),kds)
			        end 
				  j = j + 1
                end
			end
        j = 1
    end
end

function OnStop(stop_flag)
	DestroyTable(id)
	is_run = false
end
