fx_version 'cerulean'
game 'gta5'

name 'apo_ui'
description 'Mad Max RP - UI System'
author 'Mad Max RP Team'
version '1.0.0'

-- Зависимости
dependencies {
    'apo_core'
}

-- Общие скрипты
shared_scripts {
    'config.lua'
}

-- Клиентские скрипты
client_scripts {
    'client/*.lua'
}

-- UI файлы
ui_page 'ui/index.html'

files {
    'ui/index.html',
    'ui/css/*.css',
    'ui/js/*.js',
    'ui/assets/**/*'
}

-- Lua 5.4
lua54 'yes'

