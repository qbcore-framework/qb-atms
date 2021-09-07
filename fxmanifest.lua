fx_version 'cerulean'
game 'gta5'

description 'QB-ATM'
version '1.0.0'

shared_scripts { 
	'@qb-core/import.lua',
	'config.lua'
}

client_script 'client/main.lua'
server_script 'server/main.lua'

ui_page 'html/index.html'

files {
    'html/images/*.png',
    'html/scripting/jquery-ui.css',
    'html/scripting/external/jquery/jquery.js',
    'html/scripting/jquery-ui.js',
    'html/style.css',
    'html/index.html',
    'html/atms.js'
}
