-- Инициализация
CreateThread(function()
    print('[SIGNAL] Клиент инициализирован')
end)

-- Отслеживание выстрелов
CreateThread(function()
    while true do
        Wait(0)
        
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

