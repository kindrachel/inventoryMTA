a = "ä"
o = "ö"
u = "ü"
s = "ß"
A = "Ä"
O = "Ö"
U = "Ü"


function refreshString(string)
	local nstring,w = string.gsub(string,"Ü","Ue")
	local nstring,w = string.gsub(nstring,"Ö","Oe")
	local nstring,w = string.gsub(nstring,"Ä","Ae")
	local nstring,w = string.gsub(nstring,"ü","ue")
	local nstring,w = string.gsub(nstring,"ö","oe")
	local nstring,w = string.gsub(nstring,"ä","ae")
	local nstring,w = string.gsub(nstring,"ß","sz")
	return nstring
end


function refreshStringManuel(string)
	local nstring,w = string.gsub(string,"Ue",""..U.."")
	local nstring,w = string.gsub(nstring,"Oe",""..O.."")
	local nstring,w = string.gsub(nstring,"Ae",""..A.."")
	local nstring,w = string.gsub(nstring,"ue",""..u.."")
	local nstring,w = string.gsub(nstring,"oe",""..o.."")
	local nstring,w = string.gsub(nstring,"ae",""..a.."")
	local nstring,w = string.gsub(nstring,"*sz",""..s.."")
	return nstring
end


function giveMoney(player,amount)
	local int = tonumber(amount)
	local money = math.floor(int)
	if(getElementType(player) ~= "player") then
		return false
	end
	if(money == 0 or int == nil) then
		return false
	end
	
	if(money < 0) then
		playSoundFrontEnd ( player, 10 )
		setData(player,"UnL","GeldH",getMoney(player) - math.abs( money ))
		givePlayerMoney ( player, money )
	elseif(money > 0) then
		playSoundFrontEnd ( player, 10 )
		setData(player,"UnL","GeldH",getMoney(player) + money)
		givePlayerMoney ( player, money )
	end
	local saved = mysql_query(Datenbank,"UPDATE `benutzertabelle` SET `GeldH`='"..MySQL_Save ( tostring(getElementData(player,"UnL","GeldH")) ).."' WHERE `Benutzername`='"..MySQL_Save ( getPlayerName(player) ).."'")
	mysql_free_result ( saved )
	return true
end

function getMoney(player)
	if(getElementType ( player ) ~= "player") then
		return false
	end
	return tonumber(getElementData(player,"UnL","GeldH"))
end

function md5it (player,command, theString) -- open function
  if theString then -- check if the string is exist
    md5string = md5(theString) -- get the md5 string
    outputChatBox(theString.. " -> " .. md5string , player, 255, 0, 0, false) -- output it
  end
end
addCommandHandler ("md5it", md5it)

function MySQL_Save ( strings )
	if(not strings) then
		return error("MySQL_Save > no argument",2)
	end
	return mysql_escape_string ( Datenbank, tostring(strings) )
end

function setGK(player, amount)
	if(getElementType(player) ~= "player") then
		return error("setGK > arg #1 not a player",2)
	end
	local int = tonumber(amount)
	if(int == nil) then
		return false
	end
	local money = math.floor(int)
	--setElementData(player,"Bank"["GeldGK"],money,false)
	setData(player,"Bank","GeldGK",money,true)
	local saved = mysql_query(Datenbank,"UPDATE `bankkonten` SET `GeldGK`='"..MySQL_Save ( tostring(getElementData(player,"Bank")["GeldGK"]) ).."' WHERE `Benutzername`='"..MySQL_Save ( getPlayerName(player) ).."'")
	mysql_free_result ( saved )
end

function getGK(player)
	if(getElementType(player) ~= "player") then
		return error("getGK > arg #1 not a player",2)
	end
	return getElementData(player,"Bank")["GeldGK"]
end

function setSB(player,amount)
	if(getElementType(player) ~= "player") then
		return error("setSB > arg #1 not a player",2)
	end
	local int = tonumber(amount)
	if(int == nil) then
		return false
	end
	local money = math.floor(int)
	setData(player,"Bank","GeldSB",money,true)
	local saved = mysql_query(Datenbank,"UPDATE `bankkonten` SET `GeldSB`='"..MySQL_Save ( tostring(getElementData(player,"Bank")["GeldSB"]) ).."' WHERE `Benutzername`='"..MySQL_Save ( getPlayerName(player) ).."'")
	mysql_free_result ( saved )
end

function getSB(player)
	if(getElementType(player) ~= "player") then
		return error("getSB > arg #1 not a player",2)
	end
	return getElementData(player,"Bank")["GeldSB"]
end

function getSkin(player)
	if(getElementType(player) ~= "player") then
		return error("getSkin > arg #1 not a player",2)
	end
	return tonumber(getElementData(player,"UnL","Skin"))
