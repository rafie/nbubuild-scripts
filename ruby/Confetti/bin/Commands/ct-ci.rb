
require 'optparse'

require 'ostruct'
require 'pp'

require 'Bento'

#----------------------------------------------------------------------------------------------
# returns a subset of files: all items that are contained in both "files" and the checkouts hashtalbe

def collect_files(checkouts, files)
	selected = []
	files.each do |file|
		selected << file if checkouts[file]
	end
	return selected
end

#----------------------------------------------------------------------------------------------
# returns a subset of dirs that are contains in "dirs" and appear in the hashtable of checked-out files

def collect_dirs(checkouts, dirs, recurse)
	selected = []
	dirs.each do |dir|
		checkouts.keys.each do |co|
			if recurse
				selected << co if co =~ /^#{dir}/
			else
				selected << co if co =~ /^#{dir}\/([^\/]*)$/
			end
		end
	end
	return selected
end

#----------------------------------------------------------------------------------------------
# file - checked out file to check in.
# optional flags: keepco - do not check in files that did not change
#				  noop - do nothing, just print files.

def checkin_file(file, *opt)
	noop = opt.include? :noop
	keepco = opt.include? :keepco

	rc = true
	begin
		elem = ClearCASE::Element.new(file)
		if !elem.changed?
			if keepco
				print "#{file} (no changes, kept checked-out)"
				return true
			end
	
			print "#{file}: UNDO"
			return true if noop
	
			print " ... "
			elem.uncheckout
		else
			print file
			return true if noop
	
			print " ... "
	
			elem.checkin(keepco)
		end

		print "OK"
		return true
	rescue => err
		print "FAILED: #{err}"
		return false
	ensure
		puts
	end
end

#----------------------------------------------------------------------------------------------

def checkin_files(files, *opt)
	errors = []
	files.each do |file|
		begin
			ok = checkin_file file, *opt
			errors << [file] if !ok
		rescue => err
			errors << [file, err]
		end
	end
	return errors
end

#----------------------------------------------------------------------------------------------

class Arguments
	def initialize
	end
end

#----------------------------------------------------------------------------------------------
# check in files:
#  either checkin all the files in all the vobs (using the -all flag) 
# or
#  specify a directory to checkin, 
# or
#  a file that contains a list of files to checkin.

begin
	options = OpenStruct.new
	options.all = false
	options.argfiles = []
	options.vobs = []
	options.dirs = []
	gopt = []
	
	optparse = OptionParser.new do |opts|
		opts.banner = "ct-ci: check-in files\nUsage: ct-ci [options] files"
		
		opts.on('-n', '--dry', "Just print messages, don't execute commands") do
			options.noop = true
			gopt = gopt | [:noop]
		end
		
		opts.on('-f', '--file FILE', /[^-].*/, 'Take file arguments from FILE (repeatable)') do |file|
			options.argfiles << file
		end
		
		opts.on('-d', '--dir DIR', /[^-].*/, 'Operate on directory DIR') do |dir|
			options.dirs << dir
		end
		
		opts.on('-r', '--recursive', "Recursive operation") do
			options.recursive = true
			gopt = gopt | [:recursive]
		end
	
		opts.on('--co', "Keep files checked-out") do
			options.keep_co = true
			gopt = gopt | [:keepco]
		end
	
		opts.on('--co1', "Keep changed files checked-out") do
			options.keep_co_mod = true
		end
	
		opts.on('-w VIEW', '--view VIEW', /[^-].*/, 'Operate in view VIEW') do |view|
			options.view = view
		end

		opts.on('-v VOB', '--vob VOB', /[^-].*/, 'check-in files in VOB (repeatable)') do |vob|
			options.vobs << vob
		end

		opts.on('-b BRANCH', '--branch BRANCH', /[^-].*/, 'check-in files on BRANCH') do |branch|
			options.branch << branch
		end
	
		opts.on('-a', '--all', "Operate on all mounted VOBs") do
			options.all = true
		end
	
		opts.on_tail('--version', 'Print version') do
			options.version = true
		end
	
		opts.on_tail('-h', '--help', 'Display this screen') do
			puts opts
			exit
		end
	end

	optparse.parse!

	raise "Conflicting options: --all et al." if options.all && (options.dirs || options.vobs || options.argfiles)

	if options.view
		view = ClearCASE::View.new(options.view)
	else
		view = ClearCASE::CurrentView.new
	end

	cwd = Dir.pwd;

	# generate list of checkouts for this view and store them in checkouts[]
	checkouts = {} # use hashtable to implement a set
	view.checkouts.keys.each do |file|
		checkouts[view.root + file] = true
	end

	# depending on the flags, either checkin all the files or list of argument-files/directories	
	if options.all
		checkins =  checkouts.keys
	else
		# get the content of the argument files
		files = []
		files += ARGV
	
		options.argfiles.each { |file|
			File.open(file).each { |line|
				f = line.chomp
	    		files << f
	    	}
		}
	
		# in case no files were found, add "/" (root).
		options.dirs << "/" if files.empty? && options.dirs.empty? && options.vobs.empty?
		
		# prefix the files,directories and vobs with appropriate path
		files.map! { |file| ((file =~ /^\//) ? view.root : cwd + "/") + file }
		dirs = options.dirs.map { |file| ((file =~ /^\//) ? view.root : cwd + "/") + file }
		vobs = options.vobs.map { |vob| view.root + "/" + vob }
	
		# get only the files/dirs that are checked out
		checkins = []
		checkins.concat(collect_files(checkouts, files))
		checkins.concat(collect_dirs(checkouts, dirs, options.recursive))
		checkins.concat(collect_dirs(checkouts, vobs, true))
	end

	# finally, check in the files
	errors = checkin_files(checkins, *gopt)
	if ! errors.empty?
		puts "-- errors:"
		puts errors
	end
	
#	puts "Got view #{options.view}" if options.view
#	puts "Got arg file #{options.argfiles}" if options.argfiles
#	puts "Got vobs #{options.vobs}" if options.vobs
#	puts "Got files #{files}" if files
#	puts "Got dirs #{options.dirs}" if options.dirs
#	puts "Got version" if options.version
#	puts "Got dry" if options.dry
#	puts "args: #{ARGV}"

rescue => err
	STDERR.puts err
	raise
end
