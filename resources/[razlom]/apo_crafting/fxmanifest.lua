fx_version 'cerulean'
game 'gta5'

name 'apo_crafting'
description 'Razlom — Базовый крафтинг'
author 'Razlom Team'
version '1.0.0'

dependencies {
    'apo_core',
    'apo_inventory',
    'apo_ui'
}

shared_scripts {
    'config.lua'
}

server_scripts {
    'server/*.lua'
}

client_scripts {
    'client/*.lua'
}

lua54 'yes'

