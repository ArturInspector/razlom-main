Config = {}

Config.StartingMoney = 100
Config.MaxMoney = 1000000

Config.DefaultStats = {
    health = 100.0,
    hunger = 100.0,
    thirst = 100.0,
    radiation = 0.0
}

Config.DefaultClass = 'stalker'

-- Точки спауна для новой карты (Post-Apocalyptic LS)
-- type используется для будущей логики (colony = безопасная зона, fob = форпост)
Config.SpawnPoints = {
    {
        label = 'Colony - Sandy Shores',
        coords = vector3(1850.0, 3685.0, 34.3),
        heading = 210.0,
        type = 'colony'
    },
    {
        label = 'FOB - Paleto Bay',
        coords = vector3(-431.0, 6044.0, 31.3),
        heading = 45.0,
        type = 'fob'
    },
    {
        label = 'FOB - Harmony',
        coords = vector3(561.0, 2793.0, 42.0),
        heading = 190.0,
        type = 'fob'
    }
}

