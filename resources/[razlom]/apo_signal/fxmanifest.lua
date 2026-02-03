fx_version 'cerulean'
game 'gta5'

name 'apo_signal'
description 'Razlom — Система шума: направленный спавн по выстрелам'
author 'Razlom Team'
version '1.0.0'

dependencies {
    'apo_mobs'
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

