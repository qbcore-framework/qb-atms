fx_version 'cerulean'
game 'gta5'

description 'QB-ATM'
version '1.0.0'

server_scripts {
    'config.lua',
    'locales/*.lua',
    'config/main.lua',
    'server/main.lua'
}

client_scripts {
    'config/main.lua',
    'client/main.lua',
    'client/nui.lua'
}

ui_page 'nui/index.html'

files {
    'nui/images/logo1.png',
    'nui/images/logo.png',
    'nui/images/visa.png',
    'nui/images/mastercard.png',
    'nui/scripting/jquery-ui.css',
    'nui/scripting/external/jquery/jquery.js',
    'nui/scripting/jquery-ui.js',
    'nui/style.css',
    'nui/index.html',
    'nui/qb-atms.js',
}