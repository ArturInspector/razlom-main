Config = Config or {}

Config.Debug = true

Config.Rarity = {
    common = {label = 'Common', color = 'white', bonus = 0.0},
    rare = {label = 'Rare', color = 'blue', bonus = 0.10},
    legendary = {label = 'Legendary', color = 'orange', bonus = 0.25}
}

Config.Weapons = {
    ['weapon_pistol'] = {
        label = 'Makeshift Pistol',
        hash = `WEAPON_PISTOL`,
        weight = 1.5,
        noise_level = 3,
        rarity_weights = {common = 70, rare = 25, legendary = 5},
        stats = {damage = 25, accuracy = 0.7, range = 50, fire_rate = 0.30},
        allowed_attachments = {'scope_basic', 'mag_extended', 'suppressor'}
    },
    ['weapon_smg'] = {
        label = 'Scrap SMG',
        hash = `WEAPON_SMG`,
        weight = 2.4,
        noise_level = 6,
        rarity_weights = {common = 60, rare = 30, legendary = 10},
        stats = {damage = 22, accuracy = 0.65, range = 80, fire_rate = 0.10},
        allowed_attachments = {'scope_basic', 'mag_extended', 'grip', 'suppressor'}
    },
    ['weapon_assaultrifle'] = {
        label = 'Rebuilt AR',
        hash = `WEAPON_ASSAULTRIFLE`,
        weight = 3.6,
        noise_level = 7,
        rarity_weights = {common = 55, rare = 30, legendary = 15},
        stats = {damage = 30, accuracy = 0.72, range = 120, fire_rate = 0.11},
        allowed_attachments = {'scope_advanced', 'mag_extended', 'grip', 'armor_plating'}
    },
    ['weapon_pumpshotgun'] = {
        label = 'Rusty Shotgun',
        hash = `WEAPON_PUMPSHOTGUN`,
        weight = 4.2,
        noise_level = 8,
        rarity_weights = {common = 65, rare = 25, legendary = 10},
        stats = {damage = 55, accuracy = 0.45, range = 35, fire_rate = 1.00},
        allowed_attachments = {'armor_plating', 'suppressor'}
    }
}

Config.Attachments = {
    ['scope_basic'] = {
        label = 'Scrap Scope',
        type = 'optic',
        model = 'prop_scope_01',
        bone = 'WAPClip',
        offset = vector3(0.0, 0.02, 0.08),
        rotation = vector3(0.0, 0.0, 0.0),
        stats_bonus = {accuracy = 0.10},
        rarity_required = 'common'
    },
    ['scope_advanced'] = {
        label = 'Refitted Scope',
        type = 'optic',
        model = 'prop_trevor_rope_01',
        bone = 'WAPClip',
        offset = vector3(0.0, 0.03, 0.1),
        rotation = vector3(0.0, 0.0, 0.0),
        stats_bonus = {accuracy = 0.15, range = 10},
        rarity_required = 'rare'
    },
    ['mag_extended'] = {
        label = 'Extended Mag',
        type = 'mag',
        model = 'prop_ld_ammo_pack_02',
        bone = 'WAPClip',
        offset = vector3(0.0, -0.02, -0.05),
        rotation = vector3(0.0, 0.0, 0.0),
        stats_bonus = {magazine = 15},
        rarity_required = 'common'
    },
    ['grip'] = {
        label = 'Front Grip',
        type = 'grip',
        model = 'prop_cs_dildo_01', -- простая рукоятка-плейсхолдер
        bone = 'WAPGrip',
        offset = vector3(0.0, 0.03, -0.08),
        rotation = vector3(0.0, 0.0, 0.0),
        stats_bonus = {recoil = -0.1},
        rarity_required = 'common'
    },
    ['suppressor'] = {
        label = 'Improvised Suppressor',
        type = 'barrel',
        model = 'prop_ld_flow_bottle',
        bone = 'WAPSupp',
        offset = vector3(0.0, 0.17, -0.02),
        rotation = vector3(0.0, 0.0, 0.0),
        stats_bonus = {noise = -2},
        rarity_required = 'rare'
    },
    ['armor_plating'] = {
        label = 'Armor Plating',
        type = 'armor',
        model = 'prop_armour_pickup',
        bone = 'WAPGrip',
        offset = vector3(0.0, -0.05, -0.02),
        rotation = vector3(0.0, 0.0, 90.0),
        stats_bonus = {durability = 0.30},
        rarity_required = 'rare'
    }
}

-- Построим обратную таблицу hash -> name для клиента
Config.HashToName = {}
for name, data in pairs(Config.Weapons) do
    Config.HashToName[data.hash] = name
end

