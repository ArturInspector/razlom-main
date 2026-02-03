Mobs = Mobs or {}

local MobState = {}
local NextMobId = 1

local function getArchetypeConfig(archetype)
    return Config.Archetypes[archetype]
end

local function getRandomSpawnCoords(center)
    local radius = math.random() * (Config.Mobs.spawn_radius_max - Config.Mobs.spawn_radius_min) + Config.Mobs.spawn_radius_min
    local angle = math.random() * math.pi * 2
    local x = center.x + math.cos(angle) * radius
    local y = center.y + math.sin(angle) * radius
    local z = center.z
    return vector3(x, y, z)
end

local function ensureModelLoaded(model)
    local modelHash = GetHashKey(model)
    if not IsModelInCdimage(modelHash) or not IsModelValid(modelHash) then
        return nil
    end

    RequestModel(modelHash)
    local timeout = GetGameTimer() + 5000
    while not HasModelLoaded(modelHash) do
        Wait(0)
        if GetGameTimer() > timeout then
            return nil
        end
    end

    return modelHash
end

function Mobs.Spawn(centerCoords, archetype, tier, targetSource)
    if Mobs.GetAliveCount() >= Config.Mobs.max_alive then
        return nil
    end

    local archetypeCfg = getArchetypeConfig(archetype or 'runner')
    if not archetypeCfg then
        return nil
    end

    local modelHash = ensureModelLoaded(archetypeCfg.model)
    if not modelHash then
        return nil
    end

    local spawnCoords = getRandomSpawnCoords(centerCoords)
    local ped = CreatePed(4, modelHash, spawnCoords.x, spawnCoords.y, spawnCoords.z, 0.0, true, true)
    if not ped or ped == 0 then
        return nil
    end

    SetEntityAsMissionEntity(ped, true, true)
    SetPedArmour(ped, archetypeCfg.armor or 0)
    SetEntityHealth(ped, archetypeCfg.health or 100)
    SetPedMoveRateOverride(ped, archetypeCfg.speed or 1.0)
    SetPedAccuracy(ped, 30)
    SetPedFleeAttributes(ped, 0, false)
    SetPedCombatRange(ped, 1)
    SetPedCombatMovement(ped, 2)

    local mobId = NextMobId
    NextMobId = NextMobId + 1

    MobState[mobId] = {
        id = mobId,
        entity = ped,
        archetype = archetype or 'runner',
        tier = tier or 1,
        targetSource = targetSource,
        lastAttackAt = 0,
        lastAttackerSource = nil
    }

    Entity(ped).state.apoMobId = mobId
    TriggerEvent('apo:mobs:spawned', mobId, archetype, spawnCoords)

    return mobId
end

function Mobs.Despawn(mobId)
    local mob = MobState[mobId]
    if not mob then return false end

    if DoesEntityExist(mob.entity) then
        DeleteEntity(mob.entity)
    end

    MobState[mobId] = nil
    return true
end

function Mobs.GetMob(mobId)
    return MobState[mobId]
end

function Mobs.GetAliveCount()
    local count = 0
    for _, _ in pairs(MobState) do
        count = count + 1
    end
    return count
end

function Mobs.SpawnDirected(coords, noiseLevel, targetSource)
    local count = math.min(5, math.max(1, math.floor(noiseLevel / 4)))
    for _ = 1, count do
        Mobs.Spawn(coords, 'runner', 1, targetSource)
    end
end

function Mobs.Iterate()
    return pairs(MobState)
end

