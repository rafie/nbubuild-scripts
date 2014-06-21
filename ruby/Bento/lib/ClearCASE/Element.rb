
require_relative 'Common'
require 'set'

#----------------------------------------------------------------------------------------------

module ClearCASE

#----------------------------------------------------------------------------------------------

class Element
	attr_reader :name

	def initialize(name)
		@name = Element.fix_name(name)
	end

	#------------------------------------------------------------------------------------------

	def to_s
		@name
	end

	def fullpath?
		Element.fullpath?(@name)
	end

	def fullpath
		Element.fullpath(@name)
	end
	
	# element path, without view name, but with an initial /
	def epath
		Element.epath(@name)
	end

	def view
		Element.view(@name)
	end

	def vob
		Element.vob(@name)
	end
	
	def in_vob?(vob)
		Element.in_vob(@name, vob)
	end

	def directory_closure
		Element.directory_closure(@name)
	end

	def under?(roots)
		Element.under?(@name, roots)
	end

	#------------------------------------------------------------------------------------------

	def Element.fix_name(name)
		name = name.chomp
		name.gsub!(/\\/, '/')
		name.gsub!(/\/+/, '/')
		# name = name[0..-3] if name.end_with?('/.')
		# the following are invalid: M: or M:/ or M:/view or M:/view/ or : not followed by /
		raise "invalid element name: #{name}" if name =~ /:[^\/]/ || name =~ /^[Mm]:[\/]?[^\/]*\/?$/
		name = $1 if name =~ /^(.+)\/.?$/
		name
	end

	# view, vob, epath
	# .vob(s) are special because they are considered a part of the view, thus elements of .vob(s) come
	#   in the form /view/.vob/vob/path

	def Element.parse(name)
		name = Element.fix_name(name)
		return [$1, $2, "/#{$2}#{$3}"] if name =~ /^[Mm]:[\/]([^\/]*[\/]\.[^\/]*)[\/]([^\/]*)([\/].*)/
																						   # M:/view/.vob/vob/path
		return [$1, $2, "/#{$2}"]      if name =~ /^[Mm]:[\/]([^\/]*[\/]\.[^\/]*)[\/]([^\/]*)$/
																						   # M:/view/.vob/vob
		return Element._std_parse(name)
	end

	def Element.std_parse(name)
		return Element._std_parse(Element.fix_name(name))
	end

	def Element._std_parse(name)
		return [$1, $2, "/#{$2}#{$3}"] if name =~ /^[Mm]:[\/]([^\/]*)[\/]([^\/]*)([\/].*)/ # M:/view/vob/path
		return [$1, $2, "/#{$2}"]      if name =~ /^[Mm]:[\/]([^\/]*)[\/]([^\/]*)$/        # M:/view/vob
		return ["", $1, "/#{$1}#{$2}"] if name =~      /^[\/]([^\/]*)([\/].*)/             # /vob/path
		return ["", $1, "/#{$1}"]      if name =~      /^[\/]([^\/]*)$/                    # /vob
		return ["", "", name]
	end

	def Element.fullpath?(name)
		(name =~ /^[Mm:]/) != nil
	end

	def Element.fullpath(name)
		return name if Element.fullpath?(name)
		d = Dir.pwd
		raise "cannot determine fullpath for #{name} (no view context)" if (d =~ /^[Mm]:/) == nil
		"#{d}/#{name}"
	end
	
	def Element.epath(name)
		view, vob, epath = Element.parse(name)
		epath
	end

	def Element.view(name)
		view, vob, epath = Element.parse(name)
		raise "cannot determine view for #{name} (no view context)" if view.empty?
		ClearCASE::View.new(view)
	end

	def Element.vob(name)
		view, vob, epath = Element.parse(name)
		raise "cannot determine VOB for #{name}" if vob.empty?
		ClearCASE::VOB.new(vob)
	end
	
	def Element.in_vob?(name, vob)
		vob_name = vob.is_a?(ClearCASE::VOB) ? vob.name : ClearCASE::VOB.new(vob).name
		Element.vob(name).name == vob_name
	end

	def Element.under?(name, roots)
		roots = [roots] if roots.is_a?(String)
		view, vob, epath = Element.parse(name)
		roots.each do |root| 
			return true if epath.start_with?(root)
		end
		return false
	end
	
	# Calculates the directory closure of this element - all the directories that compose its 
	# partial paths, up to but excluding the root.
	# for example, the closure for the element "/mcu/EC/Snmp/ecSnmpIvr.cpp" is:
	# /mcu
	# /mcu/EC
	# /mcu/EC/Snmp

	def Element.directory_closure(name)
		view, vob, p = Element.parse(name)
		closure = []
		loop do
			p, f = File.split(p)
			break if p == f
			closure << p if p != '/'
		end
		
		closure.map! { |name| "#{View.new(view).path}#{name}"} if  view != ""

		return Elements.new(closure)
	end

	#------------------------------------------------------------------------------------------

	def checkout
		# puts "Checking-out file: #{@name}..." if Bento::UserCommand::$verbose
		co = System.command("cleartool checkout -nc -ptime #{@name}")
		raise "cannot checkout #{name}" if co.failed?
	end

	#------------------------------------------------------------------------------------------

	def checkin
		# puts "Checking-in file: #{@name}..." unless !$VerboseMode
		ci = System.command("cleartool ci -nc -ptime #{@name}")
		return if ci.ok?

		if ci.status == 1 && ci.err0 == "cleartool: Error: By default, won't create version with data identical to predecessor."
			# puts "\tIdentical to predecessor: Undoing check-out on #{@name}" unless !$VerboseMode
			unco = System.command("cleartool unco -rm #{@name}")
		else
			raise "checkin failed for #{name}"
		end
	end

	#------------------------------------------------------------------------------------------

	def uncheckout
		unco = System.command("cleartool unco -rm #{@name}")
		raise "cannot uncheckout #{name}" if unco.failed?
	end

	#------------------------------------------------------------------------------------------

	# flags: :recursive, :replace
	#   :checkin, :keepco

	def label!(label_name, *flags)
		nocreate = flags.include?(:nocreate)
		recursive = flags.include?(:recursive)
		replace = flags.include?(:replace)

		ClearCASE::LabelType.create(label_name) if !nocreate
		mklabel = System.command("cleartool mklabel -nc #{recursive ? "-r" : ""} #{replace ? "-rep" : ""} #{label_name} #{@name}")
		raise "failed to apply label #{label_name} on element #{@name}" if mklabel.failed?
	end

	#------------------------------------------------------------------------------------------

	def checkedout?
		lsco = System.command("cleartool lsco -short #{@name}")
		return lsco.out0 == file
	end

	def changed?
		diff = System.command("cleartool diff -pred #{@name}")
		return diff.status == 0
	end

	#------------------------------------------------------------------------------------------
	
	# Attaches the attribute with the given name and value to this element.
	# note that the attribute is assumed to exist in the relevant VOB

	def [](attr)
		desc = System.command("cleartool describe -short -aattr #{attr} #{@name}@@")
		raise "error reading attribute #{attr} for element #{@name}" if desc.failed?
		s = desc.out0
		s = s[1..-2] if s[0] == '"' && s[-1] == '"'
		return s
	end
	
	#------------------------------------------------------------------------------------------

	def []=(attr, value)
		v = case
			when value.is_a?(Integer); value.to_s
			else; "\\\"#{value.to_s}\\\""
		end
		mkattr = System.command("cleartool mkattr -replace #{attr} #{v} #{@name}@@")
		raise "error setting attribute #{attr} to \"#{value}\" for element #{@name}" if mkattr.failed?
	end

