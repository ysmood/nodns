NB.conf = {

	api: {
		get_user_addr: 'http://bd.ysmood.org:8572/api/user_addr/get/'
		get_all_user: 'http://bd.ysmood.org:8572/api/user_addr/get_all'
	}

	port: 8013

	dns_port: 53

	debug_port: 8014

	# IF 'auto_reload_page' is enabled, it will be auto enabled.
	enable_socket_io: false

	# If 'mode' is 'production', it will be disabled.
	auto_reload_page: true

	modules: {
		'NB.Database': './sys/modules/database'
		'NDS.Dns_faker': './dns_faker/dns_faker'
	}

	db_filename: 'var/NB.db'

	load_langs: ['en']

	current_lang: ['en']

	mode: 'development'

}

if NB.conf.mode == 'production'
	NB.conf.auto_reload_page = false

if NB.conf.auto_reload_page
	NB.conf.enable_socket_io = true

NB.conf.client_conf = {

	enable_socket_io: NB.conf.enable_socket_io
	auto_reload_page: NB.conf.auto_reload_page
	current_lang: NB.conf.current_lang
	load_langs: NB.conf.load_langs
	mode: NB.conf.mode

}
