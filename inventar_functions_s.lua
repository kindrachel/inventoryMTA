local function isPlatzEmpty(player,tasche,platz)
	local id = getElementData(player,"Item_"..tasche,platz.."_id")
	if(id) then
		return false
	elseif(getElementData(player,"Inventar",tasche.."Platz") < platz) then
		return false
	else
		return true
	end
end

local function getLowEmptyPlace(player,tasche)
	for i = 0, getInventarPlaces(player,tasche),1 do
		if(isPlatzEmpty(player,tasche,i)) then
			return i
		end
	end
	return false
end

local function getLowestOccupiedPlace(player,tasche)
	local tasche = getElementData(player,"Item_"..tasche)
	for index,value in pairs(tasche) do
		if(value) then
			local place = getElementData(player,"Item",value.."_Platz")
			return place
		end
	end
	return false
end

function getInventarPlaces(player,tasche)
	return getElementData(player,"Inventar",tasche.."Platz") - 1
end

function getCountOfPlaces(player,tasche,item)
	local maxPlace = tonumber(getElementData(player,"Iteminfo",item.."_Item_Max"))
	local places = maxPlace
	for i = 0, getInventarPlaces(player,tasche),1 do
		local id = getElementData(player,"Item_"..tasche,i.."_id")
		if(getElementData(player,"Item",id) == item) then
			places = places - getElementData(player,"Item",id.."_Menge")
		elseif(not id) then
			--places = places + maxPlace
		end
	end
	return places
end

function getItemID(player,tasche,platz)
	return getElementData(player,"Item_"..tasche,platz.."_id")
end

function setItemPlace(player,tasche,oplatz,platz)
	local id = getItemID(player,tasche,oplatz)
	local nid= getItemID(player,tasche,platz)
	if(not id or (nid and getElementData(player,"Item",nid) ~= getElementData(player,"Item",id)) ) then
		return false
	end
	setData(player,"Item_"..tasche,oplatz.."_id",nil,true)
	setData(player,"Item",id.."_Platz",platz,true)
	setData(player,"Item_"..tasche,platz.."_id",id,true)
	
	local saved = mysql_query(Datenbank,"UPDATE `inventarinhalt` SET `Platz`='"..MySQL_Save( getElementData(player,"Item",id.."_Platz") ).."' WHERE `id`='"..MySQL_Save(id).."'")
	mysql_free_result(saved)
	return true
end

function c_setItemPlace(tasche,platz,nplatz) 
	if(source ~= client) then
		return false
	end
	setItemPlace(source,tasche,platz,nplatz)
end
addEvent("c_setItemPlace",true)
addEventHandler("c_setItemPlace",getRootElement(),c_setItemPlace)
function removeItem(player,tasche,platz,count)
	--if(antiSpam(player)) then
		--outputChatBox("Bitte warten ...",player)
	--	return 1
	--end
	local id = getElementData(player,"Item_"..tasche,platz.."_id")
	if(not id) then
		return false
	end
	
	if(not count) then
		count = getElementData(player,"Item",id.."_Menge")
	elseif(count < 0) then
		error("removeItem > You cant remove less then 0 items!",2)
		return false
	end
	local itemA = getElementData(player,"Item",id.."_Menge")
	if(tasche == "Waffen" and getElementData(player,"Item",id.."_Menge") - count == 0) then
		local weaponName = getRealItemName(getElementData(player,"Item",id))
		local wid = getWeaponIDFromName(weaponName)
		_takeWeapon(player,wid)
	end
	
	if(itemA - count < 0) then
		return false
	elseif(itemA - count > 0) then
		setData(player,"Item",id.."_Menge",itemA - count,true)
		local saved = mysql_query(Datenbank,"UPDATE `inventarinhalt` SET `Menge`='"..MySQL_Save( getElementData(player,"Item",id.."_Menge") ).."' WHERE `id`='"..MySQL_Save(id).."'")
		mysql_free_result(saved)
	else
		local saved = mysql_query(Datenbank,"DELETE FROM `inventarinhalt` WHERE `id`='"..MySQL_Save(id).."'")
		mysql_free_result(saved)
		setData(player,"Item",id,nil,true)
		setData(player,"Item",id.."_Menge",nil,true)
		setData(player,"Item",id.."_Platz",nil,true)
		setData(player,"Item_"..tasche,platz.."_id",nil,true)
	end
	

	
