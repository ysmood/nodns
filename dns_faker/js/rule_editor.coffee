class NDS.Rule_editor
	constructor: ->
		@init_editor()

	init_editor: ->
		@$editor = $('#rule_editor')
		@editor = new JSONEditor @$editor[0], {
			theme: 'bootstrap3'
			iconlib: 'fontawesome4'
			startval: NDS.rule_list

			schema: {
				type: 'array'
				title: 'DNS Rule List'
				items: {
					title: 'Rule'
					type: 'object'
					format: 'grid'
					properties: {
						pattern: {
							type: 'string'
							description: 'How to match the IP. Syntax doc https://github.com/isaacs/minimatch.'
							pattern: ".+"
						}
						to_user: {
							type: 'string'
							description: 'The user name, the name will automatically convert to IP of the user.'
							pattern: "(^[^\\s]+$)|(^$)"
						}
						to: {
							type: 'string'
							description: 'The target IP. If the "to_user" is set, this value won\'t take effect.'
							pattern: "(^\\d+\\.\\d+\\.\\d+\\.\\d+$)|(^$)"
						}
						type: {
							type: 'string'
							default: 'dns_rule'
							readonly: true
							visible: false
						}
					}
				}
			}
		}

	submit_rule_list: (btn) =>
		errors = @editor.validate()

		if errors.length
			for err in errors
				_.notify {
					info: "The value of the path is invalid: #{err.path}"
					class: 'red'
					delay: 3000
				}
			return

		btn.disabled = true

		$.ajax({
			type: 'POST'
			url: '/put_rule_list'
			data: JSON.stringify @editor.getValue()
			contentType: 'application/json'
		}).done (data) ->
			if data == 'OK'
				_.notify {
					info: 'Applied!'
					class: 'green'
					delay: 1000
				}
		.always ->
			btn.disabled = false

