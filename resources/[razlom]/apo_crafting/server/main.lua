local function getRecipe(recipeName)
    return Config.Recipes[recipeName]
end

local function hasIngredients(source, recipe)
    for _, input in ipairs(recipe.inputs) do
        if not exports['apo_inventory']:hasItem(source, input.item, input.count) then
            return false
        end
    end
    return true
end

local function consumeIngredients(source, recipe)
    for _, input in ipairs(recipe.inputs) do
        exports['apo_inventory']:removeItem(source, input.item, input.count)
    end
end

local function giveOutput(source, recipe)
    local output = recipe.output
    exports['apo_inventory']:addItem(source, output.item, output.count)
end

RegisterNetEvent('apo:crafting:craft')
AddEventHandler('apo:crafting:craft', function(recipeName)
    local source = source
    local recipe = getRecipe(recipeName)
    if not recipe then
        TriggerClientEvent('apo:ui:notify', source, 'Рецепт не найден', 'error')
        return
    end

    if not hasIngredients(source, recipe) then
        TriggerClientEvent('apo:ui:notify', source, 'Недостаточно ингредиентов', 'warning')
        return
    end

    consumeIngredients(source, recipe)
    giveOutput(source, recipe)
    TriggerClientEvent('apo:ui:notify', source, 'Крафт завершён: ' .. recipe.label, 'success')
end)

RegisterNetEvent('apo:crafting:openMenu')
AddEventHandler('apo:crafting:openMenu', function()
    local source = source
    TriggerClientEvent('apo:crafting:openMenu', source, Config.Recipes)
end)

exports('GetRecipes', function()
    return Config.Recipes
end)

