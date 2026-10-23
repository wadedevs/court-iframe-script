fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'fivem-iframe'
description 'Show any website in an in-game panel. Sites, commands and permissions come from config.lua.'
version '2.0.0'

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/style.css',
    'html/app.js',
}

shared_script 'config.lua'

server_scripts {
    'server/sha256.lua',
    'server/embed.lua',
    'server/server.lua',
}

client_script 'client/client.lua'
