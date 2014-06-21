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

$keepco = opts[:keepco]

if opts[:verbose]
	$VerboseMode = true
end 

#----------------------------------------------------------------------------------------------

noop = opts[:noop]

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

#----------------------------------------------------------------------------------------------

if opts[:act]
	act = Confetti::Activity.new(opts[:act])
else
	act = Confetti::CurrentActivity.new
end
	
raise "Please specify a *valid* activity name" if !act.exists?

#----------------------------------------------------------------------------------------------
	
view = act.view
bra = act.branch

#----------------------------------------------------------------------------------------------

checkouts = view.checkouts
checkouts = lot.filter_elements(checkouts)

checkouts.each do |file|					
	element = ClearCASE::Element.new(view.path + file.name)
	element.checkin
end

bra_elements = view.on_branch(bra)
bra_elements = lot.filter_elements(bra_elements)
bra_elements_closure = bra_elements.directory_closure		

return if bra_elements_closure.empty?

mark = act.new_mark_name
bra_elements_closure.each do |file|
	element = ClearCASE::Element.new(view.path + file.name)
	element.label!(new_mark_name)
end

return if ! $keepco

checkouts.each do |file|					
	element = ClearCASE::Element.new(view.path + file.name)
	element.checkout
end
