fx_version 'cerulean'
game 'gta5'

description 'QB-ATM'
version '1.0.0'


shared_scripts {
    '@qb-core/import.lua',
    'locales/*.lua',
    'config/main.lua'
}

server_script 'server/main.lua'

client_scripts {
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
    'nui/scripting/i18next-1.11.2.min.js',
    'nui/style.css',
    'nui/index.html',
     'nui/locales/it.json',
    'nui/locales/en.json',

}

