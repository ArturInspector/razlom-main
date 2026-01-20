local playerData = nil

RegisterNetEvent('apo:player:loaded', function(data)
    playerData = data
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
