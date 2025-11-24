
-- Direct X Drawing
local inventarKey = "i"

local aktuel,oldaktuel = "Potte","Potte"
local fx,fy = guiGetScreenSize()
local x,y,bx,by, slots
local btn_Potte, btn_Taschen, btn_Waffen, btn_Keys, btn_Close, btn_Move, btn_Reset, btn_origin
local pClose,pMove,pReset
local r,g,b
local itemPlatzR,itemPlatzG,itemPlatzB = {["Potte"]= {},["Taschen"]={},["Keys"]={}, ["Waffen"]={}},{["Potte"]= {},["Taschen"]={},["Keys"]={}, ["Waffen"]={}},{["Potte"]= {},["Taschen"]={},["Keys"]={}, ["Waffen"]={}}
local btn_inventar = {["Potte"]= {},["Taschen"]={},["Keys"]={}, ["Waffen"]={}}
local spawnLock,callCheck, mouseDistX,mouseDistY
local IBtext,ueberSize, textSize,IBx,IBy,Itx,Ity,Iobx,Ioby,Ibx,Iby, IBUeber,BlipInfo, InfoBlipTimer,showInfoBlip
local aname, atext
local startMoveButton,lastOver
local item,sitem,itemFront = {},{},{}

-- В начале файла добавьте:
function debugOutput(message)
    outputDebugString("[INVENTORY_CLIENT] " .. message)
end

function getRealItemName(name)
	local nstring,w = string.gsub(name,"weapons/","")
	return refreshStringManuel(nstring)
end

local function moveInfoWindow(x,y)
	setInventarBlipPos(x+5,y+8)
end

local function getPlaceMouseOver()
	local src = false
	local mx,my =  getCursorPosition()
	for i=0,slots-1,1 do
		if(btn_inventar[aktuel][i]) then
			local x,y = guiGetPosition(btn_inventar[aktuel][i],true)
			local bx,by = guiGetSize(btn_inventar[aktuel][i],true)
			bx,by = bx +x , by +y
			if(mx > x and mx < bx and my > y and my < by) then
				return btn_inventar[aktuel][i]
			end
		end
	end
	return false
end

local function showInfoBlipFunc(button)
	if(showInfoBlip == true) then
		return false
	end
	local fx,fy = guiGetScreenSize()
	local mx,my = getCursorPosition ()
	if(getElementData(getLocalPlayer(),"Item_"..aktuel.."_c") == false) then
		showInfoBlip = "close"
		return false
	end
	local id = getElementData(getLocalPlayer(),"Item_"..aktuel.."_c")[guiGetText(button).."_id"]
	if(id == nil) then
		showInfoBlip = "close"
		return 0
	end
	
	local name = getElementData(getLocalPlayer(),"Item_c")[tonumber(id)]
	local text = getElementData(getLocalPlayer(),"Iteminfo_c")[name]
	aname, atext = getRealItemName(name),text
	showInfoBlip = true
	setInventarBlipData(name,text,mx * fx + 5,my *fy + 8)
	addEventHandler("onClientMouseMove",getRootElement(),moveInfoWindow)
	
end

local function onItemMouseOver()
	local src = false
	for i=0,slots-1,1 do
		if(source == btn_inventar[aktuel][i]) then
			src = true
		end
	end
	if(src ~= true) then
		return 0
	end
	
	if(showInfoBlip == true) then
		return false
	end
	if(not lockItemUseState[aktuel] or not lockItemUseState[aktuel][tonumber(guiGetText(source))]) then
		setItemRGB(tonumber(guiGetText(source)),255,255,0)
	end
	InfoBlipTimer = setTimer(showInfoBlipFunc,1000,1,source)
end

local function onItemMouseLeave()
	local src = false
	for i=0,slots-1,1 do
		if(source == btn_inventar[aktuel][i]) then
			src = true
		end
	end
	if(src ~= true ) then
		return false
	end
	if(( ( lockItemUseState[aktuel] and lockItemUseState[aktuel][tonumber(guiGetText(source))] ) )) then
	
	else
		setItemRGB(tonumber(guiGetText(source)), 110,110,110 )
	end
	
	if(showInfoBlip) then
		showInfoBlip = false
		InventarBlipAlpha = 0
		removeEventHandler("onClientMouseMove",getRootElement(),moveInfoWindow)
	end
	killTimer(InfoBlipTimer)
end

