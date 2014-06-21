
require 'commander/import'
require 'Confetti'

module Confetti
module Commands

class NewVer
	def NewVer.command(c)
		c.syntax = 'tt newver [options]'
		c.summary = 'Create a new project version'
		c.description = ''
		c.example 'description', 'command example'
		c.option '--some-switch', 'Some switch that does something'

		c.action NewVer
	end

	def initialize(args, options)
	end
end

end # Commands
end # Confetti
