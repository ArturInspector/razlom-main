Config = Config or {}

Config.Recipes = {
    bandage = {
        label = 'Бинт',
        inputs = {
            { item = 'canned_food', count = 1 },
            { item = 'water', count = 1 }
        },
        output = { item = 'bandage', count = 1 },
        time = 3000
    },
    medkit = {
        label = 'Аптечка',
        inputs = {
            { item = 'bandage', count = 2 },
            { item = 'water', count = 1 }
        },
        output = { item = 'medkit', count = 1 },
        time = 5000
    },
    antirad = {
        label = 'Антирад',
        inputs = {
            { item = 'water', count = 1 },
            { item = 'electronic_parts', count = 1 }
        },
        output = { item = 'antirad', count = 1 },
        time = 4000
    },
    weapon_pistol = {
        label = 'Самодельный пистолет',
        inputs = {
            { item = 'scrap_metal', count = 2 },
            { item = 'electronic_parts', count = 1 }
        },
        output = { item = 'weapon_pistol', count = 1 },
        time = 7000
    }
}

