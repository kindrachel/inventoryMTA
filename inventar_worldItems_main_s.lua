-- inventar_worldItems_main_s.lua
local connection = nil
local worldItems = {}

function getDBConnection()
    if not connection then
        connection = exports.inv2:getConnection()
    end
    return connection
end

function loadWorldItems()
    local db = getDBConnection()
    if not db then
        outputDebugString("[WORLDITEMS] ❌ Нет подключения к БД", 1)
        return false
    end
    
    -- Сначала создаем таблицу если не существует
    dbExec(db, [[
        CREATE TABLE IF NOT EXISTS world_items (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            position TEXT NOT NULL,
            item_data TEXT NOT NULL,
            created_at DATETIME DEFAULT CURRENT_TIMESTAMP
        )
    ]])
    
    -- Затем загружаем предметы
    local query = dbQuery(db, "SELECT * FROM world_items")
    if not query then
        outputDebugString("[WORLDITEMS] ❌ Ошибка запроса к world_items", 1)
        return false
    end
    
    local items = dbPoll(query, -1)
    if not items then
        outputDebugString("[WORLDITEMS] ✅ Таблица world_items пуста")
        return true
    end
    
    local loadedCount = 0
    for i, row in ipairs(items) do
        local success, positionData = pcall(fromJSON, row.position)
        local success2, itemData = pcall(fromJSON, row.item_data)
        
        if success and success2 and positionData and itemData then
            if createWorldItemObject(row.id, positionData, itemData) then
                loadedCount = loadedCount + 1
            end
        else
            outputDebugString("[WORLDITEMS] ❌ Ошибка парсинга данных предмета #" .. row.id, 1)
        end
    end
    
    outputDebugString("[WORLDITEMS] ✅ Загружено " .. loadedCount .. " мировых предметов")
    return true
end


-- Создание таблицы если не существует
function createWorldItemsTable()
    local db = getDBConnection()
    if not db then return end
    
    dbExec(db, [[
        CREATE TABLE IF NOT EXISTS world_items (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            position TEXT NOT NULL,
            item_data TEXT NOT NULL,
            created_at DATETIME DEFAULT CURRENT_TIMESTAMP
        )
    ]])
    
    outputDebugString("[WORLDITEMS] ✅ Таблица world_items создана")
end

-- Создание объекта мирового предмета
function createWorldItemObject(itemId, position, itemData)
    if not position or not position.x or not position.y or not position.z then
        outputDebugString("[WORLDITEMS] ❌ Неверные координаты позиции для предмета #" .. tostring(itemId), 1)
        return false
    end
    
    local x, y, z = position.x, position.y, position.z
    local rx, ry, rz = position.rx or 0, position.ry or 0, position.rz or 0
    local interior = position.interior or 0
    local dimension = position.dimension or 0
    
    -- Используем стандартный объект если не указан
    local objectId = itemData.object_id or 1271
    
    local object = createObject(objectId, x, y, z, rx, ry, rz)
    
    if not object then
        outputDebugString("[WORLDITEMS] ❌ Не удалось создать объект для предмета #" .. tostring(itemId), 1)
        return false
    end
    
    -- Устанавливаем интерьер и измерение
    setElementInterior(object, interior)
    setElementDimension(object, dimension)
    
    -- Устанавливаем данные
    setElementData(object, "worldItem.id", itemId)
    setElementData(object, "worldItem.data", itemData)
    setElementData(object, "worldItem.pickupable", true)
    
    worldItems[itemId] = object
    
    -- Создаем коллизию
    if createPickupCollision(object) then
        outputDebugString("[WORLDITEMS] ✅ Создан мировой предмет #" .. tostring(itemId))
        return object
    else
        outputDebugString("[WORLDITEMS] ❌ Ошибка создания коллизии для предмета #" .. tostring(itemId), 1)
        if isElement(object) then
            destroyElement(object)
        end
        return false
    end
end

-- Создание коллизии для пикапа
function createPickupCollision(object)
    local colshape = createColSphere(0, 0, 0, 1.5)
    attachElements(colshape, object, 0, 0, 0)
    
    setElementData(colshape, "worldItem.parent", object)
    
    addEventHandler("onColShapeHit", colshape, function(hitElement)
        if getElementType(hitElement) == "player" then
            triggerClientEvent(hitElement, "worldItemShowPickup", hitElement, object)
        end
    end)
    
    addEventHandler("onColShapeLeave", colshape, function(hitElement)
        if getElementType(hitElement) == "player" then
            triggerClientEvent(hitElement, "worldItemHidePickup", hitElement)
        end
    end)