end

function getElementSpeed(element,unit)
	if (unit == nil) then unit = 0 end
	if (isElement(element)) then
		local x,y,z = getElementVelocity(element)
		if (unit=="mph" or unit==1 or unit =='1') then
			return (x^2 + y^2 + z^2) ^ 0.5 * 100
		else
			return (x^2 + y^2 + z^2) ^ 0.5 * 1.61 * 100
		end
	else
		outputDebugString("Not an element. Can't get speed")
		return false
	end
end

function outputChatBoxInRange(range,message,player,r,g,b)
	
	if(type(range) ~= "number") then
		return error("outputChatBoxInRange > arg #1 not a number",2)
	elseif(type(message) ~= "string") then
		return error("outputChatBoxInRange > arg #2 not a string",2)
	elseif(getElementType(player) ~= "player") then
		return error("outputChatBoxInRange > arg #3 not a player",2)
	end
	local x,y,z = getElementPosition(player)
	if(r == nil) then
		r=255
	end
	if(g == nil) then
		g=255
	end
	if( b == nil) then
		b=255
	end
	local chatSphere = createColSphere( x, y, z, range )
	local nearbyPlayers = getElementsWithinColShape( chatSphere, "player" )
	destroyElement(chatSphere)
	for i, nearbyPlayer in ipairs( nearbyPlayers ) do
		if(nearbyPlayer ~= player) then
			outputChatBox(tostring(message),nearbyPlayer,r,g,b)
		end
	end
end

local aspam = {}
function antiSpam(player,theTime)
	if(getElementType(player) ~= "player") then
		return error("antiSpam > arg #1 not a player",2)
	end
	if(not theTime) then
		theTime = 500
	end
	if(tonumber(aspam[player])) then
		if(getTickCount () - aspam[player] > theTime) then
			aspam[player]= getTickCount ()
			return true
		end
		return false
	else
		aspam[player]= getTickCount()
		return false
	end
end

local function onJoin()
	aspam[source] = getTickCount()
end
addEventHandler("onPlayerJoin",getRootElement(),onJoin)

_setElementData = setElementData
_setElementInteriorTrigger = true
function setElementData ( element, name,value,stream )
    if _setElementInteriorTrigger then
		
		if(not isElement(element)) then
			return error("setElementData > arg #1 not a element",2)
		elseif(type(name) ~= "string") then
			return error("setElementData > arg #2 not a string",2)
		end
		if(not stream or stream == false) then
			_setElementInteriorTrigger = false
			local result = _setElementData ( element, name,value,false)
			_setElementInteriorTrigger = true
		elseif(stream == true) then
			_setElementInteriorTrigger = false
			local result = _setElementData ( element, name,value,true)
			_setElementInteriorTrigger = true
		end
		return result
    end
end

function setData(element,tname,index,value,stream)
	if(not isElement(element)) then
		return error("setData > arg #1 not a element",2)
	elseif(type(tname) ~= "string") then
		return error("setData > arg #2 not a string",2)
	end
	
	if(getElementData(element,tname) == false) then
		setElementData(element,tname,{})
	end
	local table = getElementData(element,tname)
	table[index] = value
	setElementData(element,tname,table,false)
	if(not stream or stream == false) then
		
	elseif(stream == true) then
		if(getElementData(element,tname.."_c") == false) then
			setElementData(element,tname.."_c",{})
		end
		local table = getElementData(element,tname.."_c")
		table[index] = value
		setElementData(element,tname.."_c",table,true)
		
	end
end

_getElementData = getElementData
_getElementDatTrigger = true
function getElementData ( element, name,index )
    if _getElementDatTrigger then
		if(not element ) then
			return error("getElementData > no argument",2)
		elseif(not isElement(element)) then
			return error("getElementData > arg #1 not a element",2)
		elseif(type(name) ~= "string") then
			return error("getElementData > arg #2 not a string",2)
		end
		local result
		if(not index) then
			_getElementDatTrigger = false
			result = _getElementData ( element, name)
			_getElementDatTrigger = true
		else
			_getElementDatTrigger = false
			if(_getElementData(element,name)) then
				_getElementDatTrigger = true
				
				_getElementDatTrigger = false
				result = _getElementData ( element, name)[index]
				_getElementDatTrigger = true
			else
				_getElementDatTrigger = false
				result = _getElementData ( element, name)
				_getElementDatTrigger = true
			end
			_getElementDatTrigger = true
		end
		return result
    end
end

function getPlayerSpawn(player)
	if(getElementType(player) ~= "player") then
		return error("getPlayerSpawn > arg #1 not a player",2)
	end
	return getElementData(player,"UnL","X"), getElementData(player,"UnL","Y"), getElementData(player,"UnL","Z")
