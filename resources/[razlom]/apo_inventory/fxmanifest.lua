fx_version 'cerulean'
game 'gta5'

name 'apo_inventory'
description 'Mad Max RP - Inventory System'
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
    'server/*.lua'
}

client_scripts {
    'client/*.lua'
}

lua54 'yes'

-- Exports
exports {
    'addItem',
    'removeItem',
    'hasItem',
    'getInventory',
    'getItemCount'
}










