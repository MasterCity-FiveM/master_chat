fx_version 'adamant'
game 'gta5'

name 'master_chat'
author 'MasterkinG32#9999'
description 'MasterkinG32 Chat System!'
version '1.0.0'

ui_page 'html/ui.html'

client_scripts {
	'client/*.lua'
}

server_scripts {
	'server/main.lua',
}

files {
	'html/ui.html',
	'html/css/*.css',
	'html/js/*.js',
}

dependencies {
	'es_extended'
}
