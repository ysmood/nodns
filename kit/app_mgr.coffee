#!node_modules/.bin/coffee

require 'colors'
Q = require 'q'
os = require '../sys/os'

# Path variables.
coffee_bin = 'node_modules/.bin/coffee'
forever_bin = 'node_modules/.bin/forever'
app_path = process.cwd() + '/nobone.coffee'

switch process.argv[2]
	when 'setup'
		conf_path = 'var/config.coffee'
		example_path = 'kit/config.example.coffee'

		Q.fcall ->
			console.log ">> Install bower...".cyan
			os.spawn 'node_modules/.bin/bower', ['--allow-root', 'install']
		.then ->
			os.exists conf_path
		.then (exists) ->
			if exists
				console.log ">> Config file auto created.".cyan
				os.copy example_path, conf_path
		.done ->
			console.log '>> Setup finished.'.yellow

	when 'test'
		# Redirect process io to stdio.
		os.spawn coffee_bin, [app_path]

	when 'debug'
		global.NB = {}
		require '../var/config'
		os.spawn(
			coffee_bin
			['--nodejs', '--debug-brk=' + NB.conf.debug_port, app_path]
		)

	when 'start'
		os.spawn(
			forever_bin
			[
				'start'
				'--minUptime', '5000', '--spinSleepTime', '5000' # uptime
				'-a', '-o', 'var/log/std.log', '-e', 'var/log/err.log' # log
				'-c', coffee_bin, app_path
			]
		)

	when 'stop'
		os.spawn forever_bin, ['stop', app_path]

	else
		console.error '>> No such command: ' + process.argv[2].red
