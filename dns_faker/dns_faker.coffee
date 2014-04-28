ndns = require 'native-dns'
dns = require 'dns'

class NDS.Dns_faker extends NB.Module
	constructor: ->
		super

		@init_dns_server()

	map: (domain) ->
		return null

	resolve: (req, res) =>
		domain = req.question[0].name

		addr = @map domain
		if addr
			res.answer.push ndns.A {
				name: domain
				address: addr
				ttl: 300
			}
			res.send()

		dns.resolve req.question[0].name, (err, addr) ->
			if err
				console.log err
			else
				res.answer.push ndns.A {
					name: domain
					address: addr[0] + ''
					ttl: 300
				}
			res.send()

	init_dns_server: ->
		server = ndns.createServer()

		server.on 'request', @resolve

		server.serve NB.conf.dns_port

		console.log ">> DNS server at port: #{NB.conf.dns_port}".cyan
