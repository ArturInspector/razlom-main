local currentThreatLevel = 0
local capturedNodes = {}

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

-- Начать захват узла
RegisterNetEvent('apo:invasion:startCapture', function(nodeId)
    local source = source
    -- TODO: реализовать логику захвата узла
    print('[INVASION] Игрок ' .. source .. ' начал захват узла ' .. nodeId)
end)

-- Запустить волну
function StartWave(coords, tier)
    local waveConfig = Config.Waves[tier] or Config.Waves[1]
    -- TODO: интеграция с apo_mobs для спавна
    TriggerClientEvent('apo:invasion:waveStart', -1, coords, tier)
end

exports('GetThreatLevel', function()
    return currentThreatLevel
end)

exports('StartWave', StartWave)

