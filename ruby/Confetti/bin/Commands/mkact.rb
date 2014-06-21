
require 'commander/import'
require 'Confetti'

module Confetti
module Commands

class MkAct
	def MkAct.command(c)
		c.syntax = 'tt mkact [options] name'
		c.summary = 'Create a new activity'
		c.description = 'Create a new activity'

		c.example "Create activity named 'ACT'", 'tt mkact ACT'
		c.example "Create activity named 'ACT'", 'tt mkact --name ACT'

		c.option '--name NAME', 'Activity name'
		c.option '--raw', 'Do not add username prefix'

		c.action MkAct
	end

	def initialize(args, options)
		flags = []

		name = args.shift
		name = options.name if !name && !!options.name
		raise "missing activity name" if !name

		flags << :raw if options.raw

		say "Creating activity #{name} ..."
		
		act_args = {name: name}
		act_args[:project] = options.project if options.project
		act = Confetti::Activity.create(act_args, *flags)
		
		say "Activity #{name} created."
	end
end

end # Commands
end # Confetti
