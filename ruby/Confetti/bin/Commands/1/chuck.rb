require 'trollop'
require 'Bento'
require 'Confetti'

$keepco = false
$originalWorkingDir = ""

def print(message)
	if $VerboseMode
		puts message
	end
end

def print_with_sep(message)
	print message
	print "-------------------------------------------------------------"
end

#----------------------------------------------------------------------------------------------

# Handle command line args:
opts = Trollop::options do
	version "Chuck 1.0"
	opt :act,     "Activity", :type => String
	opt :lot,     "Lot name", :type => String
	opt :verbose, "Be verbose", :default => false
	opt :keepco,  "Keep checkouts", :default => false
	opt :noop,    "Do nothing, just print", :default => false
end

Trollop::die "Must specify a lot..aborting" if !opts[:lot]

# Was a lot given? if not use default (TODO AMIB?)

# Keep files as checked out?
$keepco = opts[:keepco]

if opts[:verbose]
	$VerboseMode = true
	print "Entering verbose mode"
	print "Activity flag: #{opts[:act]}"
	print "Lot flag: #{opts[:lot]}"
	print "Keepco flag: #{opts[:keepco]}"
	print "noop flag: #{opts[:noop]}"
end 

# Get the current directory
$originalWorkingDir = Dir.pwd

#----------------------------------------------------------------------------------------------

noop = opts[:noop]

# Sanity: Verify the given lot is valid
if opts[:lot]
	lotName = opts[:lot]
else
	lotName = "mcu" #TODO AMIB what's the default? should we have one?
end

begin
	myLot = Confetti::Lot.new(lotName)		
rescue
	Trollop::die "Must specify a valid lot name..aborting"	
end

# Sanity: Activity name
# It was either given - or analyzed from the cwd (from the view name)
if opts[:act]
	@activityName = opts[:act]
else # Get the activity name from the cwd	
	begin	
		currentViewName = ClearCASE::CurrentView.new().name
		@activityName = Confetti::Activity.extractActivityNameFromViewName(currentViewName)	
	rescue
		Trollop::die "Please run the script from within a view (or specify the activity name)..aborting"		
	end
end
	
# Sanity: Verify the activity exists in the meta-data
myActivity = Confetti::Activity.new(@activityName)
puts "Checking existance of activity:#{@activityName}" unless !$VerboseMode
if !myActivity.exists?()
	Trollop::die "Please specify a *valid* activity name (or run script from within the view without using the -a flag)..aborting"	
end

#----------------------------------------------------------------------------------------------
	
# Convert activity name to View, Branch
myView = ClearCASE::View.new(myActivity.getViewName)
myBranch = ClearCASE::Branch.new(myActivity.getBranchName)		

print "view = #{myView.name}"
print "branch = #{myBranch.name}"

# Print the list of vobs in the lot
print "list of vobs in lot: #{myLot.getVOBs.to_s}"			

# Switch to the right view
if Dir.exists?(myView.path)
	Dir.chdir myView.path
else		
	print "Error: No such view - #{myView.path}"
end

#----------------------------------------------------------------------------------------------

# Get the list of checked out files in all the VOBs	in this view
checkedOutElements = myView.checkouts2()

# Print them	
print "\nListing all the cheked-out files in view #{myView.path} ..."
print_with_sep checkedOutElements.to_s

# Filter the list of checked out files by the lot		
filteredCheckedOutElements = myLot.filterElements(checkedOutElements)

# Check the files in
if filteredCheckedOutElements.count==0
	print "\nNo files to check-in"
else
# Print them	
	print "\nListing all the cheked-out files *within the lot #{myLot.name}* in view #{myView.path} ..."
	print_with_sep filteredCheckedOutElements.to_s

# Check the files in and undo-checkout for identicals
# in keepco mode we check-out all the files after we label them.
	print "\nChecking in all the cheked-out files *within the lot #{myLot.name}* in view #{myView.path} ..."		
	filteredCheckedOutElements.each do |file|					
		element = ClearCASE::Element.new(myView.path + file.name)
		element.checkin() unless noop	

		# ClearCASE::checkin_file(myView.path+file,$keepco)
	end
end

# Get the list of files on the branch in this view
branchedElements = myView.listFiles(myBranch)

# Print them
print "\nListing all the files on branch #{myBranch.name} and view #{myView.name} ..."
print_with_sep branchedElements.to_s

# Filter the list of branced files by the lot	
filteredBranchedElements = myLot.filterElements(branchedElements)

# Print them
print "\nListing all the files, *within the lot #{myLot.name}* on branch #{myBranch.name} ..."
print_with_sep filteredBranchedElements.to_s

# Expand the list of files to include the directories
expandedFilteredElements = filteredBranchedElements.expandClosure()		

# Print them
print "\nListing all the files, *expanded* *within the lot #{myLot.name}* on branch #{myBranch.name} ..."
print_with_sep expandedFilteredElements.to_s

# Create label and apply on the files
if expandedFilteredElements.count == 0
	puts "No files to label. Exiting..."
	exit
end

# Create a label object 
if !noop
	myLabel = ClearCASE::Label.new(myActivity.getNextLabelName())			
	myLabel.materializeLabel() #creates the label in CC 
	puts "\nCreated label: #{myLabel.name}"
end

# Label the files
print "\nLabeling files in Lot..."	
expandedFilteredElements.each do |file|
	element = ClearCASE::Element.new(myView.path + file.name)
	element.label!(myLabel) unless noop	
end
print_with_sep

# Keepco: check out the files that were checked out before
if $keepco && filteredCheckedOutElements.count > 0
	print "\nKeepco: Re-Checking out all the files *within the lot #{myLot.name}* in view #{myView.path} ..."		
		filteredCheckedOutElements.each do |file|					
			element = ClearCASE::Element.new(myView.path + file.name)
			element.checkout() unless noop														
	end
end
	
# Go back the original dir
Dir.chdir $originalWorkingDir