end # Element

#----------------------------------------------------------------------------------------------

class Elements
	include Enumerable
	
	attr_reader :names

	def initialize(names)
		@names = names.map { |name| Element.fix_name(name) }
		# @names = names
	end

	def each
		@names.each { |fname| yield Element.new(fname) }
	end

	#------------------------------------------------------------------------------------------

	def empty?
		@names.empty?
	end

	def in_vob(vob)
		# in_vobs([vob])
		Elements.new(@names.reject { |name| ! ClearCASE::Element.in_vob?(name, vob) })
	end

	def in_vobs(vobs)
		e = []
		vobs.each { |vob| e.concat(@names.select { |name| ClearCASE::Element.in_vob?(name, vob) }) }
		Elements.new(e)
	end

	def under(roots)
		Elements.new(@names.reject { |name| ! ClearCASE::Element.under?(name, roots) })
	end

	#------------------------------------------------------------------------------------------

	def directory_closure
		closure = Set.new
		@names.each do |name|
			 closure.merge(Element.directory_closure(name).names)
		end
		Elements.new(closure.to_a)
	end

	def absolute_paths
		Elements.new(@names.map { |f| File.absolute_path(f) }.uniq.sort)
	end

	#------------------------------------------------------------------------------------------

	def checkin
		each { |e| e.checkin }
	end

	def checkout
		each { |e| e.checkout }
	end
	
	# flags:
	#   :recursive, :replace, :checkin, :keepco

	def label!(name, *flags)
		return if @names.empty?
		e1 = @names.first
		view, vob, epath = Element.parse(e1)
		root_vob = ClearCASE::View.new(view).root_vob

		nocreate = flags.include?(:nocreate)

		if !nocreate
			lbtype_args = {name: name}
			lbtype_args[:root_vob] = @root if @root
			ClearCASE::LabelType.create(lbtype_args)
		end

		label_flags = []
		label_flags << :recursive if flags.include?(:recursive)
		label_flags << :replace if flags.include?(:replace)
		label_flags << :checkin if flags.include?(:checkin)
		label_flags << :keepco if flags.include?(:keepco)

		label_args = {name: name}
		label_args[:root_vob] = root_vob.name if root_vob
		each { |e| e.label!(label_args, *label_flags) }
			
		closure = directory_closure
		closure.each { |e| e.label!(label_args, *label_flags) }
		
		Element.new(view.path).label!(label_args, *label_flags) if @root
	end

	# args: name, root_vob (see ClearCASE::LabelType.create)
