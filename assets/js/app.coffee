class NB.Nobone
	constructor: ->
		@init_underscore()
		@init_global_tooltip()

		if NB.conf.auto_reload_page
			@init_auto_reload_page()

	init_underscore: ->
		_.mixin _.str.exports()
		_.str.include 'Underscore.string', 'string'

		_.templateSettings = {
			evaluate    : /<\?([\s\S]+?)\?>/g
			interpolate : /<\?=([\s\S]+?)\?>/g
			escape      : /<\?-([\s\S]+?)\?>/g
		}

	init_global_tooltip: ->
		$('body').on('mouseenter', '[title]', ->
			$this = $(this)
			$this.tooltip(
				container: 'body'
				placement: 'auto'
				animation: false
			)
			$this.tooltip('show').removeAttr('title')
		)

	init_auto_reload_page: ->
		init = ->
			sock = io.connect(location.origin + '/auto_reload_page')
			sock.on 'code_reload', (path) ->
				location.reload()

		require ['/socket.io/socket.io.js'], init