local function tesssst()
	
		
end
addCommandHandler("bug",tesssst)

local function onCloseClick(button)
	if(button ~= "left") then
		return 0
	end
	destroyInventar()
end

function MoveGUI(mx,my)
	x,y = mx - mouseDistX, my - mouseDistY
	slots = tonumber(getElementData(getLocalPlayer(),"Inventar_c")[aktuel.."Platz"])
	local line,oline,platz
	for i=0,slots-1,1 do
		line = math.floor(i/7)
		if(line ~= oline) then 
			platz = 0 
		end
		local id
		if(	getElementData(getLocalPlayer(),"Item_"..aktuel.."_c") ) then
			id = getElementData(getLocalPlayer(),"Item_"..aktuel.."_c")[i.."_id"]
			if(id) then
				item[id]= { ["x"]= x+10 + 40 * platz + 5 * platz,["y"]=y+10 + 40 * line + 5 * line }
			end
		end
		guiSetPosition ( btn_inventar[aktuel][i], x+10 + 40 * platz + 5 * platz,y+10 + 40 * line + 5 * line, false )
		sitem[i]= { ["x"]= x+10 + 40 * platz + 5 * platz,["y"]=y+10 + 40 * line + 5 * line }
		oline = line
		platz = platz + 1
	end
	guiSetPosition ( btn_Potte, x+2,y-48, false )
	guiSetPosition ( btn_Keys ,x+2 + 82,y-48, false )
	guiSetPosition ( btn_Taschen , x+2 + 82*2,y-48, false )
	guiSetPosition ( btn_Waffen,  x+2 + 82*3,y-48, false )
	guiSetPosition ( btn_Close , x+bx + 1,y-49, false )
	guiSetPosition ( btn_Move, x+bx + 1,y-49+18, false )
	guiSetPosition ( btn_Reset, x+bx + 1,y-49+36, false )
	
end

local function onMoveClick(button,mx,my)
	if(button ~= "left") then
		return 0
	end
	unbindKey("i","down",destroyInventar)
	mouseDistX,mouseDistY = mx - x, my - y
	addEventHandler("onClientMouseMove",root,MoveGUI)
end

local function onStopMove(button)
	if(button ~= "left") then
		return 0
	end
	removeEventHandler("onClientMouseMove",root,MoveGUI)
	bindKey("i","down",destroyInventar)
end

local function onResetClick(button)
	if(button ~= "left") then
		return 0
	end
	
	x,y = fx/2 - bx/2,fy/2 - by/2
	slots = tonumber(getElementData(getLocalPlayer(),"Inventar_c")[aktuel.."Platz"])
	local line,oline,platz
	for i=0,slots-1,1 do
		line = math.floor(i/7)
		if(line ~= oline) then 
			platz = 0 
		end
		local id
		if(	getElementData(getLocalPlayer(),"Item_"..aktuel.."_c") ) then
			id = getElementData(getLocalPlayer(),"Item_"..aktuel.."_c")[i.."_id"]
			if(id) then
				item[id]= { ["x"]= x+10 + 40 * platz + 5 * platz,["y"]=y+10 + 40 * line + 5 * line }
			end
		end
		guiSetPosition ( btn_inventar[aktuel][i], x+10 + 40 * platz + 5 * platz,y+10 + 40 * line + 5 * line, false )
		sitem[i]= { ["x"]= x+10 + 40 * platz + 5 * platz,["y"]=y+10 + 40 * line + 5 * line }
		oline = line
		platz = platz + 1
	end
	guiSetPosition ( btn_Potte, x+2,y-48, false )
	guiSetPosition ( btn_Keys ,x+2 + 82,y-48, false )
	guiSetPosition ( btn_Taschen , x+2 + 82*2,y-48, false )
	guiSetPosition ( btn_Waffen,  x+2 + 82*3,y-48, false )
	guiSetPosition ( btn_Close , x+bx + 1,y-49, false )
	guiSetPosition ( btn_Move, x+bx + 1,y-49+18, false )
	guiSetPosition ( btn_Reset, x+bx + 1,y-49+36, false )
end

