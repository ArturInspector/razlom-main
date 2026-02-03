fx_version 'cerulean'
game 'gta5'

name 'apo_tutorial'
description 'Razlom — Скриптовый онбординг'
author 'Razlom Team'
version '1.0.0'

dependencies {
    'apo_core',
    'apo_ui',
    'apo_inventory',
    'apo_mobs',
    'apo_zones',
    'apo_economy',
    'apo_crafting'
}

shared_scripts {
    'config.lua'
}

server_scripts {
    'server/main.lua'
}

client_scripts {
    'client/main.lua'
}

lua54 'yes'

