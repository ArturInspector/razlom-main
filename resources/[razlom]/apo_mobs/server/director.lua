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

local function getRandomSpawnCoords(center, radiusRange)
    local minRadius = radiusRange and radiusRange.min or Config.Mobs.spawn_radius_min
    local maxRadius = radiusRange and radiusRange.max or Config.Mobs.spawn_radius_max
    local radius = math.random() * (maxRadius - minRadius) + minRadius
    local angle = math.random() * math.pi * 2
    local x = center.x + math.cos(angle) * radius
    local y = center.y + math.sin(angle) * radius
    local z = center.z
    return vector3(x, y, z)
end

local function selectScenarioByWeight(scenarios, context)
    if not scenarios or #scenarios == 0 then
        return nil
    end
    
    local valid = {}
    local totalWeight = 0
    
    for _, scenario in ipairs(scenarios) do
        local isValid = true
        
        -- Проверка условий
        if context.threat then
            if scenario.min_threat and context.threat < scenario.min_threat then
                isValid = false
            end
            if scenario.max_threat and context.threat > scenario.max_threat then
                isValid = false
            end
        end
        
        if context.level then
            if scenario.min_level and context.level < scenario.min_level then
                isValid = false
            end
            if scenario.max_level and context.level > scenario.max_level then
                isValid = false
            end
        end
        
        if context.playerCount then
            if scenario.min_players and context.playerCount < scenario.min_players then
                isValid = false
            end
            if scenario.max_players and context.playerCount > scenario.max_players then
                isValid = false
            end
        end
        
        if isValid then
            table.insert(valid, scenario)
            totalWeight = totalWeight + (scenario.weight or 1)
        end
    end
    
    if #valid == 0 then
        return nil
    end
    
    local roll = math.random() * totalWeight
    local current = 0
    
    for _, scenario in ipairs(valid) do
        current = current + (scenario.weight or 1)
        if roll <= current then
            return scenario
        end
    end
    
    return valid[#valid] -- Fallback
end

local function spawnComposition(coords, composition, modifiers, targetSource)
    if not composition then return end
    
    modifiers = modifiers or {}
    local spawnCount = modifiers.spawn_count or 1.0
    
    for _, entry in ipairs(composition) do
        local count = entry.count
        if not count then goto continue end
        
        local minCount = math.max(0, math.floor((count.min or 1) * spawnCount))
        local maxCount = math.max(minCount, math.floor((count.max or 1) * spawnCount))
        local actualCount = math.random(minCount, maxCount)
        
        if entry.chance and math.random() > entry.chance then
            actualCount = 0
        end
        
        for _ = 1, actualCount do
            Mobs.Spawn(coords, entry.archetype, 1, targetSource)
        end
        
        ::continue::
    end
end

local function spawnAmbientGroup(targetSource)
    local ped = GetPlayerPed(targetSource)
    if not ped or ped == 0 then return end

    local coords = GetEntityCoords(ped)
    local threat = getThreatLevel()
    local playerCount = #GetPlayers()
    
    local scenario = selectScenarioByWeight(Config.Scenarios and Config.Scenarios.ambient, {
        threat = threat,
        playerCount = playerCount
    })
    
    if scenario then
        local modifiers = Config.Modifiers and Config.Modifiers.player_scaling and Config.Modifiers.player_scaling[playerCount] or { spawn_count = 1.0 }
        local spawnCoords = getRandomSpawnCoords(coords, scenario.spawn_radius)
        
        spawnComposition(spawnCoords, scenario.composition, modifiers, targetSource)
        
        if scenario.notification then
            notify(targetSource, scenario.notification.message, scenario.notification.type)
        end
        
        TriggerClientEvent('apo:director:ambientSpawn', targetSource, { 
            count = #scenario.composition,
            scenario = scenario.name
        })
    else
        -- Fallback на старую логику
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
        
        TriggerClientEvent('apo:director:ambientSpawn', targetSource, { count = count })
    end
end

local function spawnHotspotGroup(hotspot)
    if not hotspot or not hotspot.coords then return end

    local level = hotspot.level or 0
    local scenario = selectScenarioByWeight(Config.Scenarios and Config.Scenarios.hotspot, {
        level = level
    })
    
    if scenario then
        local multiplier = scenario.composition_multiplier or 1.0
        local adjustedLevel = level * multiplier
        
        local modifiers = {
            spawn_count = math.min(2.0, adjustedLevel / 20.0)
        }
        
        spawnComposition(hotspot.coords, scenario.composition, modifiers, nil)
        
        -- Уведомления игрокам в радиусе
        for _, source in ipairs(GetPlayers()) do
            local ped = GetPlayerPed(source)
            if ped and ped ~= 0 then
                local playerCoords = GetEntityCoords(ped)
                if #(playerCoords - hotspot.coords) < 200 then
                    local msg = scenario.notification.message
                    if string.find(msg, '%%d') then
                        msg = string.format(msg, level)
                    end
                    TriggerClientEvent('apo:director:hotspotSpawn', source, { 
                        level = level,
                        scenario = scenario.name
                    })
                end
            end
        end
    else
        -- Fallback на старую логику
        local spawns = math.min(Config.Director.hotspot_max_spawns, math.max(1, math.floor(level / 5)))
        for _ = 1, spawns do
            Mobs.SpawnDirected(hotspot.coords, level)
        end

        local note = Config.Director.notifications and Config.Director.notifications.hotspot
        if note then
            for _, player in ipairs(GetPlayers()) do
                notify(player, note.message, note.type)
            end
        end
        
        for _, source in ipairs(GetPlayers()) do
            local ped = GetPlayerPed(source)
            if ped and ped ~= 0 then
                local playerCoords = GetEntityCoords(ped)
                if #(playerCoords - hotspot.coords) < 200 then
                    TriggerClientEvent('apo:director:hotspotSpawn', source, { level = level })
                end
            end
        end
    end
end

local function startThreatWave(coords, threat, targetSource)
    if GetResourceState('apo_invasion') == 'started' then
        local tier = math.min(3, 1 + math.floor((threat or 0) / 4))
        
        -- Выбор сценария wave для уведомления
        local scenario = nil
        if Config.Scenarios and Config.Scenarios.wave then
            for _, waveScenario in ipairs(Config.Scenarios.wave) do
                if waveScenario.tier == tier then
                    scenario = waveScenario
                    break
                end
            end
        end
        
        exports['apo_invasion']:StartWave(coords, tier, targetSource)
        
        if scenario and scenario.notification then
            notify(targetSource, scenario.notification.message, scenario.notification.type)
        else
            local note = Config.Director.notifications and Config.Director.notifications.wave
            if note then
                notify(targetSource, note.message, note.type)
            end
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


