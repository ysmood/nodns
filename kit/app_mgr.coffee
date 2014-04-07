#!node_modules/.bin/coffee

child_process = require 'child_process'
Q = require 'q'
fs = require 'fs-extra'

# Path variables.
coffee_bin = 'node_modules/.bin/coffee'
forever_bin = 'node_modules/.bin/forever'
app_path = process.cwd() + '/nobone.coffee'

spawn = (cmd, args) ->
	deferred = Q.defer()

	ps = child_process.spawn cmd, args, { stdio: 'inherit' }

	ps.on 'error', (data) ->
		deferred.reject data

	ps.on 'close', (code) ->
		deferred.resolve code

	return deferred.promise

switch process.argv[2]
	when 'setup'
		Q.fcall ->
			spawn 'npm', ['install']
		.then ->
			spawn 'node_modules/.bin/bower', ['--allow-root', 'install']
		.then ->
			# Auto create config file.
			example_path = 'kit/config.example.coffee'
			path = 'var/config.coffee'
			if not fs.existsSync(path)
				fs.copySync example_path, path
		.done ->
			console.log '>> Setup finished.'

	when 'test'
		# Redirect process io to stdio.
		spawn coffee_bin, [app_path]

	when 'debug'
		global.NB = {}
		require '../var/config'
		spawn(
			coffee_bin
			['--nodejs', '--debug-brk=' + NB.conf.debug_port, app_path]
		)

	when 'start'
		spawn(
			forever_bin
			[
				'start'
				'--minUptime', '5000', '--spinSleepTime', '5000' # uptime
				'-a', '-o', 'var/log/std.log', '-e', 'var/log/err.log' # log
				'-c', coffee_bin, app_path
			]
		)

	when 'stop'
		spawn forever_bin, ['stop', app_path]

	else
		console.error '>> No such command: ' + process.argv[2]
