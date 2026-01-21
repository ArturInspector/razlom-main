-- Инициализация
CreateThread(function()
    print('[SIGNAL] Клиент инициализирован')
end)

-- Отслеживание выстрелов
CreateThread(function()
    Wait(5000) -- Даем время загрузиться
    while true do
        Wait(100) -- Проверяем выстрелы каждые 100мс
        
        local ped = PlayerPedId()
        
        if IsPedShooting(ped) then
            local coords = GetEntityCoords(ped)
            local weapon = GetSelectedPedWeapon(ped)
            
            -- Отправить на сервер
            TriggerServerEvent('apo:signal:registerNoise', coords, weapon)
            
            Wait(500) -- Дебаунс
        end
    end
end)

