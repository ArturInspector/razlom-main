fx_version 'cerulean'
game 'gta5'

name 'apo_player'
description 'Mad Max RP - Система игроков'
author 'Mad Max RP Team'
version '1.0.0'

dependencies {
    'apo_core',
    'oxmysql'
}

shared_scripts {
    'config.lua',
    'shared/*.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/*.lua'
}

client_scripts {
    'client/*.lua'
}

lua54 'yes'










