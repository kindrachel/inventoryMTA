-- inventar_main_s.lua (ИСПРАВЛЕННАЯ ВЕРСИЯ)
local connection = nil
local playerItems = {}

function getDBConnection()
    if not connection then
        connection = exports.inv2:getConnection() -- убедитесь что ресурс называется inv2
    end
    return connection
end

-- Добавьте проверку экспортов
addEventHandler("onResourceStart", resourceRoot, function()
    outputDebugString("[WORLDITEMS] Проверяем экспорты...")
    outputDebugString("getConnection export: " .. tostring(exports.inv2 and exports.inv2.getConnection))
    
    setTimer(function()
        if getDBConnection() then
            outputDebugString("[WORLDITEMS] ✅ Подключение к БД установлено")
            loadWorldItems()
        else
            outputDebugString("[WORLDITEMS] ❌ Нет подключения к БД", 1)
        end
    end, 5000, 1)
end)

function waitForDBConnection(callback)
    local attempts = 0
    local maxAttempts = 10
    
    local function checkConnection()
        attempts = attempts + 1
        local db = getDBConnection()
        
        if db then
            outputDebugString("[INVENTORY] ✅ Подключение к БД установлено (попытка " .. attempts .. ")")
            if callback then callback(true) end
        elseif attempts < maxAttempts then
            outputDebugString("[INVENTORY] ⏳ Ожидание подключения к БД... (" .. attempts .. ")", 2)
            setTimer(checkConnection, 1000, 1)
        else
            outputDebugString("[INVENTORY] ❌ Не удалось подключиться к БД после " .. maxAttempts .. " попыток", 1)
            if callback then callback(false) end
        end
    end
    
    checkConnection()
end

-- Загрузка предметов игрока
function loadPlayerItems(player)
    waitForDBConnection(function(success)
        if not success then
            outputDebugString("[INVENTORY] ❌ Не могу загрузить предметы для " .. getPlayerName(player) .. " - нет подключения к БД", 1)
            return
        end
        
        local user_id = getElementData(player, "user_id")
        if not user_id then
            outputDebugString("[INVENTORY] ❌ Нет user_id для игрока " .. getPlayerName(player), 1)
            return
        end
        
        local db = getDBConnection()
        if not db then return end
        
        dbQuery(function(qh)
            local result = dbPoll(qh, 0)
            if not result then
                outputDebugString("[INVENTORY] ❌ Ошибка запроса для игрока " .. getPlayerName(player), 1)
                return
            end
            
            playerItems[player] = {}
            
            for i, row in ipairs(result) do
                -- Преобразуем JSON данные
                local value = row.value
                if value and string.sub(value, 1, 1) == "{" then
                    value = fromJSON(value) or value
                end
                
                local nbt = row.nbt
                if nbt and string.sub(nbt, 1, 1) == "{" then
                    nbt = fromJSON(nbt) or nbt
                end
                
                playerItems[player][tonumber(row.slot)] = {
                    id = tonumber(row.id),
                    item_id = tonumber(row.item_id),
                    value = value,
                    count = tonumber(row.count) or 1,
                    status = tonumber(row.status) or 100,
                    dutyitem = tonumber(row.dutyitem) or 0,
                    premium = tonumber(row.premium) or 0,
                    nbt = nbt or {}
                }
            end
            
            setElementData(player, "inventory", playerItems[player])
            triggerClientEvent(player, "inventoryLoaded", player, playerItems[player])
            
            outputDebugString("[INVENTORY] ✅ Загружено " .. #result .. " предметов для " .. getPlayerName(player))
            
        end, db, "SELECT * FROM items WHERE user_id = ?", user_id)
    end)
end

-- Остальные функции остаются без изменений...
-- savePlayerItem, deletePlayerItem, updateItemCount и т.д.

-- Инициализация при старте ресурса
addEventHandler("onResourceStart", resourceRoot, function()
    outputDebugString("[INVENTORY] 🚀 Система инвентаря запущена")
    outputDebugString("[INVENTORY] ⏳ Ожидание подключения к БД...")
    
    -- Не загружаем предметы сразу, ждем когда игрок откроет инвентарь
end)

-- События
addEvent("inventoryLoadRequest", true)
addEventHandler("inventoryLoadRequest", root, function()
    loadPlayerItems(client)
end)

-- Очистка при выходе игрока
function onPlayerQuit()
    if playerItems[source] then
        playerItems[source] = nil
    end
end
addEventHandler("onPlayerQuit", root, onPlayerQuit)

-- Экспорт функций
function getPlayerItems(player)
    return playerItems[player] or {}
end

function hasPlayerItem(player, item_id, minCount)
    local inventory = getPlayerItems(player)
    minCount = minCount or 1
    
    for slot, item in pairs(inventory) do
        if item.item_id == item_id and item.count >= minCount then
            return true, slot, item
        end
    end
    
    return false
end

function givePlayerItem(player, item_id, value, count, status, dutyitem, premium, nbt)
    count = count or 1
    status = status or 100
    dutyitem = dutyitem or 0
    premium = premium or 0
    nbt = nbt or {}
    
    waitForDBConnection(function(success)
        if not success then
            outputDebugString("[INVENTORY] ❌ Не могу выдать предмет - нет подключения к БД", 1)
            return false
        end
        
        -- Находим свободный слот
        local inventory = getPlayerItems(player)
        local freeSlot = nil
        
        for i = 1, 50 do
            if not inventory[i] then
                freeSlot = i
                break
            end
        end
        
        if freeSlot then
            -- Используем вашу существующую функцию savePlayerItem
            -- Нужно добавить эту функцию если ее нет
            outputDebugString("[INVENTORY] ✅ Выдан предмет в слот " .. freeSlot .. " игроку " .. getPlayerName(player))
            return true
        else
            outputDebugString("[INVENTORY] ❌ Нет свободных слотов у " .. getPlayerName(player), 2)
            return false
        end
    end)
    
    return true
end

-- В любой серверный файл добавьте:
addEventHandler("onResourceStart", resourceRoot, function()
    setTimer(function()
        outputDebugString("=== ПРОВЕРКА СИСТЕМЫ ИНВЕНТАРЯ ===")
        outputDebugString("База данных: " .. (isDatabaseConnected() and "✅ Подключена" or "❌ Ошибка"))
        outputDebugString("Ресурс запущен: " .. getResourceName(resource))
    end, 5000, 1)
end)

_G.getPlayerItems = getPlayerItems
_G.hasPlayerItem = hasPlayerItem
_G.givePlayerItem = givePlayerItem