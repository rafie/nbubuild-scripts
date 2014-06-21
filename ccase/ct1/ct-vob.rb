#!/usr/bin/env ruby

require 'rubygems'
require 'win32/Console/ANSI' if RUBY_PLATFORM =~ /mingw/
require 'commander/import'

require 'Bento'
require 'pp'

HighLine::use_color = false

program :name, 'ct1 vob'
program :version, '1.0.0'
program :description, 'Extended VOB operations'
 
command :new do |c|
	c.syntax = 'ct1 vob new [options] vob-name'
	c.summary = 'Create a new VOB'
	c.description = 'Create a new VOB'
	c.example "Create VOB named 'V1'", 'ct1 vob new v1'
	c.example "Create VOB named 'v1' from archive file 'v1.vob.zip'", 'ct1 vob new --arc v1.vob.zip v1.zip'
	c.option '--name NAME', 'VOB name'
	c.option '--arc FILE', 'VOB archive file'
	c.option '--jazz', 'Make VOB name partially random'
	c.action do |args, options|
		cmd_options = {}
		cmd_flags = []

		name = args.shift
		name = options.name if !name && !!options.name
		raise "missing VOB name" if !name

		name = ClearCASE::VOB.jazz_name(name) if options.jazz		
		say "Creating VOB #{name} ..."
		if !options.arc
			vob = ClearCASE::VOB.create({name: name}, cmd_flags)
		else
			vob = ClearCASE::VOB.unpack({name: name, file: options.arc}, cmd_flags)
		end
		say "VOB #{name} created."
	end
end

command :rm do |c|
	c.syntax = 'ct1 vob rm [options] vob-name'
	c.summary = 'Remove a VOB'
	c.description = 'Removes a new VOB, optionally creating a VOB archive file'
	c.example "Remove VOB named 'V1'", 'ct1 vob rm v1'
	c.option '--name NAME', 'VOB name'
	c.option '--arc FILE', 'VOB archive file'
	c.action do |args, options|
		name = args.shift
		name = options.name if !name && !!options.name
		raise "missing VOB name" if !name
		
		vob = ClearCASE::VOB.new(name)
		if !!options.arc
			file = options.arc
			say "Archiving VOB #{name} into #{file} ..."
			vob.pack(file)
		end
		say "Removing VOB #{name} ..."
		vob.remove!
		say "VOB #{name} removed."
	end
end

command :arc do |c|
	c.syntax = 'ct1 arc [options] vob-name'
	c.summary = 'Archive a VOB'
	c.description = 'Archive a VOB.'
	c.example "Create archive file from VOB named 'V1'", 'ct1 vob pack --arc v1.vob.zip v1'
	c.option '--name NAME', 'VOB name'
	c.option '--arc FILE', 'VOB archive file'
	c.action do |args, options|
		name = args.shift
		name = options.name if !name && !!options.name
		raise "missing VOB name" if !name
		packed_vob = ClearCASE::PackedVOB.create(name: options.name, file: options.arc)
		say "Created archive file #{options.arc} from VOB #{name}."
	end
end
