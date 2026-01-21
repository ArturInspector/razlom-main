local currentThreatLevel = 0

-- Инициализация
CreateThread(function()
    print('[INVASION] Клиент инициализирован')
    TriggerServerEvent('apo:invasion:getThreatLevel')
end)

-- Получить уровень угрозы
RegisterNetEvent('apo:invasion:threatLevel', function(level)
    currentThreatLevel = level
end)

-- Изменение уровня угрозы
RegisterNetEvent('apo:invasion:threatChanged', function(level)
    currentThreatLevel = level
    -- TODO: обновить HUD
end)

-- Начало волны
RegisterNetEvent('apo:invasion:waveStart', function(coords, tier)
    -- TODO: уведомление игроку, маркер на карте
    print('[INVASION] Волна начинается! Tier: ' .. tier)
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
                -- TODO: отрисовка маркера
            end
            
            if distance < 5.0 then
                -- TODO: показать подсказку E для захвата
                if IsControlJustPressed(0, 38) then -- E
                    TriggerServerEvent('apo:invasion:startCapture', node.id)
                end
            end
        end
    end
end)