local function renderInventar()
		if(isMainMenuActive()) then
			destroyInventar()
			return false
		end
		dxDrawRectangle(x,y-50,82.0,50.0,tocolor(r["Rahmen"],g["Rahmen"],b["Rahmen"],255),false)
        dxDrawRectangle(x+2,y-48,80.0,48.0,tocolor(0,0,0,255),true)
		dxDrawRectangle(x+2.0,y-48,80.0,48.0,tocolor(r["Potte"],g["Potte"],b["Potte"],200),true)
		dxDrawImage(x+20,y-48,48.0,48.0,"images/portmonai.png",0.0,0.0,0.0,tocolor(255,255,255,255),true)
		
		dxDrawRectangle(x + 82,y-50,82.0,50.0,tocolor(r["Rahmen"],g["Rahmen"],b["Rahmen"],255),false)
        dxDrawRectangle(x+2 + 82,y-48,80.0,48.0,tocolor(0,0,0,255),true)
		dxDrawRectangle(x+2 + 82,y-48,80.0,48.0,tocolor(r["Keys"],g["Keys"],b["Keys"],200),true)
		dxDrawImage(x+20 + 82,y-48,48.0,48.0,"images/schluesselbund.png",0.0,0.0,0.0,tocolor(255,255,255,255),true)
		
		dxDrawRectangle(x + 82*2,y-50,82.0,50.0,tocolor(r["Rahmen"],g["Rahmen"],b["Rahmen"],255),false)
        dxDrawRectangle(x+2 + 82*2,y-48,80.0,48.0,tocolor(0,0,0,255),true)
		dxDrawRectangle(x+2 + 82*2,y-48,80.0,48.0,tocolor(r["Taschen"],g["Taschen"],b["Taschen"],200),true)
		dxDrawImage(x+20 + 82*2,y-48,48.0,48.0,"images/rucksackIcon.png",0.0,0.0,0.0,tocolor(255,255,255,255),true)
		
		dxDrawRectangle(x + 82*3,y-50,84.0,50.0,tocolor(r["Rahmen"],g["Rahmen"],b["Rahmen"],255),false)
        dxDrawRectangle(x+2 + 82*3,y-48,80.0,48.0,tocolor(0,0,0,255),true)
		dxDrawRectangle(x+2 + 82*3,y-48,80.0,48.0,tocolor(r["Waffen"],g["Waffen"],b["Waffen"],200),true)
		dxDrawImage(x+20 + 82*3,y-48,48.0,48.0,"images/gun.png",0.0,0.0,0.0,tocolor(255,255,255,255),true)
		
		dxDrawImage(x+bx + 1,y-49,18,18,pClose,0.0,0.0,0.0,tocolor(255,255,255,255),true)
		dxDrawImage(x+bx + 1,y-49+18,18.0,18.0,pMove,0.0,0.0,0.0,tocolor(255,255,255,255),true)
		dxDrawImage(x+bx + 1,y-49+36,18.0,18.0,pReset,0.0,0.0,0.0,tocolor(255,255,255,255),true)
		dxDrawRectangle(x+bx ,y-50,20.0,56.0,tocolor(0,0,0,200),false)

		dxDrawRectangle(x,y,bx,by,tocolor(r["Rahmen"],g["Rahmen"],b["Rahmen"],255),false)
		dxDrawRectangle(x+2,y+2,bx-4,by-4,tocolor(0,0,0,255),false)
		
		local line
		local oline
		local platz
		for i=0,slots-1,1 do
			line = math.floor(i/7)
			if(line ~= oline) then 
				platz = 0 
			end
			if(not itemPlatzR[aktuel][i]) then
				if(not lockItemUseState[aktuel] or not lockItemUseState[aktuel][i]) then
					setItemRGB(i,110,110,110)
				end
			end
			dxDrawRectangle(x+10 + 40 * platz + 5 * platz,y+10 + 40 * line + 5 * line,40,40,tocolor(itemPlatzR[aktuel][i],itemPlatzG[aktuel][i],itemPlatzB[aktuel][i],200),false)
			if(getElementData(getLocalPlayer(),"Item_"..aktuel.."_c")) then
				local slotid = getElementData(getLocalPlayer(),"Item_"..aktuel.."_c")[tostring(i).."_id"]
				if(slotid) then
					local rx,gx,bx = itemPlatzR[aktuel][i] - 10,itemPlatzG[aktuel][i]- 10,itemPlatzB[aktuel][i]- 10
					local a = 255
					if (rx == 100) then
						rx,gx,bx = 255,255,255
						a = 180
					end
					local itemname = getElementData(getLocalPlayer(),"Item_c")
					if(itemname and itemname[slotid]) then
							if(	getElementData(getLocalPlayer(),"Item_"..aktuel.."_c") ) then
								id = getElementData(getLocalPlayer(),"Item_"..aktuel.."_c")[i.."_id"]
								if(id) then
									dxDrawImage(item[id]["x"],item[id]["y"],40,40,"images/items/"..itemname[slotid]..".png",0.0,0.0,0.0,tocolor(rx,gx,bx,255),itemFront[id])
									dxDrawText(tostring(getElementData(getLocalPlayer(),"Item_c")[tostring(slotid).."_Menge"]),item[id]["x"] + 40 - dxGetTextWidth (tostring(getElementData(getLocalPlayer(),"Item_c")[tostring(slotid).."_Menge"] , 0.85, "defauld-bold")),item[id]["y"] + 27.25,40,40,tocolor(rx,gx,bx,a),0.85,"default-bold","left","top",false,false,itemFront[id])
								end
							end
					end
				end
			end
			oline = line
			platz = platz + 1
		end
		
		if(showInfoBlip == true) then
			showInfo(IBUeber,IBtext,IBx,IBy,Itx,Ity,Iobx,Ioby,Ibx,Iby)
		end
		
		