end

local cEE = {}
function enterInterior(player,x,y,z,x2,y2,z2,r,interior,dimension)
		if(getElementType(player) ~= "player") then
			return error("enterInterior > arg #1 not a player",2)
		elseif(type(x) ~= "number") then
			return error("enterInterior > arg #2 not a coordinate",2)
		elseif(type(y) ~= "number") then
			return error("enterInterior > arg #3 not a coordinate",2)
		elseif(type(z) ~= "number") then
			return error("enterInterior > arg #4 not a coordinate",2)
		elseif(type(x2) ~= "number") then
			return error("enterInterior > arg #5 not a coordinate",2)
		elseif(type(y2) ~= "number") then
			return error("enterInterior > arg #6 not a coordinate",2)
		elseif(type(z2) ~= "number") then
			return error("enterInterior > arg #7 not a coordinate",2)
		elseif(type(r) ~= "number") then
			return error("enterInterior > arg #8 not a coordinate",2)
		elseif(type(interior) ~= "number") then
			return error("enterInterior > arg #9 not a number",2)
		elseif(type(dimension) ~= "number") then
			return error("enterInterior > arg #10 not a number",2)
		end
		local px,py,pz = getElementPosition(player)
		if(getDistanceBetweenPoints3D( x,y,z,px,py,pz) > 1.0) then
			return false
		end
		if(cEE[player] == true) then
			return false
		end
		cEE[player] = true
		fadeCamera(player,false,2.5)
		toggleAllControls (player,false)	
		setTimer(
		function()
			setPedRotation ( player, r )
			setElementPosition( player,x2,y2,z2)
			cEE[player] = false
			if(dimension) then
				setElementDimension(player,dimension)
			else
				setElementDimension(player,0)
			end
			if(interior) then
				setElementInterior(player,interior)
			else
				setElementInterior(player,0)
			end
			toggleAllControls (player,true)
			fadeCamera(player,true,2.5)
			setTimer(
			function()
				setCameraTarget(player,player)
			end,100,1)
		end , 2500,1)
		return true
end

local function blockEnter(player)
	if(cEE[player] == true) then
		cancelEvent()
	end
end -- Einsteigen wird geblockt, sofern der Spieler gerade in ein Haus geht...
addEventHandler("onVehicleStartEnter",getRootElement(),blockEnter)

local function setCameraRotation(p,r)
	triggerClientEvent(p,"Rotation",p,r)
end

function string.getCharCount(string,char)
	if(type(string) ~= "string") then
		return error("string.getCharCount > arg #1 not a string",2)
	elseif(type(char) ~= "string" or #char > 1) then
		return error("string.getCharCount > arg #2 not a char",2)
	end
	local count = 0
	local cstring = string
	while(string.find(cstring,char)) do
		local p, pos = string.find(cstring,char)
		cstring = string.sub(cstring,pos+1,string.len(cstring))
		count = count + 1
	end
	return count
end

local function getPlayerFrontPos(player)
	if(getElementType(player) ~= "player") then
		return error("getPlayerFrontPos > arg #1 not a player",2)
	end
	if(getPedOccupiedVehicle ( player )) then
		local abstand = 5
		local x,y,z = getElementPosition(getPedOccupiedVehicle ( player ))
		rx,ry, rota = getElementRotation ( getPedOccupiedVehicle ( player ) )
		local nx = math.sin(math.rad(rota)) * abstand
		local ny = math.sqrt(abstand^2 - nx^2)
	
		if(rota <=90 or rota >=270) then
			createPickup(x + nx,y - ny,z,3,1239,2000)
			setVehicleDoorState ( getPedOccupiedVehicle ( player ), 3, 1 )
			--createObject(1337,x + nx,y - ny,z)
			return x + nx,y - ny,z
		elseif(rota > 90 and rota < 270) then
			createPickup(x + nx,y + ny,z,1239,2000)
			setVehicleDoorState ( getPedOccupiedVehicle ( player ), 3, 1 )
			--createObject(1337,x + nx,y + ny,z)
			return x + nx,y + ny,z
		end
		
		outputChatBox(tostring(rx))
	end
end

function table.len(table)
	if(type(table) ~= "table") then
		error("table.len > arg #1 not a table",2)
		return false
	end
	local count = 0
	for index,value in pairs(table) do
		--if(value) then
			count = count + 1
		--end
	end
	return count
end

_killTimer = killTimer
function killTimer(theTimer)
	if(isTimer(theTimer) and getTimerDetails ( theTimer )) then
		return _killTimer(theTimer)
	else
		return false
	end
end


