fx_version 'cerulean'
game 'gta5'

name "esx_truckingjob"
description "An advanced Trucking Job for the ESX-Framework"
author "ESX-Framework"
lua54 'yes'
version "1.0.0"

shared_scripts {
	'@es_extended/locale.lua',
	'locales/*.lua',
	'@es_extended/imports.lua',
	'shared/*.lua'
}

client_scripts {
	'client/modules/*.lua',
	'client/*.lua',
}

server_scripts {
	'server/modules/*.lua',
	'server/*.lua'
}