end

local function onClientDragAndDropMove()
	local mx,my = getCursorPosition ()
	local x,y = startMoveButton["x"],startMoveButton["y"]
	local fx,fy = startMoveButton["bx"] + x,startMoveButton["by"] + y
	--if(mx < x or mx >fx or my < y or my > fy) then
		local button = startMoveButton["object"]
		local platz
		if(getElementData(getLocalPlayer(),"Item_"..aktuel.."_c") ~= false) then
			platz = getElementData(getLocalPlayer(),"Item_"..aktuel.."_c")[guiGetText(button).."_id"]
		else
			platz = nil
		end
		
		if(showInfoBlip) then
			showInfoBlip = false
			InventarBlipAlpha = 0
			removeEventHandler("onClientMouseMove",getRootElement(),moveInfoWindow)
		end
		killTimer(InfoBlipTimer)
		if(getPlaceMouseOver() ~= button) then
			triggerEvent("onClientMouseLeave",button)
		end
		if(platz) then
			local place = guiGetText(button)
			local fullx,fully = guiGetScreenSize()
			mx,my = mx*fullx,my*fully
			if(	getElementData(getLocalPlayer(),"Item_"..aktuel.."_c") ) then
				id = getElementData(getLocalPlayer(),"Item_"..aktuel.."_c")[place.."_id"]
				if(id) then
					item[tonumber(id)] = { ["x"]= mx,["y"]=my }
				end
			end
			
			if(isElement(getPlaceMouseOver())) then
				triggerEvent("onClientMouseEnter",getPlaceMouseOver())
				if(isElement(lastOver) and lastOver ~= getPlaceMouseOver()) then
					triggerEvent("onClientMouseLeave",lastOver)
				end
				lastOver = getPlaceMouseOver()
			elseif(isElement(lastOver)) then
				triggerEvent("onClientMouseLeave",lastOver)
				lastOver = nil
			end
		else
			startMoveButton = nil
			removeEventHandler("onClientPreRender",getRootElement(),onClientDragAndDropMove)
		end
	--end
end

local function onClickAndDropDown(button)
	local src
	for i=0,slots-1,1 do
		if(source == btn_inventar[aktuel][i]) then
			src = true
		end
	end
	if(src ~= true) then
		if(source ~= btn_Move and (source == btn_Potte or source == btn_Keys or source == btn_Taschen or source == btn_Waffen or source == btn_Close or source == btn_Reset) ) then
			startMoveButton = { ["object"] = source }
			startMoveButton["x"],startMoveButton["y"] = guiGetPosition ( source, true )
			startMoveButton["bx"],startMoveButton["by"] = guiGetSize ( source, true ) 
			addEventHandler("onClientPreRender",getRootElement(),onClientDragAndDropMove)
			return false
		end
		return false
	end
	local id 
	if(getElementData(getLocalPlayer(),"Item_"..aktuel.."_c")) then
		id = getElementData(getLocalPlayer(),"Item_"..aktuel.."_c")[guiGetText(source).."_id"]
	end
	if(button ~= "left") then
		if(id) then
			triggerEvent("onPlayerItemUse",getLocalPlayer(),getElementData(getLocalPlayer(),"Item_c")[id],id,aktuel,tonumber(guiGetText(source)))
		end
		return false
	end
	if(id) then
		itemFront[id] = true
	end
	startMoveButton = { ["object"] = source }
	startMoveButton["x"],startMoveButton["y"] = guiGetPosition ( source, true )
	startMoveButton["bx"],startMoveButton["by"] = guiGetSize ( source, true ) 
	addEventHandler("onClientPreRender",getRootElement(),onClientDragAndDropMove)
