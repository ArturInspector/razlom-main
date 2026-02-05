fx_version 'cerulean'
game 'gta5'

name 'apo_mobs'
description 'Razlom — Базовая система мобов'
author 'Razlom Team'
version '1.0.0'

dependencies {
    'apo_core',
    'apo_inventory'
}

shared_scripts {
    'config.lua',
    'config_scenarios.lua'
}

server_scripts {
    'server/*.lua'
}

client_scripts {
    'client/*.lua'
}

lua54 'yes'





