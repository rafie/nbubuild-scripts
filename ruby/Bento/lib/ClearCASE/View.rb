
require_relative 'Common'

#----------------------------------------------------------------------------------------------

module ClearCASE

#----------------------------------------------------------------------------------------------

class View             
	include Bento::Class

	attr_reader :name

	def initialize(*opt)
		return if init_with_tag(:create, opt)

		init([:name], [:root_vob], [], opt)
		fix_name
	end

	def View.create(*opt)
		View.new(opt, :create)
	end

	#------------------------------------------------------------------------------------------

	def exists?
		lsview = System.commandx("cleartool lsview -short #{name}", :nolog)
		return lsview.ok?
	end

	# type = :dynamic/:snapshot

	def type
		if !@type
			@type = :dynamic			
			lsview = System.commandx("cleartool lsview -long #{name}", :nolog)
			lsview.out.lines.each do |line|				
				if line =~ /^View attributes: (.*)/
					snap = $1
					#only snapshot views return the "View attributes" line.
					@type = ($snap =~ /.*snapshot.*/) ? :dynamic : :snapshot
				end
			end
		end
		
		return @type
	end

	def path
		"M:/#{name}" + (defined?(@root_vob) ? "/#{@root_vob}" : "")
	end

	def root_vob
		return VOB.new(@root_vob) if @root_vob
		nil
	end

	#------------------------------------------------------------------------------------------

	def elements(names)
		Elements.new(names.map { |e| path + '/' + e })
	end

	def checkout(names)
		elements(names).checkout
	end

	#------------------------------------------------------------------------------------------

	# finds all checked out files in view
	
	def checkouts
		lsco = System.command("pushd M:\\#{@name} & cleartool lsco -avobs -cview -short")
		raise "checked-out elements query failed for viewe #{@name}" if lsco.out0 =~ /Error/
		ClearCASE::Elements.new(lsco.out.lines)
	end
	
	# finds all files on a given branch in view

	def on_branch(branch)
		branch_name = branch.is_a?(ClearCASE::Branch) ? branch.name : Branch.new(branch).name
		find = System.command("pushd M:\\#{@name} & cleartool find -element brtype(#{branch_name}) -nxname -avobs -visible -print")
		raise "elements on branch query failed for view {@name}" if find.failed?
		ClearCASE::Elements.new(find.out.lines)
	end

	#------------------------------------------------------------------------------------------
	private
	#------------------------------------------------------------------------------------------

	def create(opt)
		init([:name], [:root_vob], [], opt)
		fix_name

		region = DEFAULT_WIN_REGION
		host = System.hostname
		stg = LocalStorageLocation.new
		local_stg = "#{stg.local_stg}\\#{@name}.vws"
		global_stg = "#{stg.global_stg}\\#{@name}.vws"

		mkview_cmd = "cleartool mkview -tag #{@name} -tmode unix -region #{region} -shareable_dos " + 
			"-host #{host} -hpath #{local_stg} -gpath #{global_stg} #{local_stg}"
		mkview = System.command(mkview_cmd)	
		raise "failed to create view #{@name}" if mkview.failed?

		ClearCASE::Explorer.add_view_shortcut(@name)
	end

	def fix_name
		if @name =~ /^([^\\]*)\/(.*)/
			@name = $1
			raise "conflicting root_vob specifications: #{@root_vob} and #{$2}" if defined?(@root_vob) && @root_vob != $2
			@root_vob = $2
		else
			@root_vob = '' if !defined?(@root_vob)
		end
	end
end # class View

#----------------------------------------------------------------------------------------------

class CurrentView < View

	def initialize
		@name = System.commandx("cleartool pwv -sh", :nolog).out0
		raise "Cannot determine current view" if @name == "** NONE **"
	end

	def current_vob
		view, vob, path = ClearCASE::Element.parse(Dir.pwd)
		raise "No current VOB" if vob.empty?
		VOB.new(vob)
	end

end # class CurrentView

#----------------------------------------------------------------------------------------------

class LocalView
end

#----------------------------------------------------------------------------------------------

class RemoteView
end

#----------------------------------------------------------------------------------------------

end # module ClearCASE
