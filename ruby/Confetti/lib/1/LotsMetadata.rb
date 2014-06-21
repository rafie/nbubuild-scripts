require 'nokogiri'

class LotsMetadata
 
	# Ctor: takes in the path to the lots meta-data file

	def initialize(lotMetaDataFile)
		@lotMetaDataFile = lotMetaDataFile		
	end
	
	#-------------------------------------------------------------------------------------
	
	# Returns true if the lot with the given name exists in the metadata 

	def exists?(lotName)
		# Read the contents of the activity file
		doc = Nokogiri::XML(open(@lotMetaDataFile))		 		

		# Parse the data		
		doc.css('lots > lot').each do |node|
			return true if node.attr('name') == lotName
		end
		return false
	end	
	
	#-------------------------------------------------------------------------------------
	
	# Returns the list of VOB-names that compose the Lot with the given name

	def getListOfVOBs(lotName)
		# Read the contents of the activity file
		doc = Nokogiri::XML(open(@lotMetaDataFile))

		# Parse the data
		vobsList = []
		doc.xpath('lots // lot').each do |node|							 		
			if node.attr('name') == lotName
				vobsNode = node.xpath('vobs')
				vobsNode.children.each do |vob|							
					vobName = vob.attr('name')
					vobsList.push(vobName) unless vobName == nil
				end
			end
		end
		 		 
		return vobsList
	end

end