#	def label!(args, *flags)
#		nocreate = flags.include?(:nocreate)
#		ClearCASE::LabelType.create(args) if !nocreate
#		name = args[:name]
#		each { |e| e.label!(name, flags + [:nocreate]) }
#	end

	def []=(attr, value)
		each { |e| e[name] = value }
	end

end # class Elements

#----------------------------------------------------------------------------------------------

class CheckedoutFiles

	def initialize(view = nil)
		if view
			@view = view
		else
			wd = System.commandx("cleartool pwv").out0
			raise "Cannot determine view" if wd == "** NONE **"
			@view = wd
		end

		view_root = System.commandx("cleartool pwv -root").out0;
		puts "view root: #{view_root}"
	end

end

#----------------------------------------------------------------------------------------------

# Returns true iff the file was actually checked in.
def checkin_file(file, keep_co)
	ci = System.command("cleartool ci -nc -ptime #{file}")

	if (ci.status == 0)
		if keep_co
			#checkout the file
		end

		return true
	end

	if ci.status == 1 && ci.err0.chomp == "cleartool: Error: By default, won't create version with data identical to predecessor."
		if !keep_co
			puts "\tFile is identical to predecessor. Undoing check-out on #{file} ..."
			unco = System.command("cleartool unco -rm #{file}")
		else
			#keepco, do nothing
			puts "\t file is checked-out and identical. skipping checkin due to keepco" unless !$VerboseMode
		end
	else
		raise "Checkin failed for #{file}"
	end

	return false
end

module_function :checkin_file

#----------------------------------------------------------------------------------------------

end # module ClearCASE
