CreateThread(function()
    Wait(4000)
    while true do
        Wait(500)
        local ped = PlayerPedId()
        local coords = GetEntityCoords(ped)
        local distance = #(coords - Config.Shop.coords)

        if distance < Config.Shop.marker_radius then
            DrawMarker(1, Config.Shop.coords.x, Config.Shop.coords.y, Config.Shop.coords.z - 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 2.2, 2.2, 1.0, 0, 245, 255, 120, false, true, 2, nil, nil, false)
        end

        if distance < Config.Shop.radius then
            BeginTextCommandDisplayHelp('STRING')
            AddTextComponentSubstringPlayerName('Нажмите ~INPUT_CONTEXT~ чтобы открыть магазин')
            EndTextCommandDisplayHelp(0, false, true, -1)
            if IsControlJustPressed(0, 38) then
                TriggerServerEvent('apo:economy:openShop')
            end
        end
    end
end)

RegisterNetEvent('apo:economy:openShop', function(data)
    exports['apo_ui']:OpenMenu('shop', data)
end)

RegisterNetEvent('apo:economy:updateShop', function(data)
    exports['apo_ui']:OpenMenu('shop', data)
end)

