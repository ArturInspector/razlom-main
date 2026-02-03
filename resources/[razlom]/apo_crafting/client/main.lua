RegisterCommand('craftmenu', function()
    TriggerServerEvent('apo:crafting:openMenu')
end, false)

RegisterCommand('craft', function(_, args)
    local recipeName = args[1]
    if not recipeName then
        print('[CRAFTING] Использование: /craft <recipe>')
        return
    end
    TriggerServerEvent('apo:crafting:craft', recipeName)
end, false)

RegisterNetEvent('apo:crafting:openMenu')
AddEventHandler('apo:crafting:openMenu', function(recipes)
    exports['apo_ui']:OpenMenu('crafting', { recipes = recipes })
end)

