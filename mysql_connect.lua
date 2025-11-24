-- mysql_connect.lua
local connection = nil

function connectToDatabase()
    -- Используем SQLite
    local db = dbConnect("sqlite", ":/inv2.db")
    
    if db then
        outputDebugString("[SQLite] ✅ База данных подключена успешно!")
        connection = db
        createTables()
        return true
    else
        outputDebugString("[SQLite] ❌ Ошибка подключения к базе данных", 1)
        return false
    end
end

function createTables()
    if not connection then return end
    
    outputDebugString("[SQLite] 🔧 Начинаем создание таблиц...")
    
    -- Сначала принудительно создаем таблицы через код
    createMinimalTables()
    
    -- Затем пытаемся выполнить SQL файл если есть (для индексов и доп. структур)
    if fileExists("inventar.sql") then
        outputDebugString("[SQLite] 📁 Найден inventar.sql, выполняем...")
        local sqlFile = fileOpen("inventar.sql")
        if sqlFile then
            local sqlContent = fileRead(sqlFile, fileGetSize(sqlFile))
            fileClose(sqlFile)
            
            -- Разделяем SQL на отдельные запросы
            local queries = {}
            for query in sqlContent:gmatch("[^;]+") do
                local trimmedQuery = query:gsub("^%s+", ""):gsub("%s+$", "")
                if trimmedQuery ~= "" and not trimmedQuery:match("^%-%-") then
                    table.insert(queries, trimmedQuery)
                end
            end
            
            -- Выполняем запросы
            local successCount = 0
            for i, query in ipairs(queries) do
                if dbExec(connection, query) then
                    successCount = successCount + 1
                else
                    outputDebugString("[SQLite] ❌ Ошибка SQL (" .. i .. "): " .. query:sub(1, 100), 1)
                end
            end
            
            outputDebugString("[SQLite] ✅ Дополнительные запросы: " .. successCount .. "/" .. #queries)
        end
    else
        outputDebugString("[SQLite] ❌ Файл inventar.sql не найден", 1)
    end
    
    -- Проверяем что таблицы создались
    checkAllTables()
end

function createMinimalTables()
    outputDebugString("[SQLite] 🔧 Создаем основные таблицы...")
    
    local tables = {
        [[CREATE TABLE IF NOT EXISTS inventarinhalt (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id INTEGER NOT NULL,
            slot INTEGER NOT NULL,
            item_id INTEGER NOT NULL,
            count INTEGER DEFAULT 1,
            value TEXT,
            status INTEGER DEFAULT 100,
            dutyitem INTEGER DEFAULT 0,
            premium INTEGER DEFAULT 0,
            nbt TEXT,
            created_at DATETIME DEFAULT CURRENT_TIMESTAMP
        )]],
        
        [[CREATE TABLE IF NOT EXISTS world_items (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            position TEXT NOT NULL,
            item_data TEXT NOT NULL,
            created_at DATETIME DEFAULT CURRENT_TIMESTAMP
        )]],
        
        [[CREATE TABLE IF NOT EXISTS items (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id INTEGER NOT NULL,
            slot INTEGER NOT NULL,
            item_id INTEGER NOT NULL,
            value TEXT,
            count INTEGER DEFAULT 1,
            status INTEGER DEFAULT 100,
            dutyitem INTEGER DEFAULT 0,
            premium INTEGER DEFAULT 0,
            nbt TEXT,
            created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
            UNIQUE(user_id, slot)
        )]]
    }
    
    for i, query in ipairs(tables) do
        if dbExec(connection, query) then
            outputDebugString("[SQLite] ✅ Таблица создана: " .. i)
        else
            outputDebugString("[SQLite] ❌ Ошибка создания таблицы: " .. i, 1)
        end
    end
end

function checkAllTables()
    outputDebugString("[SQLite] 🔍 Проверяем существование таблиц...")
    
    local tablesToCheck = {"inventarinhalt", "world_items", "items"}
    
    for _, tableName in ipairs(tablesToCheck) do
        local query = dbQuery(connection, "SELECT name FROM sqlite_master WHERE type='table' AND name=?", tableName)
        if query then
            local result = dbPoll(query, -1)
            if result and #result > 0 then
                outputDebugString("[SQLite] ✅ Таблица " .. tableName .. " существует")
                
                -- Проверим структуру таблицы
                checkTableStructure(tableName)
            else
                outputDebugString("[SQLite] ❌ Таблица " .. tableName .. " НЕ существует", 1)
            end
        else
            outputDebugString("[SQLite] ❌ Ошибка запроса для таблицы " .. tableName, 1)
        end
    end
end

function checkTableStructure(tableName)
    local query = dbQuery(connection, "PRAGMA table_info(" .. tableName .. ")")
    if query then
        local columns = dbPoll(query, -1)
        if columns then
            outputDebugString("[SQLite] Структура таблицы " .. tableName .. ":")
            for _, col in ipairs(columns) do
                outputDebugString("  - " .. col.name .. " (" .. col.type .. ")")
            end
        end
    end
end

function checkTableExists(tableName)
    local query = dbQuery(connection, "SELECT name FROM sqlite_master WHERE type='table' AND name=?", tableName)
    if query then
        local result = dbPoll(query, -1)
        if result and #result > 0 then
            outputDebugString("[SQLite] ✅ Таблица " .. tableName .. " существует")
            return true
        else
            outputDebugString("[SQLite] ❌ Таблица " .. tableName .. " не существует", 1)
            return false
        end
    end
    return false
end

function checkTableStructure()
    local query = dbQuery(connection, "PRAGMA table_info(inventarinhalt)")
    if query then
        local columns = dbPoll(query, -1)
        if columns then
            outputDebugString("[SQLite] Структура таблицы inventarinhalt:")
            for _, col in ipairs(columns) do
                outputDebugString("  " .. col.name .. " (" .. col.type .. ")")
            end
        end
    end
end

function createMinimalTables()
    outputDebugString("[SQLite] Создаем минимальные таблицы...")
    
    local tables = {
        -- Таблица items (основная)
        [[CREATE TABLE IF NOT EXISTS items (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id INTEGER NOT NULL,
            slot INTEGER NOT NULL,
            item_id INTEGER NOT NULL,
            value TEXT,
            count INTEGER DEFAULT 1,
            status INTEGER DEFAULT 100,
            dutyitem INTEGER DEFAULT 0,
            premium INTEGER DEFAULT 0,
            nbt TEXT,
            created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
            UNIQUE(user_id, slot)
        )]],
        
        -- Таблица world_items
        [[CREATE TABLE IF NOT EXISTS world_items (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            position TEXT NOT NULL,
            item_data TEXT NOT NULL,
            created_at DATETIME DEFAULT CURRENT_TIMESTAMP
        )]],
        
        -- Таблица inventarinhalt (для совместимости)
        [[CREATE TABLE IF NOT EXISTS inventarinhalt (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id INTEGER NOT NULL,
            slot INTEGER NOT NULL,
            item_id INTEGER NOT NULL,
            count INTEGER DEFAULT 1,
            value TEXT,
            status INTEGER DEFAULT 100,
            dutyitem INTEGER DEFAULT 0,
            premium INTEGER DEFAULT 0,
            nbt TEXT,
            created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
            UNIQUE(user_id, slot)
        )]]
    }
    
    for i, query in ipairs(tables) do
        if dbExec(connection, query) then
            outputDebugString("[SQLite] ✅ Таблица создана: " .. i)
        else
            outputDebugString("[SQLite] ❌ Ошибка создания таблицы: " .. i, 1)
        end
    end
    
    -- Создаем индексы
    local indexes = {
        "CREATE INDEX IF NOT EXISTS idx_items_user ON items(user_id)",
        "CREATE INDEX IF NOT EXISTS idx_world_items_position ON world_items(position)",
        "CREATE INDEX IF NOT EXISTS idx_inventarinhalt_user ON inventarinhalt(user_id)"
    }
    
    for i, indexQuery in ipairs(indexes) do
        if dbExec(connection, indexQuery) then
            outputDebugString("[SQLite] ✅ Индекс создан: " .. i)
        else
            outputDebugString("[SQLite] ❌ Ошибка создания индекса: " .. i, 1)
        end
    end
end

function getConnection()
    return connection
end

function isDatabaseConnected()
    return connection and true or false
end

-- Запуск при старте ресурса
addEventHandler("onResourceStart", resourceRoot, function()
    outputDebugString("[SQLite] 🚀 Запуск инвентаря...")
    setTimer(connectToDatabase, 1000, 1)
end)

-- Добавьте в mysql_connect.lua
addCommandHandler("checkdb", function(player)
    if not isDatabaseConnected() then
        outputChatBox("❌ База данных не подключена", player, 255, 0, 0)
        return
    end
    
    outputChatBox("=== ПРОВЕРКА БАЗЫ ДАННЫХ ===", player, 0, 255, 255)
    
    -- Проверим существование таблиц
    local tables = {"items", "world_items", "inventarinhalt"}
    for _, tableName in ipairs(tables) do
        local query = dbQuery(connection, "SELECT name FROM sqlite_master WHERE type='table' AND name=?", tableName)
        if query then
            local result = dbPoll(query, -1)
            if result and #result > 0 then
                outputChatBox("✅ " .. tableName .. " существует", player, 0, 255, 0)
            else
                outputChatBox("❌ " .. tableName .. " не существует", player, 255, 0, 0)
            end
        end
    end
end)

-- Добавьте в mysql_connect.lua
addCommandHandler("recreatedb", function(player)
    if not hasObjectPermissionTo(player, "command.start", false) then
        outputChatBox("❌ Недостаточно прав", player, 255, 0, 0)
        return
    end
    
    outputChatBox("🔄 Пересоздаем таблицы базы данных...", player, 255, 255, 0)
    
    if not connection then
        outputChatBox("❌ Нет подключения к БД", player, 255, 0, 0)
        return
    end
    
    -- Удаляем таблицы если существуют
    local tables = {"inventarinhalt", "world_items", "items"}
    for _, tableName in ipairs(tables) do
        dbExec(connection, "DROP TABLE IF EXISTS " .. tableName)
    end
    
    outputChatBox("✅ Старые таблицы удалены", player, 0, 255, 0)
    
    -- Создаем заново
    createMinimalTables()
    checkAllTables()
    
    outputChatBox("✅ Таблицы пересозданы", player, 0, 255, 0)
    outputDebugString("[SQLite] Таблицы пересозданы по команде от " .. getPlayerName(player))
end)

-- Экспорт функций
_G.getConnection = getConnection
_G.isDatabaseConnected = isDatabaseConnected