_ = require 'underscore'
Q = require 'q'
fs = require 'fs-extra'
graceful = require 'graceful-fs'
child_process = require 'child_process'
glob = require 'glob'

module.exports =

	spawn: (cmd, args = [], options = {}) ->
		deferred = Q.defer()

		opts = _.defaults options, { stdio: 'inherit' }

		ps = child_process.spawn cmd, args, opts

		ps.on 'error', (data) ->
			deferred.reject data

		ps.on 'close', (code) ->
			deferred.resolve code

		return deferred.promise

	exists: (path) ->
		deferred = Q.defer()
		fs.exists path, (exists) ->
			deferred.resolve exists
		return deferred.promise

	path: require 'path'

	# Use graceful-fs to prevent os max open file limit error.
	readFile: Q.denodeify graceful.readFile
	outputFile: Q.denodeify fs.outputFile
	copy: Q.denodeify fs.copy
	rename: Q.denodeify fs.rename
	remove: Q.denodeify fs.remove
	chmod: Q.denodeify fs.chmod
	glob: Q.denodeify glob