end

-- Создание нового мирового предмета
function createWorldItem(player, itemData, x, y, z)
    local db = getDBConnection()
    if not db then return false end
    
    local rx, ry, rz = 0, 0, 0
    local interior = getElementInterior(player)
    local dimension = getElementDimension(player)
    
    local position = {
        x = x, y = y, z = z,
        rx = rx, ry = ry, rz = rz,
        interior = interior, dimension = dimension
    }
    
    dbQuery(function(qh)
        local result, num_affected, last_id = dbPoll(qh, 0)
        if not result then
            outputDebugString("[WORLDITEMS] ❌ Ошибка создания мирового предмета", 1)
            return
        end
        
        if createWorldItemObject(last_id, position, itemData) then
            outputDebugString("[WORLDITEMS] ✅ Создан мировой предмет #" .. last_id)
            
            if isElement(player) then
                outputChatBox("Вы выбросили предмет на землю", player, 0, 255, 0)
            end
        end
        
    end, db, "INSERT INTO world_items (position, item_data) VALUES (?, ?)", 
        toJSON(position), toJSON(itemData))
    
    return true
end

-- Подбор мирового предмета
function pickupWorldItem(player, worldItemId)
    local db = getDBConnection()
    if not db then return false end
    
    local object = worldItems[worldItemId]
    if not isElement(object) then return false end
    
    local itemData = getElementData(object, "worldItem.data")
    if not itemData then return false end
    
    -- Используем функцию из inventar_main_s.lua
    if exports.inv2:givePlayerItem(player, itemData.item_id, itemData.value, itemData.count, itemData.status, itemData.dutyitem, itemData.premium, itemData.nbt) then
        dbQuery(function(qh)
            local result, num_affected = dbPoll(qh, 0)
            if result and num_affected > 0 then
                if isElement(object) then
                    destroyElement(object)
                end
                worldItems[worldItemId] = nil
                
                outputDebugString("[WORLDITEMS] ✅ Игрок " .. getPlayerName(player) .. " подобрал предмет #" .. worldItemId)
                outputChatBox("Вы подобрали предмет", player, 0, 255, 0)
            end
        end, db, "DELETE FROM world_items WHERE id = ?", worldItemId)
        
        return true
    else
        outputChatBox("Недостаточно места в инвентаре", player, 255, 0, 0)
        return false
    end
end

-- В функции инициализации измените таймер:
addEventHandler("onResourceStart", resourceRoot, function()
    outputDebugString("[WORLDITEMS] 🚀 Запуск системы мировых предметов...")
    
    -- УВЕЛИЧЬТЕ задержку с 3000 до 5000 мс
    setTimer(function()
        if getDBConnection() then
            loadWorldItems()
        else
            outputDebugString("[WORLDITEMS] ⏳ Ожидание подключения к БД...", 2)
        end
    end, 7000, 1)  -- Было 3000, стало 5000
end)

-- Экспорт функций
_G.createWorldItem = createWorldItem
_G.pickupWorldItem = pickupWorldItem

-- События
addEvent("worldItemCreate", true)
addEventHandler("worldItemCreate", root, function(itemData, x, y, z)
    if createWorldItem(client, itemData, x, y, z) then
        triggerClientEvent(client, "worldItemCreateSuccess", client)
    else
        triggerClientEvent(client, "worldItemCreateError", client)
    end
end)

addEvent("worldItemPickup", true)
addEventHandler("worldItemPickup", root, function(worldItemId)
    if pickupWorldItem(client, worldItemId) then
        triggerClientEvent(client, "worldItemPickupSuccess", client)
    else
        triggerClientEvent(client, "worldItemPickupError", client)
    end
end)

-- Экспорт функций
_G.createWorldItem = createWorldItem
_G.pickupWorldItem = pickupWorldItem

-- Добавьте в конец файла:
addCommandHandler("testworlditem", function(player)
    local x, y, z = getElementPosition(player)
    
    local testItem = {
        item_id = 1,
        value = "Test Item",
        count = 1,
        status = 100,
        dutyitem = 0,
        premium = 0,
        nbt = {name = "Тестовый предмет"},
        object_id = 1271
    }
    
    if createWorldItem(player, testItem, x + 2, y, z - 1) then
        outputChatBox("✅ Тестовый предмет создан!", player, 0, 255, 0)
    else
        outputChatBox("❌ Ошибка создания предмета", player, 255, 0, 0)
    end
end)