end

local function onClickAndDropUp(button)
	if(button ~= "left") then
		return false
	end
	local src
	for i=0,slots-1,1 do
		if(source == btn_inventar[aktuel][i]) then
			src = true
		end
	end
	if(src ~= true) then
		if(source ~= btn_Move and (source == btn_Potte or source == btn_Keys or source == btn_Taschen or source == btn_Waffen or source == btn_Close or source == btn_Reset) ) then
			startMoveButton = nil
			lastOver = nil
			removeEventHandler("onClientPreRender",getRootElement(),onClientDragAndDropMove)
			return false
		end
		return false
	end
	
	if(startMoveButton) then
		local place
		local sbutton = startMoveButton["object"]
		local splace = tonumber(guiGetText(sbutton))
		if(getPlaceMouseOver()) then
			place = guiGetText(getPlaceMouseOver())
		end
		if(place) then
			local nid = getElementData(getLocalPlayer(),"Item_"..aktuel.."_c")[place.."_id"]
			if(nid) then
				local oPlace = guiGetText(sbutton)
				
				local id = getElementData(getLocalPlayer(),"Item_"..aktuel.."_c")[splace.."_id"]
				inventarSetItemToPlace(id,place)
				inventarSetItemToPlace(nid,splace)
				
				if(lockItemUseState[aktuel] and lockItemUseState[aktuel][splace]) then
					setItemsRGBDefault(aktuel)
					setItemRGB(splace,0,255,0)
					lockItemUseState[aktuel] = {[splace]=true}
				end
				
				triggerServerEvent("changePlaces",getLocalPlayer(),getLocalPlayer(),aktuel,oPlace,place)
			else 
				local id = getElementData(getLocalPlayer(),"Item_"..aktuel.."_c")[splace.."_id"]
				if(lockItemUseState[aktuel] and lockItemUseState[aktuel][splace]) then
					setItemsRGBDefault(aktuel)
					setItemRGB(tonumber(place),0,255,0)
					lockItemUseState[aktuel] = {[tonumber(place)]=true}
					
				end
				
				inventarSetItemToPlace(id,place)
				triggerServerEvent("c_setItemPlace",getLocalPlayer(),aktuel,splace,tonumber(place))
			end
		else
			local mx,my = getCursorPosition ( )
			mx,my = mx *fx,my*fy
			
			if(mx >= x and mx <= x+bx and my >= y-50 and my <= y+by) then
				local id = getElementData(getLocalPlayer(),"Item_"..aktuel.."_c")[splace.."_id"]
				inventarSetItemToPlace(id,splace)
				if(lockItemUseState[aktuel] and lockItemUseState[aktuel][splace]) then
					setItemsRGBDefault(aktuel)
					
				--	outputChatBox("To Green")
					setItemRGB(splace,0,255,0,true)
					--lockItemUseState[aktuel] = {[splace] = true}
				end
			else
				local id = getElementData(getLocalPlayer(),"Item_"..aktuel.."_c")[splace.."_id"]
				triggerServerEvent("layItemInWorld_c",getLocalPlayer(),getLocalPlayer(),aktuel,id)
			end
		end
	end
	
	startMoveButton = nil
	lastOver = nil
	removeEventHandler("onClientPreRender",getRootElement(),onClientDragAndDropMove)
	
	local id
	if(getElementData(getLocalPlayer(),"Item_"..aktuel.."_c")) then
		id = getElementData(getLocalPlayer(),"Item_"..aktuel.."_c")[guiGetText(source).."_id"]
	end
	if(id) then
		itemFront[id] = false
	end
