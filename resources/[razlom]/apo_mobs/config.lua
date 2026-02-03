Config = Config or {}

Config.Mobs = {
    max_alive = 30,
    spawn_radius_min = 20.0,
    spawn_radius_max = 60.0,
    aggro_radius = 120.0,
    despawn_distance = 500.0,
    attack_range = 1.8,
    attack_interval_ms = 1500
}

Config.Archetypes = {
    runner = {
        model = 'a_m_y_runner_01',
        health = 100,
        damage = 10,
        speed = 1.5,
        behavior = 'rush'
    },
    tank = {
        model = 'a_m_y_army_01',
        health = 500,
        damage = 30,
        speed = 0.8,
        armor = 50,
        behavior = 'advance'
    }
}

Config.LootTables = {
    runner = {
        { item = 'bandage', min = 1, max = 2, chance = 0.35 },
        { item = 'water', min = 1, max = 1, chance = 0.25 },
        { item = 'canned_food', min = 1, max = 1, chance = 0.2 },
        { item = 'scrap_metal', min = 1, max = 2, chance = 0.1 }
    },
    tank = {
        { item = 'scrap_metal', min = 2, max = 4, chance = 0.6 },
        { item = 'bandage', min = 1, max = 2, chance = 0.2 }
    }
}

