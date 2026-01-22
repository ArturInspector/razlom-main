Config = {}

-- Уровень угрозы (0-10)
Config.ThreatLevel = {
    min = 0,
    max = 10,
    increase_per_hour = 0.1, -- Рост со временем
    node_capture = 1, -- +1 при захвате узла
    boss_kill = -1 -- -1 при убийстве босса
}

-- Узлы вторжения
Config.Nodes = {
    {
        id = 1,
        name = "Sandy Outskirts",
        coords = vector3(1845.0, 3600.0, 34.0),
        tier = 1,
        capture_time = 180,
        spawn_radius = 60.0,
        buffs = {"shield"},
        waves = 3
    },
    {
        id = 2,
        name = "Harmony Cross",
        coords = vector3(615.0, 2725.0, 42.0),
        tier = 1,
        capture_time = 180,
        spawn_radius = 60.0,
        buffs = {"discount"},
        waves = 3
    },
    {
        id = 3,
        name = "LS Ruins - Textile City",
        coords = vector3(430.0, -800.0, 29.5),
        tier = 2,
        capture_time = 210,
        spawn_radius = 70.0,
        buffs = {"loot_bonus"},
        waves = 4
    },
    {
        id = 4,
        name = "LS Financial Ruins",
        coords = vector3(-110.0, -615.0, 36.3),
        tier = 2,
        capture_time = 210,
        spawn_radius = 70.0,
        buffs = {"xp_boost"},
        waves = 4
    },
    {
        id = 5,
        name = "Maze Bank Crater",
        coords = vector3(-75.0, -820.0, 326.2),
        tier = 3,
        capture_time = 240,
        spawn_radius = 80.0,
        buffs = {"shield", "loot_bonus"},
        waves = 5
    }
}

-- Волны
Config.Waves = {
    [1] = { -- Tier 1
        {archetype = "runner", count = 5},
        {archetype = "stalker", count = 2}
    },
    [2] = { -- Tier 2
        {archetype = "runner", count = 8},
        {archetype = "stalker", count = 4},
        {archetype = "tank", count = 1}
    },
    [3] = { -- Tier 3
        {archetype = "runner", count = 10},
        {archetype = "stalker", count = 6},
        {archetype = "tank", count = 2},
        {archetype = "elite", count = 1}
    }
}

