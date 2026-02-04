Mobs = Mobs or {}

Mobs.Director = Mobs.Director or {}

local lastActionAt = 0
local lastEventAt = {}

local function notify(target, message, messageType, duration)
    if not target or target == 0 then return end
    TriggerClientEvent('apo:ui:notify', target, message, messageType or 'info', duration)
end

local function logDebug(message)
    if Config.Director and Config.Director.debug then
        print('[MOBS][DIRECTOR] ' .. message)
    end
end

local function getThreatLevel()
    if GetResourceState('apo_invasion') ~= 'started' then
        return 0
    end

    local ok, value = pcall(function()
        return exports['apo_invasion']:GetThreatLevel()
    end)

    if ok and type(value) == 'number' then
        return value
    end

    return 0
end

local function getHotspots()
    if GetResourceState('apo_signal') ~= 'started' then
        return {}
    end

    local ok, hotspots = pcall(function()
        return exports['apo_signal']:GetHotspots()
    end)

    if ok and type(hotspots) == 'table' then
        return hotspots
    end

    return {}
end

local function getTopHotspot(hotspots)
    local best = nil
    for _, hotspot in ipairs(hotspots) do
        if not best or (hotspot.level or 0) > (best.level or 0) then
            best = hotspot
        end
    end
    return best
end

local function pickRandomPlayer()
    local players = GetPlayers()
    if #players == 0 then return nil end
    return players[math.random(1, #players)]
end

local function canRunEvent(eventName, now)
    local cooldowns = Config.Director.event_cooldowns or {}
    local cooldown = cooldowns[eventName] or 0
    local lastAt = lastEventAt[eventName] or 0
    return (now - lastAt) >= cooldown
end

local function markEvent(eventName, now)
    lastEventAt[eventName] = now
    lastActionAt = now
end

local function spawnAmbientGroup(targetSource)
    local ped = GetPlayerPed(targetSource)
    if not ped or ped == 0 then return end

    local coords = GetEntityCoords(ped)
    local count = math.random(Config.Director.ambient_spawns.min, Config.Director.ambient_spawns.max)
    for i = 1, count do
        local archetypes = Config.Director.ambient_archetypes or { 'runner' }
        local pick = archetypes[math.random(1, #archetypes)]
        if math.random() <= Config.Director.elite_spawn_chance then
            pick = 'elite'
        end
        Mobs.Spawn(coords, pick, 1, targetSource)
    end

    local note = Config.Director.notifications and Config.Director.notifications.ambient
    if note then
        notify(targetSource, note.message, note.type)
    end
end

local function spawnHotspotGroup(hotspot)
    if not hotspot or not hotspot.coords then return end

    local spawns = math.min(Config.Director.hotspot_max_spawns, math.max(1, math.floor((hotspot.level or 0) / 5)))
    for _ = 1, spawns do
        Mobs.SpawnDirected(hotspot.coords, hotspot.level or 0)
    end

    local note = Config.Director.notifications and Config.Director.notifications.hotspot
    if note then
        for _, player in ipairs(GetPlayers()) do
            notify(player, note.message, note.type)
        end
    end
end

local function startThreatWave(coords, threat, targetSource)
    if GetResourceState('apo_invasion') == 'started' then
        local tier = math.min(3, 1 + math.floor((threat or 0) / 4))
        exports['apo_invasion']:StartWave(coords, tier, targetSource)
        local note = Config.Director.notifications and Config.Director.notifications.wave
        if note then
            notify(targetSource, note.message, note.type)
        end
        return true
    end
    return false
end

CreateThread(function()
    while true do
        Wait(Config.Director.tick_ms)

        if not Config.Director.enabled then
            goto continue
        end

        if #GetPlayers() < Config.Director.min_players then
            goto continue
        end

        if Mobs.GetAliveCount() >= Config.Director.max_alive_soft then
            goto continue
        end

        local now = GetGameTimer()
        if (now - lastActionAt) < Config.Director.global_cooldown_ms then
            goto continue
        end

        if math.random() > Config.Director.base_chance then
            goto continue
        end

        local threat = getThreatLevel()
        local hotspots = getHotspots()
        local topHotspot = getTopHotspot(hotspots)
        local playerSource = pickRandomPlayer()

        if not playerSource then
            goto continue
        end

        if topHotspot and (topHotspot.level or 0) >= Config.Director.hotspot_min_level
            and canRunEvent('hotspot', now) then
            logDebug('hotspot event, level=' .. tostring(topHotspot.level))
            spawnHotspotGroup(topHotspot)
            markEvent('hotspot', now)
            goto continue
        end

        if threat >= Config.Director.wave_threat_min and canRunEvent('wave', now) then
            local ped = GetPlayerPed(playerSource)
            if ped and ped ~= 0 then
                local coords = GetEntityCoords(ped)
                if startThreatWave(coords, threat, playerSource) then
                    logDebug('wave event, threat=' .. tostring(threat))
                    markEvent('wave', now)
                    goto continue
                end
            end
        end

        if canRunEvent('ambient', now) then
            logDebug('ambient event')
            spawnAmbientGroup(playerSource)
            markEvent('ambient', now)
        end

        ::continue::
    end
end)