end
function showInventar(teil)
	if(type(teil) == "string" and teil ~= "i") then
		aktuel = teil
	end
	unbindKey("i","down",showInventar)
	bindKey("i","down",destroyInventar)
	showCursor ( true ,false)
	toggleControl ( "fire", false)
	pClose,pMove,pReset = "images/closeinv.png","images/moveinv.png","images/reset.png"
	r,g,b = { ["Potte"]=110,["Taschen"]=110,["Keys"]=110,["Waffen"]=110, ["Rahmen"]=255} , { ["Potte"]=110,["Taschen"]=110,["Keys"]=110,["Waffen"]=110 ,["Rahmen"]=255} , { ["Potte"]=110,["Taschen"]=110,["Keys"]=110,["Waffen"]=110,["Rahmen"]=255 }
	 
	slots = tonumber(getElementData(getLocalPlayer(),"Inventar_c")[aktuel.."Platz"])
	lines = math.ceil(slots/7)
	bx,by = 330, 20 - 4 + 45*lines --543,266
	if(not x and not y) then
		x,y = fx/2 - bx/2,fy/2 - by/2
	end
	r[aktuel],g[aktuel],b[aktuel] = 0,255,0
	r["o"..aktuel],g["o"..aktuel],b["o"..aktuel] = 0,255,0
	local line
	local oline
	local platz
	
	for i=0,slots-1,1 do
		line = math.floor(i/7)
		if(line ~= oline) then 
			platz = 0 
		end
		btn_inventar[aktuel][i] = guiCreateButton (x+10 + 40 * platz + 5 * platz,y+10 + 40 * line + 5 * line,40,40, i.."", false)
		guiSetAlpha(btn_inventar[aktuel][i],0)
		local id
		if(	getElementData(getLocalPlayer(),"Item_"..aktuel.."_c") ) then
			id = getElementData(getLocalPlayer(),"Item_"..aktuel.."_c")[i.."_id"]
			if(id) then
				item[id]= { ["x"]= x+10 + 40 * platz + 5 * platz ,["y"]=y+10 + 40 * line + 5 * line }
				itemFront[id] = false
			end
		end
		if(not lockItemUseState[aktuel] or not lockItemUseState[aktuel][tonumber(i)]) then
			setItemRGB(i,110,110,110)
		end
		sitem[i]= { ["x"]= x+10 + 40 * platz + 5 * platz,["y"]=y+10 + 40 * line + 5 * line }
		oline = line
		platz = platz + 1
	end
	
	btn_Potte = guiCreateButton (x+2,y-48,80.0,48.0, "", false)
	guiSetAlpha(btn_Potte,0)
	btn_Keys = guiCreateButton ( x+2 + 82,y-48, 80.0,48.0, "", false )
	guiSetAlpha(btn_Keys,0)
	btn_Taschen = guiCreateButton ( x+2 + 82*2,y-48, 80.0,48.0, "", false )
	guiSetAlpha(btn_Taschen,0)
	btn_Waffen = guiCreateButton ( x+2 + 82*3,y-48, 80.0,48.0, "", false )
	guiSetAlpha(btn_Waffen,0)
	btn_Close = guiCreateButton ( x+bx + 1,y-49, 18,18, "", false  )
	guiSetAlpha(btn_Close,0)
	btn_Move = guiCreateButton ( x+bx + 1,y-49+18, 18,18, "", false )
	guiSetAlpha(btn_Move,0)
	btn_Reset = guiCreateButton ( x+bx + 1,y-49+36, 18,18, "", false )
	guiSetAlpha(btn_Reset,0)
	
	
	addEventHandler("onClientMouseEnter",getRootElement(),onButtonInvEnter)
	addEventHandler("onClientMouseLeave",getRootElement(),onButtonInvLeave)
	addEventHandler("onClientGUIClick",getRootElement(),onInvClick)
	
	addEventHandler("onClientMouseEnter",getRootElement(),onItemMouseOver)
	addEventHandler("onClientMouseLeave",getRootElement(),onItemMouseLeave)
	
	addEventHandler("onClientGUIClick",btn_Close,onCloseClick)
	addEventHandler("onClientGUIMouseDown",btn_Move,onMoveClick)
	addEventHandler("onClientGUIMouseUp",btn_Move,onStopMove)
	addEventHandler("onClientGUIClick",btn_Reset,onResetClick)
	
	addEventHandler("onClientGUIMouseDown",getRootElement(),onClickAndDropDown)
	addEventHandler("onClientGUIMouseUp",getRootElement(),onClickAndDropUp)
	
	
	addEventHandler("onClientRender",getRootElement(),renderInventar)
end

