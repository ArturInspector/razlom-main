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
        name = "Node #1 (Grapeseed)",
        coords = vector3(1705.0, 4820.0, 42.0),
        tier = 1,
        capture_time = 180,
        spawn_radius = 60.0,
        buffs = {"loot_bonus"},
        waves = 3
    },
    {
        id = 2,
        name = "Node #2 (Alamo Sea)",
        coords = vector3(548.0, 4179.0, 40.0),
        tier = 1,
        capture_time = 180,
        spawn_radius = 60.0,
        buffs = {"xp_boost"},
        waves = 3
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

Config.Rewards = {
    xp_base = 50,
    xp_per_tier = 25,
    loot = {
        { item = 'scrap_metal', min = 2, max = 4 },
        { item = 'electronic_parts', min = 1, max = 2 },
        { item = 'canned_food', min = 1, max = 2 }
    }
}

