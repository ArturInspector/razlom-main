RegisterCommand('faction', function()
    TriggerServerEvent('apo:reputation:openMenu')
end, false)

RegisterNetEvent('apo:reputation:openMenu', function(factions)
    exports['apo_ui']:OpenMenu('faction', { factions = factions })
end)

RegisterNetEvent('apo:reputation:factionSelected', function(faction)
    print(('[REPUTATION] Фракция выбрана: %s'):format(faction.label))
end)

