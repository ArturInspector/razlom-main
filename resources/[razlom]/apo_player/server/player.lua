local Database = require 'server.database'
local Logger = exports['apo_core']

local Players = {}
local PlayerCache = {}

function Players.getIdentifier(source)
    local identifiers = GetPlayerIdentifiers(source)
    for _, identifier in ipairs(identifiers) do
        if string.match(identifier, 'license:') then
            return identifier
        end
    end
    return nil
end

function Players.load(source)
    local identifier = Players.getIdentifier(source)
    if not identifier then
        Logger.error('Failed to get identifier for source: ' .. source)
        return nil
    end
    
    local playerData = Database.getPlayerByIdentifier(identifier)
    
    if not playerData then
        local playerName = GetPlayerName(source)
        local playerId = Database.createPlayer(identifier, playerName)
        if playerId then
            playerData = Database.getPlayerData(playerId)
            Logger.info('Created new player: ' .. playerName .. ' (ID: ' .. playerId .. ')')
        else
            Logger.error('Failed to create player: ' .. playerName)
            return nil
        end
    end
    
    PlayerCache[source] = playerData
    TriggerClientEvent('apo:player:loaded', source, playerData)
    Logger.info('Player loaded: ' .. playerData.name .. ' (ID: ' .. playerData.id .. ')')
    
    return playerData
end

function Players.get(source)
    return PlayerCache[source]
end

function Players.set(source, key, value)
    local player = PlayerCache[source]
    if not player then return false end
    
    player[key] = value
    Database.updatePlayer(player.id, {[key] = value})
    return true
end

function Players.remove(source)
    if PlayerCache[source] then
        Database.updatePlayer(PlayerCache[source].id, PlayerCache[source])
        PlayerCache[source] = nil
    end
end

function Players.getPlayerClass(source)
    local player = PlayerCache[source]
    if not player then return nil end
    return player.class
end

AddEventHandler('playerConnecting', function(name, setKickReason, deferrals)
    local source = source
    deferrals.defer()
    Wait(100)
    Players.load(source)
    deferrals.done()
end)

RegisterNetEvent('apo:player:updatePosition', function(coords)
    local source = source
    local player = PlayerCache[source]
    if player then
        player.position = json.encode(coords)
        Database.updatePlayer(player.id, {position = player.position})
    end
end)

Citizen.CreateThread(function()
    while true do
        Wait(300000)
        for source, player in pairs(PlayerCache) do
            if GetPlayerPing(source) > 0 then
                Database.updatePlayer(player.id, player)
            end
        end
    end
end)

AddEventHandler('playerDropped', function()
    local source = source
    Players.remove(source)
end)

exports('getPlayerData', function(source)
    return Players.get(source)
end)

exports('setPlayerData', function(source, key, value)
    return Players.set(source, key, value)
end)

exports('getPlayerClass', function(source)
    return Players.getPlayerClass(source)
end)

return Players