function destroyInventar()
	if(not btn_Potte) then
		return false
	end
	unbindKey("i","down",destroyInventar)
	bindKey("i","down",showInventar)
	showCursor ( false )
	toggleControl ( "fire", true)
	removeEventHandler("onClientRender",getRootElement(),renderInventar)
	removeEventHandler("onClientMouseEnter",getRootElement(),onButtonInvEnter)
	removeEventHandler("onClientMouseLeave",getRootElement(),onButtonInvLeave)
	removeEventHandler("onClientGUIClick",getRootElement(),onInvClick)
	removeEventHandler("onClientMouseEnter",getRootElement(),onItemMouseOver)
	removeEventHandler("onClientMouseLeave",getRootElement(),onItemMouseLeave)
	removeEventHandler("onClientGUIClick", btn_Close,onCloseClick)
	removeEventHandler("onClientGUIMouseDown",btn_Move,onMoveClick)
	removeEventHandler("onClientGUIMouseUp",btn_Move,onStopMove)
	removeEventHandler("onClientMouseMove",root,MoveGUI)
	removeEventHandler("onClientMouseMove",getRootElement(),moveInfoWindow)
	removeEventHandler("onClientGUIMouseDown",getRootElement(),onClickAndDropDown)
	removeEventHandler("onClientGUIMouseUp",getRootElement(),onClickAndDropUp)
	
	destroyElement(btn_Potte)
	destroyElement(btn_Keys)
	destroyElement(btn_Taschen)
	destroyElement(btn_Waffen)
	destroyElement(btn_Close)
	destroyElement(btn_Move)
	destroyElement(btn_Reset)
	btn_Potte = nil
	sitem = {}
	item = {}
	if(isTimer(InfoBlipTimer) and getTimerDetails(InfoBlipTimer)) then
		killTimer(InfoBlipTimer)
	end
	if(callCheck == true) then
		local slots = tonumber(getElementData(getLocalPlayer(),"Inventar_c")[oldaktuel.."Platz"])
		for i=0,slots-1,1 do
			destroyElement(btn_inventar[oldaktuel][i])
		end
		callCheck = false
	else
		local slots = tonumber(getElementData(getLocalPlayer(),"Inventar_c")[aktuel.."Platz"])
		for i=0,slots-1,1 do
			destroyElement(btn_inventar[aktuel][i])
		end
	end
	
	showInfoBlip = false
	InventarBlipAlpha = 0
	
end

addEventHandler("onClientPlayerWasted",getLocalPlayer(),destroyInventar)
function onInvClick(button)
	if button ~= "left" then
		return 0
	end
	if(source ~= btn_Potte and source ~= btn_Keys and source ~= btn_Taschen and source ~= btn_Waffen) then
		return 0
	end
	oldaktuel = aktuel
	if( source == btn_Potte and aktuel ~= "Potte") then
		aktuel = "Potte"
	elseif( source == btn_Keys and aktuel ~= "Keys") then
		aktuel = "Keys"
	elseif( source == btn_Taschen and aktuel ~= "Taschen") then
		aktuel = "Taschen"
	elseif( source == btn_Waffen and aktuel ~= "Waffen") then
		aktuel = "Waffen"
	else
		return 0
	end
	r[oldaktuel],g[oldaktuel],b[oldaktuel] = 110,110,110
	callCheck = true
	destroyInventar()
	showInventar()
end

function onButtonInvEnter()
	if(source ~= btn_Potte and source ~= btn_Keys and source ~= btn_Taschen and source ~= btn_Waffen and source ~= btn_Close and source ~= btn_Move and source ~= btn_Reset) then
		return 1
	end
	
	if( source == btn_Potte) then
		if(aktuel == "Potte") then
			return 0
		end
		r["oPotte"],g["oPotte"],b["oPotte"] = r["Potte"],g["Potte"],b["Potte"]
		r["Potte"],g["Potte"],b["Potte"] = 255,255,0
	elseif( source == btn_Keys) then
		if(aktuel == "Keys") then
			return 0
		end
		r["oKeys"],g["oKeys"],b["oKeys"] = r["Keys"],g["Keys"],b["Keys"]
		r["Keys"],g["Keys"],b["Keys"] = 255,255,0
	elseif( source == btn_Taschen) then
		if(aktuel == "Taschen") then
			return 0
		end
		r["oTaschen"],g["oTaschen"],b["oTaschen"] = r["Taschen"],g["Taschen"],b["Taschen"]
		r["Taschen"],g["Taschen"],b["Taschen"] = 255,255,0
	elseif( source == btn_Waffen) then
		if(aktuel == "Waffen") then
			return 0
		end
		r["oWaffen"],g["oWaffen"],b["oWaffen"] = r["Waffen"],g["Waffen"],b["Waffen"]
		r["Waffen"],g["Waffen"],b["Waffen"] = 255,255,0
	elseif( source == btn_Close) then
		pClose = "images/closeinvS.png"
	elseif( source == btn_Move) then
		pMove = "images/moveinvS.png"
	elseif( source == btn_Reset) then
		pReset = "images/resetS.png"
	end
