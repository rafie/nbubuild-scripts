
require 'commander/import'
require 'Confetti'

module Confetti
module Commands

class Build
	def Build.command(c)
		c.syntax = 'tt build [options]'
		c.summary = 'Build project'
		c.description = ''
		c.example 'description', 'command example'
		c.option '--some-switch', 'Some switch that does something'

		c.action Build
	end

	def initialize(args, options)
	end
end

end # Commands
end # Confetti
