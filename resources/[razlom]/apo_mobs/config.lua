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
    stalker = {
        model = 'a_m_y_methhead_01',
        health = 140,
        damage = 14,
        speed = 1.2,
        behavior = 'flank'
    },
    tank = {
        model = 'a_m_y_army_01',
        health = 500,
        damage = 30,
        speed = 0.8,
        armor = 50,
        behavior = 'advance'
    },
    elite = {
        model = 's_m_y_swat_01',
        health = 900,
        damage = 45,
        speed = 1.0,
        armor = 100,
        behavior = 'pressure'
    }
}

Config.LootTables = {
    runner = {
        { item = 'bandage', min = 1, max = 2, chance = 0.35 },
        { item = 'water', min = 1, max = 1, chance = 0.25 },
        { item = 'canned_food', min = 1, max = 1, chance = 0.2 },
        { item = 'scrap_metal', min = 1, max = 2, chance = 0.1 }
    },
    stalker = {
        { item = 'bandage', min = 1, max = 2, chance = 0.25 },
        { item = 'canned_food', min = 1, max = 2, chance = 0.25 },
        { item = 'scrap_metal', min = 1, max = 3, chance = 0.2 }
    },
    tank = {
        { item = 'scrap_metal', min = 2, max = 4, chance = 0.6 },
        { item = 'bandage', min = 1, max = 2, chance = 0.2 }
    },
    elite = {
        { item = 'scrap_metal', min = 3, max = 6, chance = 0.7 },
        { item = 'electronic_parts', min = 1, max = 2, chance = 0.35 },
        { item = 'bandage', min = 1, max = 2, chance = 0.25 }
    }
}

Config.Director = {
    enabled = true,
    tick_ms = 10000,
    base_chance = 0.35,
    global_cooldown_ms = 30000,
    min_players = 1,
    max_alive_soft = 24,
    hotspot_min_level = 20,
    hotspot_max_spawns = 4,
    wave_threat_min = 4,
    ambient_spawns = { min = 2, max = 4 },
    ambient_archetypes = { 'runner', 'stalker' },
    elite_spawn_chance = 0.1,
    event_cooldowns = {
        ambient = 20000,
        hotspot = 30000,
        wave = 60000
    },
    notifications = {
        ambient = { message = 'Разведгруппа противника движется к вам', type = 'warning' },
        hotspot = { message = 'Высокая активность роя — готовьтесь к бою', type = 'error' },
        wave = { message = 'Волна противника направлена на вашу позицию', type = 'error' }
    },
    debug = false
}

-- Визуальные настройки маркеров
Config.Markers = {
    enabled = true,
    update_interval = 0, -- 0 = каждый кадр (для плавности)
    hotspot = {
        draw_distance = 150.0,
        marker_type = 1,
        color = { r = 255, g = 0, b = 0 },
        scale = { min = 1.0, max = 3.0 },
        lifetime_ms = 300000 -- 5 минут
    },
    wave = {
        draw_distance = 200.0,
        marker_type = 1,
        color = { r = 255, g = 107, b = 53 },
        scale = { min = 2.0, max = 5.0 },
        lifetime_ms = 600000 -- 10 минут
    },
    ambient = {
        draw_distance = 100.0,
        marker_type = 28,
        color = { r = 255, g = 255, b = 0 },
        scale = { min = 0.8, max = 2.0 },
        lifetime_ms = 180000, -- 3 минуты
        fade_after_ms = 60000 -- Начинать затухать после 1 минуты
    }
}

