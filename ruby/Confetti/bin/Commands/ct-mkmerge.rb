require 'trollop'
require 'Bento'

# This is the name of the attribute in CC, for files that wont be merged
$NonMergeableAttributeName = "NonMergeable"

# Utility function: print-if-verbose
def print(message)
	if $VerboseMode
		puts message
	end
end

#-----------------------------------------------------------------------
# Script: ct-mkmerge.rb
#
# This script calls cleartool find merge command to merge files from the
# given lot to the current directory, for all the files with the given label
#
# files that are attributed as "NonMergeable" are not merged.
#-----------------------------------------------------------------------

# Handle command line args:
opts = Trollop::options do
	version "ct-mkmerge 1.0"
	opt :label,  "Label", :type => String
	opt :lot,     "Lot name", :type => String
	opt :checkoutcomment,     "Checkout comment", :type => String
	opt :verbose,  "Be verbose" , :default => false
	opt :noop, "do nothing, just print" , :default => false
end

Trollop::die "Must specify a label..aborting" if !opts[:label]
Trollop::die "Must specify a lot..aborting" if !opts[:lot]

$VerboseMode = opts[:verbose]
lotName = opts[:lot]
labelName = opts[:label]
noOp = opts[:noop]


# Sanity: Verify we're in a view
begin
	currentViewName = ClearCASE::CurrentView.new().name
rescue
	Trollop::die "Please run the script from within a view. Aborting."			
end

# Deal with the checkout comment
checkoutComment = ""
checkoutComment = opts[:checkoutcomment] unless !opts[:checkoutcomment]

# Sanity: Check that the label exists
myLabel = ClearCASE::Label.new(labelName)
Trollop::die "Can't find label (#{labelName}) in Clearcase. Aborting." unless myLabel.exists?

# Sanity: Check that the lot exists
begin
	myLot = Confetti::Lot.new(lotName)		
	print "Merging from Lot #{lotName}"
rescue
	Trollop::die "Must specify a valid lot name. Aborting"	
end

# Create a string containing the list of vobs to merge
vobs = ""
myLot.getVOBs.each do |vob|
	vobs +=  vob.to_s + " "
end

# Perform the merge
print "\nMerging VOBs ( #{vobs}) ..."
	
mergeCommand = "cleartool findmerge #{vobs} -fversion #{labelName} -gmerge -c \"#{checkoutComment}\" -element !attype(#{$NonMergeableAttributeName})"

print "Merge Command: #{mergeCommand}"

if (!noOp)
	c = System.command(mergeCommand) 
	if (c.status == 0)
		print c.out
	else
		print c.err
	end
end



