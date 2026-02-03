Mobs = Mobs or {}

local function rollLoot(archetype)
    local tableCfg = Config.LootTables[archetype] or {}
    local drops = {}

    for _, entry in ipairs(tableCfg) do
        if math.random() <= (entry.chance or 0) then
            local minCount = entry.min or 1
            local maxCount = entry.max or minCount
            local count = math.random(minCount, maxCount)
            table.insert(drops, { item = entry.item, count = count })
        end
    end

    return drops
end

local function resolveKillerSource(mobEntity)
    local killer = GetPedSourceOfDeath(mobEntity)
    if not killer or killer == 0 then return nil end
    if not IsEntityAPed(killer) or not IsPedAPlayer(killer) then return nil end

    local playerIndex = NetworkGetPlayerIndexFromPed(killer)
    if playerIndex == nil or playerIndex < 0 then return nil end

    return GetPlayerServerId(playerIndex)
end

CreateThread(function()
    while true do
        Wait(500)
        for mobId, mob in Mobs.Iterate() do
            if not DoesEntityExist(mob.entity) then
                Mobs.Despawn(mobId)
                goto continue
            end

            if IsEntityDead(mob.entity) then
                local killerSource = resolveKillerSource(mob.entity)
                if killerSource then
                    local drops = rollLoot(mob.archetype)
                    for _, drop in ipairs(drops) do
                        exports['apo_inventory']:addItem(killerSource, drop.item, drop.count)
                    end
                end

                TriggerEvent('apo:mobs:died', mobId, killerSource)
                Mobs.Despawn(mobId)
            end

            ::continue::
        end
    end
end)

