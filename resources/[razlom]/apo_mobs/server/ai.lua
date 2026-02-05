Mobs = Mobs or {}

local function getNearestPlayer(coords, maxDistance)
    local nearest = nil
    local nearestDist = maxDistance or Config.Mobs.aggro_radius

    for _, source in ipairs(GetPlayers()) do
        local ped = GetPlayerPed(source)
        if ped and ped ~= 0 then
            local dist = #(coords - GetEntityCoords(ped))
            if dist < nearestDist then
                nearest = source
                nearestDist = dist
            end
        end
    end

    return nearest, nearestDist
end

local function assignTarget(mob, source)
    mob.targetSource = source
end

CreateThread(function()
    while true do
        Wait(1000)
        for mobId, mob in Mobs.Iterate() do
            if not DoesEntityExist(mob.entity) then
                Mobs.Despawn(mobId)
                goto continue
            end

            local mobCoords = GetEntityCoords(mob.entity)
            local targetSource = mob.targetSource

            if not targetSource or targetSource == 0 then
                local nearest, dist = getNearestPlayer(mobCoords, Config.Mobs.aggro_radius)
                if nearest then
                    assignTarget(mob, nearest)
                    targetSource = nearest
                end
            end

            if targetSource and targetSource ~= 0 then
                local targetPed = GetPlayerPed(targetSource)
                if targetPed and targetPed ~= 0 then
                    local targetCoords = GetEntityCoords(targetPed)
                    local distance = #(mobCoords - targetCoords)

                    if distance > Config.Mobs.despawn_distance then
                        Mobs.Despawn(mobId)
                        goto continue
                    end

                    TaskGoToEntity(mob.entity, targetPed, -1, 1.0, 2.0, 1073741824, 0)

                    if distance <= Config.Mobs.attack_range then
                        local now = GetGameTimer()
                        if now - mob.lastAttackAt >= Config.Mobs.attack_interval_ms then
                            mob.lastAttackAt = now
                            ApplyDamageToPed(targetPed, Config.Archetypes[mob.archetype].damage or 10, false)
                        end
                    end
                end
            end

            ::continue::
        end
    end
end)





