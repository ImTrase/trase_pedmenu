fx_version 'cerulean'
games { 'gta5' }
author 'Trase#0001'
description 'FiveM Ped Menu'
version '1.0.2'
lua54 'yes'

client_scripts {
    'client/warmenu.lua',
    'client/client.lua'
}

server_scripts {
    'config.lua',
    'server/server.lua'
}

dependencies { 'trase_discord' }