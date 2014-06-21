
require 'commander/import'
require 'Confetti'

module Confetti
module Commands

class NoMerge
	def NoMerge.command(c)
		c.syntax = 'tt nomerge [options]'
		c.summary = 'Mark element or version as non-mergable'
		c.description = 'Mark element or version as non-mergable. This command operates from whithin a view.'
		c.example 'description', 'ct unmerge --element m:\view\vob\file'
		c.option '--element NAME', 'Some switch that does something'
		c.option '--version NAME', 'Some switch that does something'

		c.action NoMerge
	end

	def initialize(args, options)
	end
end

end # Commands
end # Confetti
