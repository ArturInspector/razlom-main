local playerData = nil
local hasSpawned = false

local function getSpawnPoint()
    if not Config.SpawnPoints or #Config.SpawnPoints == 0 then
        return nil
    end

    -- Предпочитаем безопасную зону колонии
    for _, point in ipairs(Config.SpawnPoints) do
        if point.type == 'colony' then
            return point
        end
    end

    return Config.SpawnPoints[1]
end

local function spawnPlayerIfNeeded()
    if hasSpawned then return end
    local spawn = getSpawnPoint()
    if not spawn then return end

    local ped = PlayerPedId()
    RequestCollisionAtCoord(spawn.coords.x, spawn.coords.y, spawn.coords.z)
    SetEntityCoordsNoOffset(ped, spawn.coords.x, spawn.coords.y, spawn.coords.z, false, false, false)
    SetEntityHeading(ped, spawn.heading or 0.0)
    hasSpawned = true
end

RegisterNetEvent('apo:player:loaded', function(data)
    playerData = data
    spawnPlayerIfNeeded()
end)

Citizen.CreateThread(function()
    while true do
        Wait(5000)
        if playerData then
            local coords = GetEntityCoords(PlayerPedId())
            TriggerServerEvent('apo:player:updatePosition', coords)
        end
    end
end)

exports('getPlayerData', function()
    return playerData
end)
