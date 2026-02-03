local playerZones = {}

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

local function distance(a, b)
    return #(vector3(a.x, a.y, a.z) - vector3(b.x, b.y, b.z))
end

local function resolveZone(coords, threatLevel)
    for _, node in ipairs(Config.Nodes) do
        if distance(coords, node.coords) <= node.radius then
            return {
                id = node.id,
                name = node.name,
                type = 'node',
                threat_bonus = node.threat_bonus or 0
            }
        end
    end

    local distToColony = distance(coords, Config.Colony.coords)
    if distToColony <= Config.Colony.radius then
        return {
            name = Config.Colony.name,
            type = 'colony'
        }
    end

    if distToColony <= Config.Perimeter.outer then
        return {
            name = Config.Perimeter.name,
            type = 'perimeter',
            dangerous = threatLevel >= Config.Threat.perimeter_danger_level
        }
    end

    return {
        name = Config.Wild.name,
        type = 'wild'
    }
end

local function updatePlayerZone(source)
    local ped = GetPlayerPed(source)
    if not ped or ped == 0 then return end

    local coords = GetEntityCoords(ped)
    local threatLevel = getThreatLevel()
    local zone = resolveZone(coords, threatLevel)

    local prev = playerZones[source]
    local changed = not prev or prev.type ~= zone.type or prev.name ~= zone.name or prev.dangerous ~= zone.dangerous
    if changed then
        playerZones[source] = zone
        TriggerClientEvent('apo:zones:zoneChanged', source, zone, threatLevel)
    end
end

CreateThread(function()
    Wait(2000)
    while true do
        for _, source in ipairs(GetPlayers()) do
            updatePlayerZone(tonumber(source))
        end
        Wait(Config.ZoneCheckInterval)
    end
end)

RegisterNetEvent('apo:zones:getZone', function()
    local source = source
    local zone = playerZones[source]
    if not zone then
        updatePlayerZone(source)
        zone = playerZones[source]
    end
    TriggerClientEvent('apo:zones:zoneChanged', source, zone, getThreatLevel())
end)

AddEventHandler('playerDropped', function()
    local source = source
    playerZones[source] = nil
end)

exports('GetPlayerZone', function(source)
    return playerZones[source]
end)

