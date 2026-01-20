-- Mad Max RP - Inventory Server Logic

local PlayerInventories = {} -- Кэш инвентарей игроков [source] = {items = {}, weight = 0}

-- ══════════════════════════════════════════════════════════
-- Утилиты
-- ══════════════════════════════════════════════════════════

-- Получение веса инвентаря
local function CalculateInventoryWeight(items)
    local weight = 0.0
    for _, item in pairs(items) do
        local itemData = Config.Items[item.name]
        if itemData then
            weight = weight + (itemData.weight * item.count)
        end
    end
    return weight
end

-- ══════════════════════════════════════════════════════════
-- Основные функции (Exports)
-- ══════════════════════════════════════════════════════════

-- Загрузка инвентаря игрока при входе
local function LoadPlayerInventory(source)
    local playerId = exports['apo_player']:GetPlayerIdentifier(source) -- Предполагаем, что такой экспорт есть
    if not playerId then return end

    local results = MySQL.query.await('SELECT item_name, count, metadata FROM apo_inventory WHERE owner_id = ? AND owner_type = "player"', {playerId})
    
    local inventory = {}
    for _, row in ipairs(results) do
        inventory[row.item_name] = {
            name = row.item_name,
            count = row.count,
            metadata = row.metadata and json.decode(row.metadata) or nil,
            label = Config.Items[row.item_name] and Config.Items[row.item_name].label or row.item_name
        }
    end

    PlayerInventories[source] = {
        items = inventory,
        weight = CalculateInventoryWeight(inventory)
    }

    if GetConvar('apo_debug', 'false') == 'true' then
        print(string.format('[APO_INVENTORY] Инвентарь загружен для %s (Вес: %.1f)', source, PlayerInventories[source].weight))
    end
end

-- Сохранение инвентаря игрока
local function SavePlayerInventory(source)
    local playerId = exports['apo_player']:GetPlayerIdentifier(source)
    local inventory = PlayerInventories[source]
    if not playerId or not inventory then return end

    -- Оптимизированное сохранение: удаляем всё и вставляем заново (или используем REPLACE INTO/ON DUPLICATE KEY)
    -- В данном случае проще удалить текущие записи игрока и вставить актуальные
    MySQL.query.await('DELETE FROM apo_inventory WHERE owner_id = ? AND owner_type = "player"', {playerId})
    
    if next(inventory.items) then
        local queryValues = {}
        for _, item in pairs(inventory.items) do
            table.insert(queryValues, {playerId, 'player', item.name, item.count, item.metadata and json.encode(item.metadata) or nil})
        end
        
        MySQL.prepare.await('INSERT INTO apo_inventory (owner_id, owner_type, item_name, count, metadata) VALUES (?, ?, ?, ?, ?)', queryValues)
    end
end

-- Добавление предмета
function addItem(source, item_name, count, metadata)
    count = count or 1
    local itemData = Config.Items[item_name]
    if not itemData then return false, "Item not found" end

    local inventory = PlayerInventories[source]
    if not inventory then return false, "Inventory not loaded" end

    -- Проверка веса
    local newWeight = inventory.weight + (itemData.weight * count)
    if newWeight > Config.MaxWeight then
        return false, "Inventory full"
    end

    if inventory.items[item_name] then
        inventory.items[item_name].count = inventory.items[item_name].count + count
    else
        inventory.items[item_name] = {
            name = item_name,
            count = count,
            metadata = metadata,
            label = itemData.label
        }
    end

    inventory.weight = newWeight
    
    -- Синхронизация с UI (если открыт) или отправка уведомления
    TriggerClientEvent('apo:inventory:update', source, inventory)
    
    return true
end

-- Удаление предмета
function removeItem(source, item_name, count)
    count = count or 1
    local inventory = PlayerInventories[source]
    if not inventory or not inventory.items[item_name] then return false, "Item not found" end

    if inventory.items[item_name].count < count then
        return false, "Not enough items"
    end

    inventory.items[item_name].count = inventory.items[item_name].count - count
    
    local itemData = Config.Items[item_name]
    inventory.weight = inventory.weight - (itemData.weight * count)

    if inventory.items[item_name].count <= 0 then
        inventory.items[item_name] = nil
    end

    TriggerClientEvent('apo:inventory:update', source, inventory)
    
    return true
end

-- Проверка наличия предмета
function hasItem(source, item_name, count)
    count = count or 1
    local inventory = PlayerInventories[source]
    if not inventory or not inventory.items[item_name] then return false end
    return inventory.items[item_name].count >= count
end

-- Получение количества предмета
function getItemCount(source, item_name)
    local inventory = PlayerInventories[source]
    if not inventory or not inventory.items[item_name] then return 0 end
    return inventory.items[item_name].count
end

-- Получение всего инвентаря
function getInventory(source)
    return PlayerInventories[source]
end

-- ══════════════════════════════════════════════════════════
-- Предметы: Использование и выбрасывание
-- ══════════════════════════════════════════════════════════

RegisterNetEvent('apo:inventory:useItem')
AddEventHandler('apo:inventory:useItem', function(itemName)
    local source = source
    local itemData = Config.Items[itemName]
    
    if not itemData then return end
    
    if hasItem(source, itemName, 1) then
        if itemData.type == 'consume' or itemData.type == 'medical' then
            -- Логика использования (например, восстановление здоровья)
            -- TriggerEvent('apo:player:useItem', source, itemName)
            
            removeItem(source, itemName, 1)
            TriggerClientEvent('apo:ui:notify', source, 'Вы использовали: ' .. itemData.label, 'success')
        else
            TriggerClientEvent('apo:ui:notify', source, 'Этот предмет нельзя использовать напрямую', 'warning')
        end
    end
end)

RegisterNetEvent('apo:inventory:dropItem')
AddEventHandler('apo:inventory:dropItem', function(itemName)
    local source = source
    local itemData = Config.Items[itemName]
    
    if not itemData then return end
    
    if hasItem(source, itemName, 1) then
        removeItem(source, itemName, 1)
        TriggerClientEvent('apo:ui:notify', source, 'Вы выбросили: ' .. itemData.label, 'info')
        
        -- TODO: Создать объект на земле (дроп)
    end
end)

-- ══════════════════════════════════════════════════════════
-- События
-- ══════════════════════════════════════════════════════════

RegisterNetEvent('apo:player:loaded') -- Предполагаем, что apo_player триггерит это событие
AddEventHandler('apo:player:loaded', function()
    local source = source
    LoadPlayerInventory(source)
end)

AddEventHandler('playerDropped', function(reason)
    local source = source
    SavePlayerInventory(source)
    PlayerInventories[source] = nil
end)

-- Периодическое сохранение
Citizen.CreateThread(function()
    while true do
        Wait(Config.SaveInterval * 60000)
        for source, _ in pairs(PlayerInventories) do
            SavePlayerInventory(source)
        end
    end
end)

-- ══════════════════════════════════════════════════════════
-- Команды (Debug)
-- ══════════════════════════════════════════════════════════

if GetConvar('apo_debug', 'false') == 'true' then
    RegisterCommand('additem', function(source, args)
        local item = args[1]
        local count = tonumber(args[2]) or 1
        local success, err = addItem(source, item, count)
        if success then
            print(string.format('Предмет %s (%d) добавлен игроку %d', item, count, source))
        else
            print(string.format('Ошибка добавления предмета: %s', err))
        end
    end, true)
end