end

function onButtonInvLeave()
	if(source ~= btn_Potte and source ~= btn_Keys and source ~= btn_Taschen and source ~= btn_Waffen and source ~= btn_Close and source ~= btn_Move and source ~= btn_Reset) then
		return 1
	end
	if( source == btn_Potte) then
		if(aktuel == "Potte") then
			return 0
		end
		r["Potte"],g["Potte"],b["Potte"] = r["oPotte"],g["oPotte"],b["oPotte"]
	elseif( source == btn_Keys) then
		if(aktuel == "Keys") then
			return 0
		end
		r["Keys"],g["Keys"],b["Keys"] = r["oKeys"],g["oKeys"],b["oKeys"]
	elseif( source == btn_Taschen) then
		if(aktuel == "Taschen") then
			return 0
		end
		r["Taschen"],g["Taschen"],b["Taschen"] = r["oTaschen"],g["oTaschen"],b["oTaschen"]
	elseif( source == btn_Waffen) then
		if(aktuel == "Waffen") then
			return 0
		end
		r["Waffen"],g["Waffen"],b["Waffen"] = r["oWaffen"],g["oWaffen"],b["oWaffen"]
	elseif( source == btn_Close) then
		pClose = "images/closeinv.png"
	elseif( source == btn_Move) then
		pMove = "images/moveinv.png"
	elseif( source == btn_Reset) then
		pReset = "images/reset.png"
	end
	
end

function setInventarBlipData(uber,text,x,y)
	IBUeber = getRealItemName(uber)
	IBtext = text
	IBx,IBy = x,y
	ueberSize = 1.1
	textSize = 0.8
	Itx,Ity = IBx + 8,IBy + 20
	Iobx,Ioby = Itx + 137,Ity --1255,523
	Ibx,Iby = getInfoClip(IBtext,Itx,Ity,Iobx,Ioby ,"default-bold",textSize)
end

function setInventarBlipPos(x,y)
	IBUeber = aname
	IBtext =  atext
	IBx,IBy = x,y
	ueberSize = 1.1
	textSize = 0.8
	Itx,Ity = IBx + 8,IBy + 20
	Iobx,Ioby = Itx + 137,Ity --1255,523
	Ibx,Iby = getInfoClip(IBtext,Itx,Ity,Iobx,Ioby ,"default-bold",textSize)
end

function inventarSetItemToPlace(id,platz)
	item[tonumber(id)] = {["x"]=sitem[tonumber(platz)]["x"],["y"]=sitem[tonumber(platz)]["y"]}
end

local function afterLogin()
	bindKey(inventarKey,"down",showInventar)
end
addEvent("onPlayerLogin",true)
addEventHandler("onPlayerLogin",getLocalPlayer(),afterLogin)

local function showC(pn,platz)
	outputChatBox("X: "..tostring(sitem[tonumber(platz)]["x"].." , Y: "..sitem[tonumber(platz)]["y"]))
end
addCommandHandler("pc",showC)

local function setInventarKoordinaten(platz,tasche)
	if(tasche == aktuel) then	
		local id = getElementData(getLocalPlayer(),"Item_"..aktuel.."_c")[platz.."_id"]
		local line = math.floor(platz/7)
		if(platz ~= 0) then
			platz = platz/(platz/7) - 1
		end
		item[id]= { ["x"]= x+10 + 40 * platz + 5 * platz ,["y"]=y+10 + 40 * line + 5 * line }
	end
end
addEvent("setIKoords_c",true)
addEventHandler("setIKoords_c",getRootElement(),setInventarKoordinaten)

function setItemRGB(platz,r,g,b)
	if(r) then
		itemPlatzR[aktuel][platz] = r
	end
	
	if(g) then
		itemPlatzG[aktuel][platz] = g
	end
	
	if(b) then
		itemPlatzB[aktuel][platz] = b
	end
end