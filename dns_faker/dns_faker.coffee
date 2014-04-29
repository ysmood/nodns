ndns = require 'native-dns'
dns = require 'dns'
_ = require 'underscore'
Q = require 'q'
minimatch = require 'minimatch'
request = require 'request'

class NDS.Dns_faker extends NB.Module
	constructor: ->
		super

		@init_dns_server()

		NB.app.get '/', @rule_editor
		NB.app.post '/put_rule_list', @put_rule_list

		@set_static_dir('dns_faker', '/dns_faker')

	rule_editor: (req, res) =>
		data = {
			title: @constructor.name.toLowerCase()
			head: @r.render('assets/ejs/head.ejs')
			foot: @r.render('assets/ejs/foot.ejs')
		}

		@get_user_list().done (user_list) =>
			@get_rule_list().done (rule_list) =>
				data.rule_list = rule_list or []
				data.rule_list.forEach (el) -> delete el._id
				data.user_list = user_list.map (el) -> el.username

				res.send @r.render("dns_faker/ejs/rule_editor.ejs", data)

	put_rule_list: (req, res) =>
		nedb = NB.database.nedb
		nedb.remove { type: 'dns_rule' }, { multi: true }, (err, num) ->
			nedb.insert req.body, (err) ->
				if err
					res.send 500
				else
					res.send 200

	get_user_list: ->
		deferred = Q.defer()

		request NB.conf.api.get_all_user, (err, res, body) ->
			try
				list = JSON.parse body
				deferred.resolve list
			catch e
				deferred.resolve []

		deferred.promise

	get_user_ip: (name) ->
		deferred = Q.defer()

		request NB.conf.api.get_user_addr + name, (err, res, body) ->
			try
				info = JSON.parse body
				deferred.resolve info.ip_addr
			catch e
				deferred.reject e

		return deferred.promise

	get_rule_list: ->
		deferred = Q.defer()

		NB.database.nedb.find { type: 'dns_rule' }, (err, docs) ->
			deferred.resolve docs

		deferred.promise

	map_dns: (domain) =>
		deferred = Q.defer()

		@get_rule_list().done (rule_list) =>

			rule = _.find rule_list, (el) ->
				minimatch(domain, el.pattern)

			if not rule
				deferred.resolve null
				return

			if rule.to_user
				@get_user_ip(rule.to_user)
				.catch (e) ->
					deferred.reject e
				.done (ip) ->
					deferred.resolve ip
			else
				deferred.resolve rule.to

		return deferred.promise

	resolve: (req, res) =>
		domain = req.question[0].name

		Q.fcall =>
			@map_dns domain
		.catch (e) ->
			console.error e
			return
		.then (addr) =>
			if addr
				res.answer.push ndns.A {
					name: domain
					address: addr
					ttl: 300
				}
				res.send()
			else
				dns.resolve req.question[0].name, (err, addr) ->
					if err
						console.error err
					else
						res.answer.push ndns.A {
							name: domain
							address: addr[0] + ''
							ttl: 300
						}
					res.send()
			return
		.done()

	init_dns_server: ->
		server = ndns.createServer()

		server.on 'request', @resolve

		server.serve NB.conf.dns_port

		console.log ">> DNS server at port: #{NB.conf.dns_port}".cyan
