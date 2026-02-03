fx_version 'cerulean'
game 'gta5'

name 'apo_economy'
description 'Razlom — Базовая экономика и магазин'
author 'Razlom Team'
version '1.0.0'

dependencies {
    'apo_core',
    'apo_ui',
    'apo_inventory',
    'apo_invasion',
    'apo_reputation'
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

