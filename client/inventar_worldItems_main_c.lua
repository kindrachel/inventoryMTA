local function getPositionOnCircle(abstand)
			local x,y,z = getElementPosition(getLocalPlayer() )
			rx,ry,rz = getElementRotation ( getLocalPlayer() )
			local nx = math.sin(math.rad(rz)) * abstand
			local ny = math.sqrt(abstand^2 - nx^2)
		
			if(rz <=90 or rz >=270) then
				return x - nx,y + ny,z
			elseif(rz > 90 and rz < 270) then
				return x - nx,y - ny,z
			end
			return false
end


local function checkPlace(tasche,platz,count,id)
	local Irange = 2.5
	local x,y,z = getPositionOnCircle(Irange)
	local az = getGroundPosition(x,y,z+150)
	if(math.sqrt((z - az)^2) <= 1.5) then
		triggerServerEvent("c_addObjectToWorldIW",getLocalPlayer(),x,y,az +1 ,tasche,platz,count)
	else
		createInfobox("Wegschmeißen","Du kannst hier nichts wegschmeißen. \n*Du hast Angst das man dich bei der Umweltverschmutzung erwischt!" ,nil,nil,4500)
		inventarSetItemToPlace(id,platz)
	end
end
addEvent("checkPlaceIW",true)
addEventHandler("checkPlaceIW",getRootElement(),checkPlace)

local function onSync()
	if(getElementType ( source ) == "pickup" and getElementData(source,"WorldItem") ) then
		triggerServerEvent("c_getItemInfos",getLocalPlayer(),getElementData(source,"WorldItem"))
	end
end
addEventHandler( "onClientElementStreamIn", getRootElement(),onSync)
local functionID = {}
local function onDeSync()
	local id = getElementData(source,"WorldItem")
	if(getElementType ( source ) == "pickup" and id ) then
		removeEventHandler("onClientRender",getRootElement(),functionID[tonumber(id)])
	end
end
addEventHandler("onClientElementStreamOut",getRootElement(),onDeSync)

local function draw3DDraw(id,Name,Menge,x,y,z)
	local drawDistance = 5
		functionID[tonumber(id)] = function()
			local px,py,pz = getElementPosition(getLocalPlayer())
			if(getDistanceBetweenPoints3D(px,py,pz,x,y,z) > drawDistance) then
				return false
			end
			local nBeginn, nEnde = string.find(Name,"weapons/")
			Name = getRealItemName(Name)
			local text
			if(not nBeginn) then
				text = "Item: "..Name.." \nMenge: "..Menge
			else
				text = "Item: "..Name.." \n Munition: "..Menge
			end
			local bx,by = dxGetTextWidth("Item: "..Name,1.8,"sans"),dxGetFontHeight ( 1.8, "sans" )
			local x,y = getScreenFromWorldPosition(x,y,z+0.5)
			if(x) then
				dxDrawText(text,x-bx/2,y,10,10,tocolor(255,0,0,255),1.8,"sans","left","top",false,false,false)
			end
		end
		addEventHandler("onClientRender",getRootElement(),functionID[tonumber(id)])
end
addEvent("getItemInfos",true)
addEventHandler("getItemInfos",getRootElement(),draw3DDraw)

local function kill3DText(id)
	removeEventHandler("onClientRender",getRootElement(),functionID[tonumber(id)])
end
addEvent("kill3DText",true)
addEventHandler("kill3DText",getRootElement(),kill3DText)