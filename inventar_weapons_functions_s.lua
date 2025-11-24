local weapons = { 
["Schlagring"]=1,
["Golfschlaeger"]=2,
["Schlagstock"]=3,
["Messer"]=4,
["Baseballschlaeger"]=5,
["Schaufel"]=6,
["Billiard Koe"]=7,
["Katana"]=8,
["Kettensaege"]=9,
["Pistole"]=22,
["Schalldaempferpistole"]=23,
["Desert Eagle"]=24,
["Schrotflinte"]=25,
["Sawn-Off Schrotflinte"]=26,
["SPAZ-12 Gefechtsschrotflinte"]=27,
["Uzi"]=28,
["MP5"]=29,
["TEC-9"]=32,
["AK-47"]=30,
["M4"]=31,
["Countryschrotflinte"]=33,
["Sniper"]=34,
["Raketenwerfer"]=35,
["Waermelenkraketenwerfer"]=36,
["Flammenwerfer"]=37,
["Granate"]=16,
["Traenengas"]=17,
["Molotov Cocktails"]=18,
["Rucksackbomben"]=39,
["Spraydose"]=41,
["Feuerloescher"]=42,
["Digitalkamera"]=43,
["Langer purpel Dildo"]=10,
["Kurzer Dildo"]=11,
["Vibrator"]=12,
["Blumen"]=14,
["Gehstock"]=15,
["Nachtsichtgeraet"]=44,
["Infrarotsichtgeraet"]=45,
["Fallschirm"]=46,
["Rucksackbombenzuender"]=40
}

function getRealItemName(name)
	local nstring,w = string.gsub(name,"weapons/","")
	return refreshStringManuel(nstring)
end

local _getWeaponIDFromName = getWeaponIDFromName
function getWeaponIDFromName(name)
	return weapons[refreshString(name)] or false
end

local _getWeaponNameFromID = getWeaponNameFromID
function getWeaponNameFromID(id)
	for index,value in pairs(weapons) do
		if(value == id) then
			return refreshStringManuel(index)
		end
	end
	return false
end

local _giveWeapon = giveWeapon
function giveWeapon(player,weapon,ammo,current)
	if(not ammo) then
		ammo = 30
	end
	local wname = getWeaponNameFromID(weapon)
	if(not wname) then
		return false
	end
	local max = getElementData(player,"Iteminfo","weapons/"..refreshString(wname).."_Item_Max")
	if(ammo > max) then
		return giveItem(player,"weapons/"..refreshString(wname),max,"Waffen")
	else
		return giveItem(player,"weapons/"..refreshString(wname),ammo,"Waffen")
	end
	return true
end

local _takeAllWeapons = takeAllWeapons
function takeAllWeapons(player)
	local count = getElementData(player,"Inventar","WaffenPlatz")
	for i=0,count,1 do
		removeItem(player,"Waffen",i)
	end
	return true
end

_takeWeapon = takeWeapon
function takeWeapon(player,weaponid,ammo)
	local count = getElementData(player,"Inventar","WaffenPlatz")
	for i=0,count,1 do
		local id = getElementData(player,"Item_Waffen",i.."_id")
		if(id and getElementData(player,"Item",id) == "weapons/"..getWeaponNameFromID(weaponid)) then
			if(not ammo or ammo > getElementData(player,"Item",id.."_Menge")) then
				ammo = getElementData(player,"Item",id.."_Menge")
			end
			removeItem(player,"Waffen",i,ammo)
		end
	end
end

function getPlayerWeapons(player)
	local count = getElementData(player,"Inventar","WaffenPlatz")
	local PlayerWeapons = {}
	for i=0,count,1 do
		local id = getElementData(player,"Item_Waffen",i.."_id")
		if(id) then
			PlayerWeapons[i] = getWeaponIDFromName( getRealItemName( getElementData(player,"Item",id) ) )
		end
	end
	if(table.len(PlayerWeapons) ~= 0) then
		return PlayerWeapons
	else
		return false
	end
end

local function onWUse(itemid,usestate)
	if(source ~= client) then
		return false
	end
	if(not usestate) then
		if(getElementData(source,"Item")) then
			local itemname = getRealItemName(getElementData(source,"Item",itemid))
			local weaponid = getWeaponIDFromName(itemname)
			local ammo = getElementData(source,"Item",itemid.."_Menge")
			_takeAllWeapons(source)
			_giveWeapon(source,weaponid,ammo,true)
		end
	else
		_takeAllWeapons(source)
	end
end
addEvent("onPlayerWeaponUse",true)
addEventHandler("onPlayerWeaponUse",getRootElement(),onWUse)

local function onWeaponFire(weaponid,leftAmmo)
	if (source ~= client) then
		return false
	end
	
	local count = getElementData(source,"Inventar","WaffenPlatz")
	for i=0,count,1 do
		local id = getElementData(source,"Item_Waffen",i.."_id")
		if(id and getElementData(source,"Item",id) == "weapons/"..getWeaponNameFromID(weaponid)) then
			if(leftAmmo <= 0) then
				removeItem(source,"Waffen",i)
			else
				removeItem(source,"Waffen",i,getElementData(source,"Item",id.."_Menge") - leftAmmo)
			end
			break
		end
	end
end
addEvent("onWeaponFire",true)
addEventHandler("onWeaponFire",getRootElement(),onWeaponFire)
