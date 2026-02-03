local function getThreatLevel()
    if GetResourceState('apo_invasion') ~= 'started' then
        return 0
    end
    local ok, level = pcall(function()
        return exports['apo_invasion']:GetThreatLevel()
    end)
    if ok and type(level) == 'number' then
        return level
    end
    return 0
end

local function getPlayerFaction(source)
    if GetResourceState('apo_reputation') ~= 'started' then
        return nil
    end
    local ok, faction = pcall(function()
        return exports['apo_reputation']:GetPlayerFaction(source)
    end)
    if ok then
        return faction
    end
    return nil
end

local function getBuyMultiplier(factionId)
    if factionId == 'scientist' then
        return 0.9
    end
    return 1.0
end

local function getSellMultiplier(factionId)
    if factionId == 'colonist' then
        return 1.1
    end
    return 1.0
end

local function buildShopData(source)
    local threatLevel = getThreatLevel()
    local factionId = getPlayerFaction(source)
    local buyMult = getBuyMultiplier(factionId)
    local sellMult = getSellMultiplier(factionId)

    local items = {}
    for _, item in ipairs(Config.Items) do
        local price = math.floor(item.basePrice * (1 + threatLevel * Config.PriceMultiplier) * buyMult)
        local sellPrice = math.floor(item.basePrice * Config.SellMultiplier * sellMult)
        table.insert(items, {
            name = item.name,
            label = item.label,
            price = price,
            sellPrice = sellPrice
        })
    end

    local currency = exports['apo_inventory']:getItemCount(source, Config.CurrencyItem)
    return {
        items = items,
        currency = currency,
        threat = threatLevel
    }
end

RegisterNetEvent('apo:economy:openShop', function()
    local source = source
    TriggerClientEvent('apo:economy:openShop', source, buildShopData(source))
end)

RegisterNetEvent('apo:economy:buyItem', function(itemName, count)
    local source = source
    count = tonumber(count) or 1
    if count <= 0 then return end

    local shopData = buildShopData(source)
    local itemData = nil
    for _, item in ipairs(shopData.items) do
        if item.name == itemName then
            itemData = item
            break
        end
    end
    if not itemData then
        TriggerClientEvent('apo:ui:notify', source, 'Товар не найден', 'error')
        return
    end

    local totalPrice = itemData.price * count
    if not exports['apo_inventory']:hasItem(source, Config.CurrencyItem, totalPrice) then
        TriggerClientEvent('apo:ui:notify', source, 'Недостаточно кредитов', 'warning')
        return
    end

    exports['apo_inventory']:removeItem(source, Config.CurrencyItem, totalPrice)
    local ok, err = exports['apo_inventory']:addItem(source, itemName, count)
    if not ok then
        exports['apo_inventory']:addItem(source, Config.CurrencyItem, totalPrice)
        TriggerClientEvent('apo:ui:notify', source, 'Инвентарь переполнен', 'error')
        return
    end

    TriggerClientEvent('apo:ui:notify', source, 'Покупка завершена', 'success')
    TriggerClientEvent('apo:economy:updateShop', source, buildShopData(source))
end)

RegisterNetEvent('apo:economy:sellItem', function(itemName, count)
    local source = source
    count = tonumber(count) or 1
    if count <= 0 then return end

    local shopData = buildShopData(source)
    local itemData = nil
    for _, item in ipairs(shopData.items) do
        if item.name == itemName then
            itemData = item
            break
        end
    end
    if not itemData then
        TriggerClientEvent('apo:ui:notify', source, 'Товар не найден', 'error')
        return
    end

    if not exports['apo_inventory']:hasItem(source, itemName, count) then
        TriggerClientEvent('apo:ui:notify', source, 'Нет предметов для продажи', 'warning')
        return
    end

    exports['apo_inventory']:removeItem(source, itemName, count)
    exports['apo_inventory']:addItem(source, Config.CurrencyItem, itemData.sellPrice * count)

    TriggerClientEvent('apo:ui:notify', source, 'Продажа завершена', 'success')
    TriggerClientEvent('apo:economy:updateShop', source, buildShopData(source))
end)

