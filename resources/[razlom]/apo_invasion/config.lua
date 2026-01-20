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
        name = "Слабый разлом",
        coords = vector3(100.0, 200.0, 30.0),
        tier = 1,
        capture_time = 180, -- 3 минуты
        spawn_radius = 50.0,
        buffs = {"shield"}, -- Баффы при захвате
        waves = 3
    }
    -- TODO: добавить больше узлов
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

