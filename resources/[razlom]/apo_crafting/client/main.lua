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
    local uiRecipes = {}

    for name, recipe in pairs(recipes) do
        local inputs = {}
        for _, input in ipairs(recipe.inputs) do
            table.insert(inputs, {
                item = input.item,
                count = input.count,
                label = string.upper((input.item or ''):gsub('_', ' '))
            })
        end

        local output = recipe.output or {}
        local outputLabel = string.upper((output.item or ''):gsub('_', ' '))

        table.insert(uiRecipes, {
            name = name,
            label = recipe.label or string.upper((name or ''):gsub('_', ' ')),
            inputs = inputs,
            output = {
                item = output.item,
                count = output.count or 1,
                label = outputLabel
            },
            time = recipe.time or 0
        })
    end

    table.sort(uiRecipes, function(a, b)
        return a.label < b.label
    end)

    exports['apo_ui']:OpenMenu('crafting', { recipes = uiRecipes })
end)

