NB.conf = {

	port: 8013

	debug_port: 8014

	# IF 'auto_reload_page' is enabled, it will be auto enabled.
	enable_socket_io: false

	# If 'mode' is 'production', it will be disabled.
	auto_reload_page: true

	modules: {
		'NB.Database': './sys/modules/database'
		'NB.Storage': './sys/modules/storage'
		'NB.Api': './sys/modules/api'
	}

	db_filename: 'var/NB.db'

	load_langs: ['en', 'cn']

	current_lang: ['cn']

	mode: 'development'

}

NB.conf.client_conf = {

	enable_socket_io: NB.conf.enable_socket_io
	auto_reload_page: NB.conf.auto_reload_page
	current_lang: NB.conf.current_lang
	load_langs: NB.conf.load_langs
	mode: NB.conf.mode

}

if NB.conf.mode == 'production'
	NB.conf.auto_reload_page = false

if NB.conf.auto_reload_page
	NB.conf.enable_socket_io = true
