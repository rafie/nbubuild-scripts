
require_relative 'Common.rb'

#----------------------------------------------------------------------------------------------

module ClearCASE

#----------------------------------------------------------------------------------------------

class Branch
	include Bento::Class

	attr_reader :name
	
	def initialize(*opt)
		return if init_with_tag(:create, opt)

		init([:name], [], [], opt)
		fix_name
	end

	def Branch.create(*opt)
		Branch.new(opt, :create)
	end

#	def Branch.admin_vob
#		begin
#			cview = CurrentView.new
#			admin_vob = cview.admin_vob
#		rescue
#			admin_vob = DEFAULT_ADMIN_VOB
#		end
#		
#		admin_vob
#	end

	def admin_vob
		@admin_vob = defined?(@root_vob) ? @root_vob : DEFAULT_ADMIN_VOB

#		return @admin_vob if defined?(@admin_vob)
#
#		begin
#			cview = CurrentView.new
#			@admin_vob = cview.admin_vob
#		rescue
#			@admin_vob = DEFAULT_ADMIN_VOB
#		end
#		
#		@admin_vob = DEFAULT_ADMIN_VOB if ! defined?(@admin_vob)
#		@admin_vob
	end

	def exists?
		desc = System.command("cleartool describe brtype:#{@name}@/#{admin_vob}")
		return desc.ok?
	end

	#------------------------------------------------------------------------------------------
	private
	#------------------------------------------------------------------------------------------

	def create(opt)
		init([:name], [:root_vob], [], opt)
		fix_name

		@admin_vob = defined?(@root_vob) ? @root_vob : DEFAULT_ADMIN_VOB

		mkbrtype = System.command("cleartool mkbrtype -nc #{@name}@/#{@admin_vob}")
		raise "Cannot create branch #{name}" if mkbrtype.failed?
	end

	def fix_name
		@name += "_br" if ! @name.end_with?("_br")
	end
end # Branch

#----------------------------------------------------------------------------------------------

class Branches
	include Enumerable

	def initialize(names)
		@names = names
	end

	def each
		@names.each { |name| yield Branch.new(name) }
	end

end # Branches

#----------------------------------------------------------------------------------------------

end # module ClearCASE
