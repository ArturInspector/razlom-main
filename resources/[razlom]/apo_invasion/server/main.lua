local currentThreatLevel = 0
local capturedNodes = {}
local activeCaptures = {}

-- Инициализация
CreateThread(function()
    print('[INVASION] Система вторжения запущена')
    
    -- Постепенное увеличение угрозы
    while true do
        Wait(3600000) -- 1 час
        currentThreatLevel = math.min(Config.ThreatLevel.max, 
            currentThreatLevel + Config.ThreatLevel.increase_per_hour)
        TriggerClientEvent('apo:invasion:threatChanged', -1, currentThreatLevel)
        print('[INVASION] Threat Level: ' .. currentThreatLevel)
    end
end)

-- Получить текущий уровень угрозы
RegisterNetEvent('apo:invasion:getThreatLevel', function()
    local source = source
    TriggerClientEvent('apo:invasion:threatLevel', source, currentThreatLevel)
end)

local function getNodeById(nodeId)
    for _, node in ipairs(Config.Nodes) do
        if node.id == nodeId then
            return node
        end
    end
    return nil
end

local function getWaveTier(baseTier)
    local threatBonus = math.floor(currentThreatLevel / 4)
    return math.max(1, math.min(3, baseTier + threatBonus))
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

local function rewardCapture(source, node)
    local xp = Config.Rewards.xp_base + (node.tier * Config.Rewards.xp_per_tier)
    local faction = getPlayerFaction(source)
    if faction == 'mercenary' then
        xp = math.floor(xp * 1.2)
    end
    if GetResourceState('apo_progression') == 'started' then
        exports['apo_progression']:AddXP(source, xp, 'node_capture')
    end

    for _, drop in ipairs(Config.Rewards.loot) do
        local count = math.random(drop.min, drop.max)
        exports['apo_inventory']:addItem(source, drop.item, count)
    end

    if faction == 'cultist' then
        exports['apo_inventory']:addItem(source, 'scrap_metal', 1)
    end
end

local function cancelCapture(nodeId, source, reason)
    activeCaptures[nodeId] = nil
    TriggerClientEvent('apo:invasion:nodeCaptureCancelled', source, nodeId, reason)
end

-- Начать захват узла
RegisterNetEvent('apo:invasion:startCapture', function(nodeId)
    local source = source
    local node = getNodeById(nodeId)
    if not node then
        TriggerClientEvent('apo:ui:notify', source, 'Узел не найден', 'error')
        return
    end

    if capturedNodes[nodeId] then
        TriggerClientEvent('apo:ui:notify', source, 'Узел уже захвачен', 'warning')
        return
    end

    if activeCaptures[nodeId] then
        TriggerClientEvent('apo:ui:notify', source, 'Узел уже захватывается', 'warning')
        return
    end

    local ped = GetPlayerPed(source)
    if not ped or ped == 0 then return end

    local coords = GetEntityCoords(ped)
    if #(coords - node.coords) > node.spawn_radius then
        TriggerClientEvent('apo:ui:notify', source, 'Вы слишком далеко от узла', 'warning')
        return
    end

    activeCaptures[nodeId] = {
        source = source,
        startedAt = GetGameTimer()
    }

    TriggerClientEvent('apo:invasion:nodeCapturing', source, node)

    CreateThread(function()
        local captureMs = (node.capture_time or 180) * 1000
        local waveCount = node.waves or 3
        local waveInterval = math.max(10000, math.floor(captureMs / waveCount))
        local endAt = GetGameTimer() + captureMs
        local nextWaveAt = GetGameTimer()
        local wavesLeft = waveCount
        local lastProgress = -1

        while GetGameTimer() < endAt do
            Wait(1000)

            local capture = activeCaptures[nodeId]
            if not capture or capture.source ~= source then
                return
            end

            if GetPlayerPing(source) <= 0 then
                cancelCapture(nodeId, source, 'disconnect')
                return
            end

            local pedNow = GetPlayerPed(source)
            if not pedNow or pedNow == 0 then
                cancelCapture(nodeId, source, 'lost')
                return
            end

            local currentCoords = GetEntityCoords(pedNow)
            if #(currentCoords - node.coords) > node.spawn_radius then
                cancelCapture(nodeId, source, 'left')
                return
            end

            local now = GetGameTimer()
            if now >= nextWaveAt and wavesLeft > 0 then
                local tier = getWaveTier(node.tier)
                StartWave(node.coords, tier, source)
                wavesLeft = wavesLeft - 1
                nextWaveAt = now + waveInterval
            end

            local remaining = math.max(0, endAt - now)
            local progress = math.floor(((captureMs - remaining) / captureMs) * 100)
            if progress ~= lastProgress then
                TriggerClientEvent('apo:invasion:nodeCaptureProgress', source, nodeId, progress, wavesLeft, math.floor(remaining / 1000))
                lastProgress = progress
            end
        end

        activeCaptures[nodeId] = nil
        capturedNodes[nodeId] = true
        rewardCapture(source, node)

        currentThreatLevel = math.min(Config.ThreatLevel.max,
            currentThreatLevel + Config.ThreatLevel.node_capture)
        TriggerClientEvent('apo:invasion:threatChanged', -1, currentThreatLevel)

        TriggerClientEvent('apo:invasion:nodeCaptured', source, nodeId)
    end)
end)

-- Запустить волну
function StartWave(coords, tier, targetSource)
    local waveConfig = Config.Waves[tier] or Config.Waves[1]
    for _, entry in ipairs(waveConfig) do
        local count = entry.count or 1
        for _ = 1, count do
            exports['apo_mobs']:Spawn(coords, entry.archetype, tier, targetSource)
        end
    end
    TriggerClientEvent('apo:invasion:waveStart', -1, coords, tier)
end

exports('GetThreatLevel', function()
    return currentThreatLevel
end)

exports('StartWave', StartWave)

