fx_version 'cerulean'
game 'gta5'

name 'apo_zones'
description 'Razlom — Система зонирования Sandy Shores'
author 'Razlom Team'
version '1.0.0'

dependencies {
    'apo_core',
    'apo_ui',
    'apo_invasion'
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

