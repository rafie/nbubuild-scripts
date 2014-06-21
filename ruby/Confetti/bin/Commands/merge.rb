
require 'commander/import'
require 'Confetti'

module Confetti
module Commands

class Merge
	def Merge.command(c)
		c.syntax = 'tt merge [options]'
		c.summary = 'Invoke merge manager'
		c.description = ''
		c.example 'description', 'command example'
		c.option '--some-switch', 'Some switch that does something'

		c.action Merge
	end

	def initialize(args, options)
	end
end

end # Commands
end # Confetti