end

function giveItem(player,item,count,tasche,platz)
	if(not antiSpam(player,250)) then
		return false
	end
	local maxLen = getElementData(getRootElement(),"Item_Max",item)
	if(not item or type(item) ~= "string") then
		return error("giveItem > arg #2 not a string",2)
	elseif(not count or type(count) ~= "number") then
		return error("giveItem > arg #3 not a number",2)
	elseif(not tasche or type(tasche) ~= "string") then
		return error("giveItem > arg #4 not a string",2)
	elseif(not player or getElementType(player) ~= "player") then
		return error("giveItem > arg #1 not a player",2)
	end
	if(count <= 0 or count > getCountOfPlaces(player,tasche,item) ) then
		return false
	end
	if(platz) then
		local id = getElementData(player,"Item_"..tasche,platz.."_id")
		if(id and getElementData(player,"Item",id) == item) then
			if(count > maxLen) then
				local value = maxLen - getElementData(player,"Item",id.."_Menge")
				giveItem(player,item,value,tasche,platz)
				count = count - value
				while(count > maxLen) do
					giveItem(player,item,maxLen,tasche,platz)
					count = count - maxLen
					platz = getLowEmptyPlace(player,tasche)
				end
			elseif(count + getElementData(player,"Item",id.."_Menge") > maxLen and getElementData(player,"Item",id.."_Menge") ~= maxLen) then
				local full = maxLen - getElementData(player,"Item",id.."_Menge")
				local rest = count - full
				if(full > 0) then
					giveItem(player,item,full,tasche,platz)
				end
				if(rest > 0) then
					if(getLowEmptyPlace(player,tasche)) then
						giveItem(player,item,rest,tasche,getLowEmptyPlace(player,tasche))
					else
						return false
					end
				end
				return true
			elseif(getElementData(player,"Item",id.."_Menge") == maxLen) then
				for i = 0, getInventarPlaces(player,tasche),1 do
					local id = getElementData(player,"Item_"..tasche,i.."_id")
					if(id and getElementData(player,"Item",id) == item and getElementData(player,"Item",id.."_Menge") < maxLen) then
						local full = maxLen - getElementData(player,"Item",id.."_Menge")
						local rest = count - full
						if(full > 0) then
							giveItem(player,item,full,tasche,getElementData(player,"Item",id.."_Platz") )
						end
						if(rest > 0) then
							if(getLowEmptyPlace(player,tasche)) then
								giveItem(player,item,rest,tasche,getLowEmptyPlace(player,tasche))
							else
								return false
							end
						end
						return true
					end
				end
				platz = nil
			end	
		elseif(not id) then
			if(count > maxLen) then
				while(count > maxLen) do
					giveItem(player,item,maxLen,tasche,platz)
					count = count - maxLen
					if(platz + 1 <= getElementData(player,"Inventar",tasche.."Platz") and getElementData(player,"Item_"..tasche,tostring(platz+1).."_id") and getElementData(player,"Item",getElementData(player,"Item_"..tasche,tostring(platz+1).."_id")) == item) then
						platz = platz + 1
					else
						platz = getLowEmptyPlace(player,tasche)
					end
				end
			end
		end
	
	end
	if(not platz) then
		for i = 0, getInventarPlaces(player,tasche),1 do
			local id = getElementData(player,"Item_"..tasche,i.."_id")
			if(getElementData(player,"Item",id) == item and getElementData(player,"Item",id.."_Menge") < maxLen) then
				platz = getElementData(player,"Item",id.."_Platz")
				break
			end
		end
		if(platz) then
			local id = getElementData(player,"Item_"..tasche,platz.."_id")
			if(count > maxLen) then
				local value = maxLen - getElementData(player,"Item",id.."_Menge")
				giveItem(player,item,value,tasche,platz)
				count = count - value
				while(count > maxLen) do
					giveItem(player,item,maxLen,tasche,platz)
					count = count - maxLen
					platz = getLowEmptyPlace(player,tasche) 
				end
			elseif(getElementData(player,"Item",id.."_Menge") + count > maxLen and getElementData(player,"Item",id.."_Menge") ~= maxLen) then
				local full = maxLen - getElementData(player,"Item",id.."_Menge")
				local rest = count - full
				if(full > 0) then
					giveItem(player,item,full,tasche,platz)
				end
				if(rest > 0) then
					if(getLowEmptyPlace(player,tasche)) then
						giveItem(player,item,rest,tasche,getLowEmptyPlace(player,tasche))
					else
						return false
					end
				end
				return true
			elseif(getElementData(player,"Item",id.."_Menge") == maxLen) then
				for i = 0, getInventarPlaces(player,tasche),1 do
					local id = getElementData(player,"Item_"..tasche,i.."_id")
					if(getElementData(player,"Item",id) == item) then
						local full = maxLen - getElementData(player,"Item",id.."_Menge")
						local rest = count - full
						if(full > 0) then
							giveItem(player,item,full,tasche,getElementData(player,"Item",id.."_Platz"))
						end
						if(rest > 0) then
							if(getLowEmptyPlace(player,tasche)) then
								giveItem(player,item,rest,tasche,getLowEmptyPlace(player,tasche))
							else 
								return false
							end
						end
						return true
					end
				end
			end
		end
	end
	if(not platz) then
		if(count > maxLen) then
			while(count > maxLen) do
				giveItem(player,item,maxLen,tasche,platz)
				count = count - maxLen
			end
		end
		platz = getLowEmptyPlace(player,tasche) 
	end
	
	local id = getElementData(player,"Item_"..tasche,platz.."_id")
	if(id and getElementData(player,"Item",id) == item) then
		local itemA = getElementData(player,"Item",id.."_Menge")
		setData(player,"Item",id.."_Menge",itemA + count,true)
		local saved = mysql_query(Datenbank,"UPDATE `inventarinhalt` SET `Menge`='"..MySQL_Save( getElementData(player,"Item",id.."_Menge") ).."' WHERE `id`='"..MySQL_Save(id).."'")
		mysql_free_result(saved)
		triggerClientEvent(player,"setIKoords_c",player,platz,tasche)
		return true
	elseif(id and getElementData(player,"Item",id) ~= item) then 
		return false
	else
		local saved = mysql_query(Datenbank, "INSERT INTO `inventarinhalt` (Name,Menge,Objekt,Platz,Tasche) VALUES ('"..MySQL_Save(getPlayerName(player)).."','"..MySQL_Save(count).."','"..MySQL_Save(item).."','"..MySQL_Save(platz).."','"..MySQL_Save(tasche).."')")
		mysql_free_result(saved)
	end
	local result = mysql_query(Datenbank, "SELECT * FROM `inventarinhalt` WHERE `Tasche`='"..tasche.."' AND `Platz`='"..platz.."' AND `Objekt`='"..item.."'")
	if(mysql_num_rows(result) ~= 0) then
		for result,row in mysql_rows_assoc(result) do
			setData(player,"Item",tonumber(row["id"]),tostring(row["Objekt"]),true)
			setData(player,"Item",tonumber(row["id"]).."_Menge",tonumber(row["Menge"]),true)
			setData(player,"Item",tonumber(row["id"]).."_Platz",tonumber(row["Platz"]),true)
			setData(player,"Item_"..tostring(row["Tasche"]),tonumber(row["Platz"]).."_id",tonumber(row["id"]),true)
		end
		mysql_free_result(result)
	else
		outputDebugString("Die Daten konnten nicht aus der Tabelle 'inventarinhalt' ausgelesen werden!")
		mysql_free_result(result)
	end
	triggerClientEvent(player,"setIKoords_c",player,platz,tasche)
	return true
end


	
