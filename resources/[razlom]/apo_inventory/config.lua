Config = {}

-- Максимальный вес игрока по умолчанию
Config.MaxWeight = 50.0

-- Клавиша открытия инвентаря
Config.InventoryKey = 289 -- Клавиша 'F2' (обычно используется для инвентаря в FiveM) или 'I' (199 в GTA)
-- Мы будем использовать 'I' (199), так как это более "сталкерский" стиль
Config.OpenKey = 199

-- Список предметов
Config.Items = {
    -- Еда и вода
    ['water'] = {
        label = 'Clean Water',
        weight = 0.5,
        type = 'consume',
        description = 'Pure water, a luxury in the wasteland.'
    },
    ['canned_food'] = {
        label = 'Canned Food',
        weight = 0.8,
        type = 'consume',
        description = 'Old but edible. Hopefully.'
    },
    
    -- Медицина
    ['bandage'] = {
        label = 'Bandage',
        weight = 0.1,
        type = 'medical',
        description = 'Basic medical wrap to stop bleeding.'
    },
    ['medkit'] = {
        label = 'Old Medkit',
        weight = 1.5,
        type = 'medical',
        description = 'A set of pre-war medical supplies.'
    },
    ['antirad'] = {
        label = 'Anti-Rad Pills',
        weight = 0.05,
        type = 'medical',
        description = 'Helps to remove radiation from the body.'
    },

    -- Материалы
    ['scrap_metal'] = {
        label = 'Scrap Metal',
        weight = 2.0,
        type = 'material',
        description = 'Rusty pieces of metal, useful for crafting.'
    },
    ['electronic_parts'] = {
        label = 'Electronic Parts',
        weight = 0.5,
        type = 'material',
        description = 'Components from old devices.'
    },
    ['credits'] = {
        label = 'Credits',
        weight = 0.0,
        type = 'currency',
        description = 'Exchange tokens used in the colony.'
    },
    ['ammo_pistol'] = {
        label = 'Pistol Ammo',
        weight = 0.02,
        type = 'ammo',
        description = 'Standard pistol ammunition.'
    },

    -- Топливо
    ['fuel_can'] = {
        label = 'Fuel Canister',
        weight = 5.0,
        type = 'fuel',
        description = 'Gasoline, the blood of the machines.'
    },

    -- Оружие
    ['weapon_pistol'] = {
        label = 'Makeshift Pistol',
        weight = 1.5,
        type = 'weapon',
        description = 'A crude but functional handgun.'
    },
    ['weapon_smg'] = {
        label = 'Scrap SMG',
        weight = 2.4,
        type = 'weapon',
        description = 'Lightweight SMG built from scrap.'
    },
    ['weapon_assaultrifle'] = {
        label = 'Rebuilt AR',
        weight = 3.6,
        type = 'weapon',
        description = 'Rusted AR rebuilt for survival.'
    },
    ['weapon_pumpshotgun'] = {
        label = 'Rusty Shotgun',
        weight = 4.2,
        type = 'weapon',
        description = 'Old shotgun that still kicks hard.'
    }
}

-- Настройки базы данных
Config.SaveInterval = 5 -- Интервал сохранения в БД (минуты)










