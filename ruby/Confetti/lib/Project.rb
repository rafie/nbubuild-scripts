
require 'nokogiri'
require 'Bento'

module Confetti

#----------------------------------------------------------------------------------------------

class Project
	attr_reader :name, :roots
	attr_writer :roots

	def initialize(name)
		@name = name
		@roots = []
	end
end # class Project

#----------------------------------------------------------------------------------------------

class Projects

	def initialize(names)
		@names = names
	end

	def each
		@names.each { |name| yield Proejct.new(name) }
	end

end # Projects


#----------------------------------------------------------------------------------------------

end # module Confetti
