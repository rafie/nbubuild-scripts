
require 'commander/import'
require 'Confetti'

module Confetti
module Commands

class Release
	def Release.command(c)
		c.syntax = 'tt release [options]'
		c.summary = 'Release project'
		c.description = ''
		c.example 'description', 'command example'
		c.option '--some-switch', 'Some switch that does something'

		c.action Release
	end

	def initialize(args, options)
	end
end

end # Commands
end # Confetti
