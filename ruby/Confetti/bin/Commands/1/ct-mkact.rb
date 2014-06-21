require 'trollop'
require 'Bento'

def print(message)
	if $VerboseMode
		puts message
	end
end

# Handle command line args:
opts = Trollop::options do
	version "ct-mkact 1.0"
	opt :act,    "Activity name" , :type => String
	opt :dynamic, "Create a dynamic view" , :default => false
	opt :static,  "Create a static view" , :default => false
	opt :server,  "Create the view on server (rvil-ccview)" , :default => false
	opt :verbose, "Verbose mode" , :default => false
	opt :noop, "Do nothing, just print" , :default => false
	#-raw          don't add username prefix to view name
    #-spec <file>  configspec file
end

begin
	noOp = opts[:noop]
	$VerboseMode = opts[:verbose]
	
	print "act = #{opts[:act]}"
	print "dynamic = #{opts[:dynamic]}"
	
	Trollop::die "Must specify an activity name..aborting" if !opts[:act]
	Trollop::die "Activity can't be both dynamic AND static..aborting" if opts[:dynamic] && opts[:static]
	
	name = opts[:act]
	
	# Sanity: Verify the activity exists in the meta-data
	print "Testing whether the activity #{activityName} already exists.."
	Activity.create(name)
	act = Confetti::Activity.new(activityName)
	if myActivity.exists?()
		puts "Activity with this name (#{myActivity.name}) already exists. Aborting."
		exit
	end
	
	# Create the activity meta-data, the branch and the view
	myActivity.materializeActivity() if !noOp
rescue Exception => x
end
