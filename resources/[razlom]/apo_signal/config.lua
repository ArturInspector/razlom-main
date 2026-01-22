Config = {}

-- Уровни шума по типам оружия
Config.NoiseLevel = {
    -- Ближний бой
    ["WEAPON_KNIFE"] = 0,
    ["WEAPON_BAT"] = 0,
    
    -- Пистолеты
    ["WEAPON_PISTOL"] = 3,
    ["WEAPON_COMBATPISTOL"] = 3,
    ["WEAPON_PISTOL50"] = 4,
    
    -- Пистолеты с глушителем
    ["WEAPON_PISTOL_SUPPRESSED"] = 1,
    
    -- Дробовики
    ["WEAPON_PUMPSHOTGUN"] = 5,
    ["WEAPON_SAWNOFFSHOTGUN"] = 5,
    
    -- Автоматы
    ["WEAPON_ASSAULTRIFLE"] = 7,
    ["WEAPON_CARBINERIFLE"] = 7,
    ["WEAPON_SPECIALCARBINE"] = 7,
    ["WEAPON_SMG"] = 6, -- Scrap SMG
    
    -- Снайперские
    ["WEAPON_SNIPERRIFLE"] = 8,
    ["WEAPON_HEAVYSNIPER"] = 9,
    
    -- Взрывчатка
    ["WEAPON_GRENADE"] = 10,
    ["WEAPON_STICKYBOMB"] = 10,
    ["WEAPON_RPG"] = 10
}

-- Радиусы агро по уровню шума
Config.AggroRadius = {
    [0] = 10,   -- Нож
    [1] = 30,   -- Глушитель
    [3] = 80,   -- Пистолет
    [5] = 120,  -- Дробовик
    [7] = 150,  -- Автомат
    [8] = 180,  -- Снайперка
    [10] = 250  -- Взрывчатка
}

-- Настройки тепловой карты
Config.Heatmap = {
    lifetime = 60000, -- 60 секунд жизни точки шума
    spawn_threshold = 20, -- Сумма шума для спавна
    check_interval = 10000, -- Проверка каждые 10 секунд
    directed_chance = 0.7 -- 70% спавна направленно, 30% случайно
}

