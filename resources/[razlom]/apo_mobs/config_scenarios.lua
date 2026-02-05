-- ════════════════════════════════════════════════════════════
-- Director Scenarios - Data-driven event definitions
-- ════════════════════════════════════════════════════════════

Config.Scenarios = Config.Scenarios or {}

-- Ambient события (случайные патрули)
Config.Scenarios.ambient = {
    {
        id = 'patrol_light',
        name = 'Light Patrol',
        weight = 50,
        min_threat = 0,
        max_threat = 5,
        min_players = 1,
        max_players = 4,
        composition = {
            { archetype = 'runner', count = { min = 2, max = 3 } },
            { archetype = 'stalker', count = { min = 0, max = 1 } }
        },
        spawn_radius = { min = 30.0, max = 80.0 },
        notification = {
            message = 'Разведгруппа противника движется к вам',
            type = 'warning'
        }
    },
    {
        id = 'patrol_heavy',
        name = 'Heavy Patrol',
        weight = 30,
        min_threat = 3,
        max_threat = 10,
        min_players = 2,
        max_players = 8,
        composition = {
            { archetype = 'runner', count = { min = 3, max = 5 } },
            { archetype = 'stalker', count = { min = 1, max = 2 } },
            { archetype = 'tank', count = { min = 0, max = 1 }, chance = 0.3 }
        },
        spawn_radius = { min = 40.0, max = 100.0 },
        notification = {
            message = 'Тяжёлый патруль обнаружен',
            type = 'error'
        }
    },
    {
        id = 'elite_strike',
        name = 'Elite Strike Team',
        weight = 5,
        min_threat = 6,
        max_threat = 10,
        min_players = 3,
        max_players = 8,
        composition = {
            { archetype = 'elite', count = { min = 1, max = 2 } },
            { archetype = 'tank', count = { min = 1, max = 2 } },
            { archetype = 'stalker', count = { min = 2, max = 3 } }
        },
        spawn_radius = { min = 50.0, max = 120.0 },
        notification = {
            message = 'ЭЛИТНОЕ ПОДРАЗДЕЛЕНИЕ: Приготовьтесь!',
            type = 'error'
        }
    }
}

-- Hotspot события (реакция на шум)
Config.Scenarios.hotspot = {
    {
        id = 'signal_response',
        name = 'Signal Response',
        weight = 60,
        min_level = 20,
        max_level = 50,
        composition_multiplier = 1.0,
        composition = {
            { archetype = 'runner', count = { min = 2, max = 4 } },
            { archetype = 'stalker', count = { min = 1, max = 2 } }
        },
        spawn_radius = { min = 20.0, max = 60.0 },
        notification = {
            message = 'Высокая концентрация сигнала: %d единиц',
            type = 'warning'
        }
    },
    {
        id = 'signal_surge',
        name = 'Signal Surge',
        weight = 30,
        min_level = 40,
        max_level = 100,
        composition_multiplier = 1.5,
        composition = {
            { archetype = 'runner', count = { min = 4, max = 6 } },
            { archetype = 'stalker', count = { min = 2, max = 3 } },
            { archetype = 'tank', count = { min = 0, max = 1 }, chance = 0.4 }
        },
        spawn_radius = { min = 30.0, max = 80.0 },
        notification = {
            message = 'КРИТИЧЕСКИЙ СИГНАЛ: Массовое скопление',
            type = 'error'
        }
    },
    {
        id = 'signal_overload',
        name = 'Signal Overload',
        weight = 10,
        min_level = 70,
        max_level = 999,
        composition_multiplier = 2.0,
        composition = {
            { archetype = 'elite', count = { min = 1, max = 2 } },
            { archetype = 'tank', count = { min = 2, max = 3 } },
            { archetype = 'runner', count = { min = 5, max = 8 } }
        },
        spawn_radius = { min = 40.0, max = 100.0 },
        notification = {
            message = 'ПЕРЕГРУЗКА СИГНАЛА: Эвакуируйтесь!',
            type = 'error'
        }
    }
}

-- Wave события (через apo_invasion)
Config.Scenarios.wave = {
    {
        id = 'wave_tier1',
        name = 'Tier 1 Wave',
        threat_range = { min = 0, max = 3 },
        tier = 1,
        composition = {
            { archetype = 'runner', count = { min = 5, max = 7 } },
            { archetype = 'stalker', count = { min = 1, max = 2 } }
        },
        notification = {
            message = 'Волна угрозы Tier 1',
            type = 'warning'
        }
    },
    {
        id = 'wave_tier2',
        name = 'Tier 2 Wave',
        threat_range = { min = 4, max = 6 },
        tier = 2,
        composition = {
            { archetype = 'runner', count = { min = 8, max = 10 } },
            { archetype = 'stalker', count = { min = 3, max = 4 } },
            { archetype = 'tank', count = { min = 1, max = 2 } }
        },
        notification = {
            message = 'Волна угрозы Tier 2',
            type = 'error'
        }
    },
    {
        id = 'wave_tier3',
        name = 'Tier 3 Wave',
        threat_range = { min = 7, max = 10 },
        tier = 3,
        composition = {
            { archetype = 'runner', count = { min = 10, max = 12 } },
            { archetype = 'stalker', count = { min = 5, max = 6 } },
            { archetype = 'tank', count = { min = 2, max = 3 } },
            { archetype = 'elite', count = { min = 1, max = 2 } }
        },
        notification = {
            message = 'КРИТИЧЕСКАЯ ВОЛНА Tier 3',
            type = 'error'
        }
    }
}

-- Модификаторы для скейлинга
Config.Modifiers = Config.Modifiers or {}

Config.Modifiers.player_scaling = {
    [1] = { mob_health = 0.8, mob_damage = 0.8, spawn_count = 0.7 },
    [2] = { mob_health = 0.9, mob_damage = 0.9, spawn_count = 0.85 },
    [3] = { mob_health = 1.0, mob_damage = 1.0, spawn_count = 1.0 },
    [4] = { mob_health = 1.1, mob_damage = 1.1, spawn_count = 1.15 },
    [5] = { mob_health = 1.2, mob_damage = 1.2, spawn_count = 1.3 },
    [6] = { mob_health = 1.3, mob_damage = 1.3, spawn_count = 1.5 }
}

Config.Modifiers.threat_scaling = {
    multiplier_per_level = 0.1,
    max_multiplier = 2.0
}
