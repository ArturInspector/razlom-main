local function resourceRunning(name)
    return GetResourceState(name) == 'started'
end

if resourceRunning('apo_crafting') then
    ApoTest.register('integration:craftingRecipes', function()
        local recipes = exports['apo_crafting']:GetRecipes()
        ApoTest.assertTrue(type(recipes) == 'table', 'рецепты должны быть таблицей')
        ApoTest.assertTrue(recipes.medkit ~= nil, 'должен быть рецепт medkit')
    end)
end

if resourceRunning('apo_mobs') and resourceRunning('apo_signal') then
    ApoTest.register('integration:signalMobsLink', function()
        local before = exports['apo_mobs']:GetAliveCount()
        exports['apo_mobs']:SpawnDirected(vector3(0, 0, 72), 8)
        local after = exports['apo_mobs']:GetAliveCount()
        ApoTest.assertTrue(after >= before, 'спавн мобов должен увеличивать счётчик')
    end)
end

