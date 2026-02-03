local tutorialState = {}

local function ensureState(source)
    if not tutorialState[source] then
        tutorialState[source] = {
            step = 1,
            kills = 0,
            active = true
        }
    end
    return tutorialState[source]
end

local function setStep(source, step)
    local state = ensureState(source)
    state.step = step
    TriggerClientEvent('apo:tutorial:stepChanged', source, step, state.kills)
end

RegisterNetEvent('apo:player:loaded')
AddEventHandler('apo:player:loaded', function()
    local source = source
    ensureState(source)
    TriggerClientEvent('apo:tutorial:start', source)
end)

RegisterNetEvent('apo:tutorial:talkedToNpc', function()
    local source = source
    local state = ensureState(source)
    if state.step ~= 1 then return end

    exports['apo_inventory']:addItem(source, 'weapon_pistol', 1)
    exports['apo_inventory']:addItem(source, 'ammo_pistol', 50)

    setStep(source, 2)
end)

RegisterNetEvent('apo:tutorial:enteredWild', function()
    local source = source
    local state = ensureState(source)
    if state.step ~= 2 then return end

    state.step = 3
    state.kills = 0
    TriggerClientEvent('apo:tutorial:stepChanged', source, 3, state.kills)

    local ped = GetPlayerPed(source)
    if ped and ped ~= 0 then
        local coords = GetEntityCoords(ped)
        for _ = 1, Config.KillTarget.count do
            exports['apo_mobs']:Spawn(coords, Config.KillTarget.archetype, 1, source)
        end
    end
end)

RegisterNetEvent('apo:tutorial:returnedToColony', function()
    local source = source
    local state = ensureState(source)
    if state.step ~= 4 then return end

    exports['apo_inventory']:addItem(source, 'credits', Config.Rewards.credits)
    exports['apo_inventory']:addItem(source, 'water', Config.Rewards.water)

    setStep(source, 5)
end)

RegisterNetEvent('apo:tutorial:completed', function()
    local source = source
    local state = ensureState(source)
    state.active = false
end)

AddEventHandler('apo:mobs:died', function(_, killerSource, archetype)
    if not killerSource or not archetype then return end

    local state = tutorialState[killerSource]
    if not state or state.step ~= 3 then return end

    if archetype ~= Config.KillTarget.archetype then return end

    state.kills = state.kills + 1
    TriggerClientEvent('apo:tutorial:stepChanged', killerSource, 3, state.kills)

    if state.kills >= Config.KillTarget.count then
        setStep(killerSource, 4)
    end
end)

AddEventHandler('playerDropped', function()
    local source = source
    tutorialState[source] = nil
end)

