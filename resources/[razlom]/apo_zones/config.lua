Config = Config or {}

Config.ZoneCheckInterval = 2000

Config.Colony = {
    name = 'Colony',
    coords = vector3(1862.0, 3681.0, 33.0),
    radius = 200.0
}

Config.Perimeter = {
    name = 'Perimeter',
    inner = 200.0,
    outer = 500.0
}

Config.Wild = {
    name = 'Wild',
    min = 500.0
}

Config.Nodes = {
    {
        id = 1,
        name = 'Node #1',
        coords = vector3(1705.0, 4820.0, 42.0),
        radius = 30.0,
        threat_bonus = 2
    },
    {
        id = 2,
        name = 'Node #2',
        coords = vector3(548.0, 4179.0, 40.0),
        radius = 30.0,
        threat_bonus = 3
    }
}

Config.Threat = {
    perimeter_danger_level = 8
}

