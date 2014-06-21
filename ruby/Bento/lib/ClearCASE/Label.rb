
require_relative 'Common'

#----------------------------------------------------------------------------------------------

module ClearCASE

#----------------------------------------------------------------------------------------------

class LabelType
	include Bento::Class

	attr_reader :name

	def initialize(*opt)
		return if init_with_tag(:create, opt)

		init([:name], [], [], opt)
	end

	def LabelType.create(*opt)
		LabelType.new(opt, :create)
	end

	def admin_vob
		@admin_vob = defined?(@root_vob) ? @root_vob : DEFAULT_ADMIN_VOB
#		@admin_vob = DEFAULT_ADMIN_VOB if ! defined?(@admin_vob)
	end

	def exists?
		System.command("cleartool describe lbtype:#{@name}@/#{admin_vob}").ok?
	end

private
	def create(opt)
		init([:name], [:root_vob], [], opt)

		@admin_vob = defined?(@root_vob) ? @root_vob : DEFAULT_ADMIN_VOB

		if !exists?
			mklbtype = System.command("cleartool mklbtype -nc #{@name}@/#{@admin_vob}")
			raise "Cannot create label #{name}" if mklbtype.failed?
		end
	end
end # LabelType

#----------------------------------------------------------------------------------------------

class LabelTypes

	def initialize(names)
		@names = names
	end

	def each
		@names.each { |name| yield LabelType.new(name) }
	end

end # LabelTypes

#----------------------------------------------------------------------------------------------

end # module ClearCASE
