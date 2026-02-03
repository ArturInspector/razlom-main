local playerFactions = {}

local function getPlayerRank(source)
    if GetResourceState('apo_progression') ~= 'started' then
        return 1
    end
    local ok, rank = pcall(function()
        return exports['apo_progression']:GetPlayerRank(source)
    end)
    if ok and type(rank) == 'number' then
        return rank
    end
    return 1
end

local function getFactionById(id)
    for _, faction in ipairs(Config.Factions) do
        if faction.id == id then
            return faction
        end
    end
    return nil
end

RegisterNetEvent('apo:player:loaded')
AddEventHandler('apo:player:loaded', function(playerData)
    local source = source
    if playerData and playerData.faction then
        playerFactions[source] = playerData.faction
    end
end)

RegisterNetEvent('apo:reputation:openMenu', function()
    local source = source
    local rank = getPlayerRank(source)
    if rank < Config.RequiredRank then
        TriggerClientEvent('apo:ui:notify', source, 'Фракции доступны с ранга 3', 'warning')
        return
    end

    if playerFactions[source] then
        TriggerClientEvent('apo:ui:notify', source, 'Фракция уже выбрана', 'info')
        return
    end

    TriggerClientEvent('apo:reputation:openMenu', source, Config.Factions)
end)

RegisterNetEvent('apo:reputation:chooseFaction', function(factionId)
    local source = source
    local faction = getFactionById(factionId)
    if not faction then
        TriggerClientEvent('apo:ui:notify', source, 'Фракция не найдена', 'error')
        return
    end

    if playerFactions[source] then
        TriggerClientEvent('apo:ui:notify', source, 'Фракция уже выбрана', 'info')
        return
    end

    local rank = getPlayerRank(source)
    if rank < Config.RequiredRank then
        TriggerClientEvent('apo:ui:notify', source, 'Фракции доступны с ранга 3', 'warning')
        return
    end

    playerFactions[source] = factionId
    if GetResourceState('apo_player') == 'started' then
        exports['apo_player']:setPlayerData(source, 'faction', factionId)
    end

    TriggerClientEvent('apo:reputation:factionSelected', source, faction)
    TriggerClientEvent('apo:ui:notify', source, 'Фракция выбрана: ' .. faction.label, 'success')
end)

AddEventHandler('playerDropped', function()
    local source = source
    playerFactions[source] = nil
end)

exports('GetPlayerFaction', function(source)
    return playerFactions[source]
end)

