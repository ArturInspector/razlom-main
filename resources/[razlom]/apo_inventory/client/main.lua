-- Mad Max RP - Inventory Client Logic

local inventoryData = {items = {}, weight = 0.0}
local isInventoryOpen = false

-- ══════════════════════════════════════════════════════════
-- Функции
-- ══════════════════════════════════════════════════════════

-- Открытие инвентаря
local function OpenInventory()
    if isInventoryOpen then return end
    
    isInventoryOpen = true
    
    -- Преобразуем данные для UI (превращаем словарь в массив)
    local uiItems = {}
    for _, item in pairs(inventoryData.items) do
        local configData = Config.Items[item.name]
        table.insert(uiItems, {
            name = item.name,
            label = item.label,
            count = item.count,
            weight = configData and configData.weight or 0,
            description = configData and configData.description or ""
        })
    end

    exports['apo_ui']:OpenMenu('inventory', {
        items = uiItems,
        weight = inventoryData.weight,
        maxWeight = Config.MaxWeight
    })
    
    if GetConvar('apo_debug', 'false') == 'true' then
        print('[APO_INVENTORY] Инвентарь открыт')
    end
end

-- Закрытие инвентаря
local function CloseInventory()
    isInventoryOpen = false
    exports['apo_ui']:CloseMenu()
end

-- ══════════════════════════════════════════════════════════
-- События
-- ══════════════════════════════════════════════════════════

-- Обновление данных инвентаря от сервера
RegisterNetEvent('apo:inventory:update')
AddEventHandler('apo:inventory:update', function(data)
    inventoryData = data
    
    -- Если инвентарь открыт, обновляем UI
    if isInventoryOpen then
        local uiItems = {}
        for _, item in pairs(inventoryData.items) do
            local configData = Config.Items[item.name]
            table.insert(uiItems, {
                name = item.name,
                label = item.label,
                count = item.count,
                weight = configData and configData.weight or 0,
                description = configData and configData.description or ""
            })
        end

        SendNUIMessage({
            action = 'updateMenu',
            menuType = 'inventory',
            data = {
                items = uiItems,
                weight = inventoryData.weight,
                maxWeight = Config.MaxWeight
            }
        })
    end

    -- Также обновляем HUD (вес)
    exports['apo_ui']:UpdateHUD({
        weight = inventoryData.weight,
        maxWeight = Config.MaxWeight
    })
end)

-- ══════════════════════════════════════════════════════════
-- Основной цикл
-- ══════════════════════════════════════════════════════════

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        
        -- Проверка нажатия клавиши открытия инвентаря
        if IsControlJustReleased(0, Config.OpenKey) then
            if isInventoryOpen then
                CloseInventory()
            else
                OpenInventory()
            end
        end

        -- Если инвентарь открыт, отключаем некоторые игровые действия
        if isInventoryOpen then
            DisableControlAction(0, 1, true) -- LookLeftRight
            DisableControlAction(0, 2, true) -- LookUpDown
            DisableControlAction(0, 24, true) -- Attack
            DisableControlAction(0, 142, true) -- Attack2
            DisableControlAction(0, 106, true) -- VehicleMouseControlOverride
        end
    end
end)

-- Обработка закрытия из NUI
RegisterNetEvent('apo:ui:closed')
AddEventHandler('apo:ui:closed', function(menuType)
    if menuType == 'inventory' then
        isInventoryOpen = false
    end
end)










