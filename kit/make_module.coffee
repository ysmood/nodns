#! node_modules/.bin/coffee

Q = require 'Q'
_ = require 'underscore'
os = require '../sys/os'

if not process.argv[2]
	console.log 'Usage: make_module Namespace.Class_name'
	return

[namespace, class_name] = process.argv[2].split('.')

pname = class_name.toLowerCase()

Q.fcall ->
	os.remove pname
.then ->
	os.copy('kit/module_tpl', pname)
.then ->
	Q.all [
		os.rename(
			pname + '/client/css/module_tpl.styl'
			pname + "/client/css/#{pname}.styl"
		)
		os.rename(
			pname + '/client/js/module_tpl.coffee'
			pname + "/client/js/#{pname}.coffee"
		)
		os.rename(
			pname + '/client/ejs/module_tpl.ejs'
			pname + "/client/ejs/#{pname}.ejs"
		)
		os.rename(
			pname + '/module_tpl.coffee'
			pname + "/#{pname}.coffee"
		)
	]
.then ->
	os.readFile(pname + "/#{pname}.coffee", 'utf8')
.then (src) ->
	code = _.template(src, { class_name: process.argv[2] })
	os.outputFile(pname + "/#{pname}.coffee", code)
.done ->
	console.log '>> Module created: ' + process.argv[2]
