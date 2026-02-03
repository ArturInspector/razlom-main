Mobs = Mobs or {}

require 'server.spawn'
require 'server.ai'
require 'server.combat'

exports('Spawn', function(coords, archetype, tier, targetSource)
    return Mobs.Spawn(coords, archetype, tier, targetSource)
end)

exports('Despawn', function(mobId)
    return Mobs.Despawn(mobId)
end)

exports('SpawnDirected', function(coords, noiseLevel, targetSource)
    return Mobs.SpawnDirected(coords, noiseLevel, targetSource)
end)

exports('GetAliveCount', function()
    return Mobs.GetAliveCount()
end)

print('[MOBS] apo_mobs initialized')

