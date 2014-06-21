require 'Bento'
require 'wiki_creole'
require 'erb'

#----------------------------------------------------------------------------------------------

class MarkupFile
	def initialize(fname)
		@last_line = 0
		@jojo = 10
		@lines = []

		file = File.new(fname, "r")
		file.each_line {|line| @lines.push line.chomp}
	end

	class Record
		attr_reader :header, :items, :last_line

		def initialize(lines, last)
			in_header = true
			in_body = false
			item = []
			@items = []
			@last_line = last
			lines.drop(last).each_with_index do |line, i|
				if in_header
					if header?(line)
						@header = line
						in_header = false
						in_body = true
					elsif !line.empty?
						throw "record: bad format"
					end
				elsif in_body
					if line.empty?
						next
					elsif header?(line)
						@items.concat item
						@last_line += i
						return
					elsif header?(line)
						@items.concat item
						item = []
					end
					item.push line
				end
			end
			@items.concat item
			@last_line = -1
		end
		
		def header?(line)
			line =~ /=.*/
		end

		def title
			@header =~ /= (.*)/
			$1
		end
	end

	def record
		if @last_line >= @lines.count || @last_line == -1
			return nil
		end
		r = Record.new(@lines, @last_line)
		@last_line = r.last_line
		return r
	end
end

#----------------------------------------------------------------------------------------------

class ChangesFile < MarkupFile
	def initialize(fname)
		super(fname)
	end
end

#----------------------------------------------------------------------------------------------

class NotesFile < MarkupFile
	attr_reader :notes, :known_issues

	def initialize(fname)
		super(fname)
		@notes = []
		@known_issues = []

		while (r = record) != nil
			@notes.concat r.items if r.title == "Notes"
			@known_issues.concat r.items if r.title == "Known issues"
		end

	end
end

#----------------------------------------------------------------------------------------------

class ChangelogFile
	def initialize(fname)
	end

	def addHeader(t)
	end
	
	def addItems(items)
	end
end

#----------------------------------------------------------------------------------------------

class Product
	attr_reader :dir, :changes, :notes, :known_issues, :lots, :pretty_name, :version,
		:notes_num, :known_issues_num, :changes_num
	
	def initialize(name)
		@name = name
		@dir = "../../" + name + "/Doc";
		@pretty_name = File.open(@dir + "/NAME").first.chomp
		@version = File.open(@dir + "/VERSION").first.chomp
		
		@notes_num = 0
		@known_issues_num = 0
		@changes_num = 0

		@lots = []
		File.open(@dir + "/LOTS").readlines.each do |line|
			next if line =~ /^#.*/
			args = line.split(" ")
			next if !args.length

			lot = args[0]
			lot_dir = args[1]
			if (lot_dir == nil)
				lot = Lot.new(lot)
			else
				lot = Lot.new(lot, lot_dir)
			end
			@lots.push lot
			@notes_num += lot.notes.length
			@known_issues_num += lot.known_issues.length
			@changes_num += lot.changes.length
		end

		changes_file = ChangesFile.new(@dir + "/CHANGES")
		@changes = []
		while (r = changes_file.record) != nil
			@changes.concat r.items
		end
		@changes_num += @changes.length

		notes_file = NotesFile.new(@dir + "/NOTES")
		@notes = notes_file.notes
		@notes_num += @notes.length
		@known_issues = notes_file.known_issues
		@known_issues_num += @known_issues.length
	end

	def changelog
		template = %{
{{<%= dir %>/logo.png}}
= <%= pretty_name %> <%= version %>
----

== Notes
<% if @notes_num > 0 %>
<%= a2s notes %>
<% @lots.each do |lot| %>
<% next if lot.notes.length == 0 %>

=== <%= lot.pretty_name %>
<%= a2s lot.notes %>
<% end %>
<% else %>
* (None)
<% end %>

----

== Known issues
<% if @known_issues_num > 0 %>
<%= a2s known_issues %>
<% @lots.each do |lot| %>
<% next if lot.known_issues.length == 0 %>

=== <%= lot.pretty_name %>
<%= a2s lot.known_issues %>
<% end %>
<% else %>
* (None)
<% end %>

----

== Changes
<%= a2s changes %>
<% if @changes_num > 0 %>
<% @lots.each do |lot| %>
<% if lot.changes.length > 0 %>

=== <%= lot.pretty_name %>
<%= a2s lot.changes %>
<% end %>
<% end %>
<% else %>
* (None)
<% end %>
}
		ERB.new(template, 0, "%<>").result(binding)
	end
	
	def html
		WikiCreole.creole_parse(changelog)
	end
end

#----------------------------------------------------------------------------------------------

class Lot
	attr_reader :changes, :notes, :known_issues, :pretty_name

	def initialize(name, dir = "")
		@name = name
		@dir = "../../" + (dir == "" ? "/" + name : dir) + "/Doc";
		
		@pretty_name = File.open(@dir + "/NAME").first.chomp
		
		
		changes_file = ChangesFile.new(@dir + "/CHANGES")
		@changes = []
		while (r = changes_file.record) != nil
			@changes.concat r.items
		end

		notes_file = NotesFile.new(@dir + "/NOTES")
		@notes = notes_file.notes
		@known_issues = notes_file.known_issues
	end
end

#----------------------------------------------------------------------------------------------

def f1
	prod = Product.new("nbu.prod.mcu")
	x = prod.html
#	x = prod.changelog
	puts x
end

#----------------------------------------------------------------------------------------------

def a2s(a)
	a.count > 0 ? a * "\n" + "\n" : ""
end

#----------------------------------------------------------------------------------------------

f1
