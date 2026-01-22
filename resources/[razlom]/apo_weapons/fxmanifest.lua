fx_version 'cerulean'
game 'gta5'

name 'apo_weapons'
description 'Razlom - Система оружия с редкостью и аттачментами'
author 'Razlom Team'
version '1.0.0'

dependencies {
    'apo_core',
    'apo_inventory',
    'apo_signal'
}

shared_scripts {
    'config.lua',
    'shared/*.lua'
}

server_scripts {
    'server/*.lua'
}

client_scripts {
    'client/*.lua'
}

lua54 'yes'

