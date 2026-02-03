fx_version 'cerulean'
game 'gta5'

name 'apo_reputation'
description 'Razlom — Фракции и репутация'
author 'Razlom Team'
version '1.0.0'

dependencies {
    'apo_core',
    'apo_ui',
    'apo_player',
    'apo_progression'
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

