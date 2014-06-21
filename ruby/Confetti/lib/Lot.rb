
require 'nokogiri'
require 'Bento'

module Confetti

LOT_XML_VIEWPATH = "/nbu.meta/confetti/lots.xml";

#----------------------------------------------------------------------------------------------

class Lot
	class DB
		def initialize
			view = ClearCASE::CurrentView.new
			@xml = Nokogiri::XML(File.open(view.fullPath + LOT_XML_VIEWPATH))
		end

		def exists?
			!@xml.xpath("//lots/lot[@name='#{name}']").empty?
		end
	
		def vobNames(name)
			@xml.xpath("//lots/lot[@name='#{name}']/vob/@name").map { |x| x.to_s }
		end
	
		def lotNames(name)
			@xml.xpath("//lots/lot[@name='#{name}']/lot/@name").map { |x| x.to_s }
		end
	end # DB

	attr_reader :name

	def initialize(name)
		# raise "Lot #{name} does not exist" unless DB.exists?(name)
		@name = name
		@db = nil
	end

	def vobs
		names = db.vobNames(@name)
		return ClearCASE::VOBs.new(names)
	end

	def lots
		names = db.lotNames(@name)
		return Lots.new(names)
	end
	
	# Filter out elements not contained in lot

	def filterElements(elements)
		files = []
		vobs.each do |vob|
			files.merge!(elements.filterByVOB(vob))
		end
		return ClearCASE::Elements.new(files)
	end
	
	private

	def db
		@db = DB.new if ! @db
		return @db
	end

end # Lot

#----------------------------------------------------------------------------------------------

class Lots

	def initialize(names)
		@names = names
	end

	def each
		@names.each { |name| yield Lot.new(name) }
	end

end # Lots

#----------------------------------------------------------------------------------------------

end # module Confetti
