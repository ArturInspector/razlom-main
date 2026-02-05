local currentThreatLevel = 0
local activeCapture = nil

local function updateThreatHUD()
    exports['apo_ui']:UpdateHUD({
        threat = currentThreatLevel,
        threatMax = Config.ThreatLevel.max
    })
end

-- Инициализация
CreateThread(function()
    print('[INVASION] Клиент инициализирован')
    TriggerServerEvent('apo:invasion:getThreatLevel')
end)

-- Получить уровень угрозы
RegisterNetEvent('apo:invasion:threatLevel', function(level)
    currentThreatLevel = level
    updateThreatHUD()
end)

-- Изменение уровня угрозы
RegisterNetEvent('apo:invasion:threatChanged', function(level)
    currentThreatLevel = level
    updateThreatHUD()
end)

-- Начало волны
RegisterNetEvent('apo:invasion:waveStart', function(coords, tier)
    TriggerEvent('apo:ui:notify', ('Волна вторжения: Tier %d'):format(tier), 'warning')
    TriggerEvent('apo:director:waveIncoming', { coords = coords, tier = tier })
    print('[INVASION] Волна начинается! Tier: ' .. tier)
end)

RegisterNetEvent('apo:invasion:nodeCapturing', function(node)
    activeCapture = {
        id = node.id,
        name = node.name
    }
    exports['apo_ui']:UpdateHUD({
        capture = {
            active = true,
            label = node.name,
            progress = 0,
            wavesLeft = node.waves or 0
        }
    })
end)

RegisterNetEvent('apo:invasion:nodeCaptureProgress', function(nodeId, progress, wavesLeft, timeLeft)
    if not activeCapture or activeCapture.id ~= nodeId then return end
    exports['apo_ui']:UpdateHUD({
        capture = {
            active = true,
            label = activeCapture.name,
            progress = progress,
            wavesLeft = wavesLeft,
            timeLeft = timeLeft
        }
    })
end)

RegisterNetEvent('apo:invasion:nodeCaptured', function(nodeId)
    if activeCapture and activeCapture.id == nodeId then
        exports['apo_ui']:UpdateHUD({
            capture = { active = false }
        })
        TriggerEvent('apo:ui:notify', 'Узел захвачен. Награда получена.', 'success')
        activeCapture = nil
    end
end)

RegisterNetEvent('apo:invasion:nodeCaptureCancelled', function(nodeId, reason)
    if activeCapture and activeCapture.id == nodeId then
        exports['apo_ui']:UpdateHUD({
            capture = { active = false }
        })
        TriggerEvent('apo:ui:notify', 'Захват узла сорван', 'warning')
        activeCapture = nil
    end
end)

-- Маркеры узлов
CreateThread(function()
    Wait(5000) -- Даем время загрузиться
    while true do
        Wait(500) -- Снижаем частоту с 60fps до 2 раза в секунду
        local playerCoords = GetEntityCoords(PlayerPedId())
        
        for _, node in ipairs(Config.Nodes) do
            local distance = #(playerCoords - node.coords)
            
            if distance < 100.0 then
                DrawMarker(1, node.coords.x, node.coords.y, node.coords.z - 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 2.2, 2.2, 1.0, 0, 245, 255, 120, false, true, 2, nil, nil, false)
            end

            if distance < 5.0 then
                BeginTextCommandDisplayHelp('STRING')
                AddTextComponentSubstringPlayerName('Нажмите ~INPUT_CONTEXT~ чтобы начать захват узла')
                EndTextCommandDisplayHelp(0, false, true, -1)
                if IsControlJustPressed(0, 38) then -- E
                    TriggerServerEvent('apo:invasion:startCapture', node.id)
                end
            end
        end
    end
end)

