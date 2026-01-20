Config = {}

-- Таблица рангов
Config.Ranks = {
    {level = 1, xp = 0, name = "Civilian", perk_slots = 0},
    {level = 2, xp = 100, name = "Recruit", perk_slots = 1},
    {level = 3, xp = 300, name = "Soldier", perk_slots = 1},
    {level = 4, xp = 700, name = "Veteran", perk_slots = 2},
    {level = 5, xp = 1500, name = "Elite", perk_slots = 2},
    {level = 6, xp = 3000, name = "Commander", perk_slots = 3},
    {level = 7, xp = 6000, name = "Hero", perk_slots = 3},
    {level = 8, xp = 12000, name = "Champion", perk_slots = 4},
    {level = 9, xp = 25000, name = "Master", perk_slots = 4},
    {level = 10, xp = 50000, name = "Legend", perk_slots = 5}
}

-- Источники XP
Config.XPSources = {
    kill_runner = 10,
    kill_stalker = 20,
    kill_tank = 40,
    kill_psionic = 50,
    kill_elite = 100,
    kill_boss = 500,
    capture_node = 500,
    defend_caravan = 300,
    find_artifact = 200,
    clear_bunker = 1000,
    defend_wave = 700
}

-- Скейлинг сложности
Config.Scaling = {
    hp_per_rank = 0.15, -- +15% HP за ранг
    damage_per_rank = 0.1, -- +10% урон за ранг
    hp_per_player = 0.2, -- +20% HP за игрока
    damage_per_player = 0.15 -- +15% урон за игрока
}

-- Перки
Config.Perks = {
    -- Боевые
    {id = "sharpshooter", name = "Sharpshooter", type = "combat", bonus = {damage = 1.15}},
    {id = "tank", name = "Tank", type = "combat", bonus = {hp = 1.20}},
    {id = "agile", name = "Agile", type = "combat", bonus = {speed = 1.15}},
    
    -- Утилитарные
    {id = "scavenger", name = "Scavenger", type = "utility", bonus = {loot = 1.25}},
    {id = "trader", name = "Trader", type = "utility", bonus = {discount = 0.85}},
    {id = "medic", name = "Medic", type = "utility", bonus = {healing = 1.50}}
}

