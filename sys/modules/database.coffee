
Nedb = require 'nedb'

class NB.Database
	constructor: ->
		@nedb = new Nedb(
			filename: NB.conf.db_filename
			autoload: true
		)

		# Auto compact every week.
		@nedb.persistence.setAutocompactionInterval(1000 * 60 * 60 * 24 * 7)
