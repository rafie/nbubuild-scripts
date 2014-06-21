
require 'find'
require 'trollop'

$debug = 1
$scripts = ENV['NBU_BUILD_ROOT'] + "/sys/scripts/ccase/ct1"
$ccase_root = "m:"

#----------------------------------------------------------------------------------------------
# Each project is a hash, within which there's a sub-hash of vobs.
$mcu_8_0 = [
	[ "app",   [ "mcu", "web" ] ], 
	[ "proto", [ "adapters", "dialingInfo", "mediaCtrlInfo", "nbu.proto.jingle-stack", "NBU_COMMON_CORE", "NBU_H323_STACK", "NBU_SIP_STACK" ] ],
	[ "media", [ "mvp", "mpc", "map", "mf", "mpInfra", "NBU_RTP_RTCP_STACK", "NBU_FEC", "NBU_ICE" ] ],
	[ "dsp",   [ "dspIcsVideo", "dspInfra", "dspIntelInfra", "dspNetraInfra", "dspNetraVideo", "dspUCGW", "mpDsp", "swAudioCodecs" ] ],
	[ "infra", [ "swInfra", "boardInfra", "loggerInfra", "rvfc", "configInfra", "nbu.contrib" ] ],
	[ "bsp",   [ "bspLinuxIntel", "bspLinuxARM" ] ]
	]

$ucgw_7_7 = [
	[ "app",      [ "mcu", "web" ] ], 
	[ "proto",    [ "adapters", "dialingInfo", "mediaCtrlInfo", "nbu.proto.jingle-stack", "NBU_SCCP_STACK", "NBU_COMMON_CORE", "NBU_H323_STACK", "NBU_SIP_STACK" ] ],
	[ "media",    [ "mvp", "mpc", "map", "mf", "mpInfra", "NBU_RTP_RTCP_STACK", "NBU_FEC", "NBU_ICE" ] ],
	[ "dsp",      [ "swAudioCodecs", "mpDsp", "dsp8144Audio", "dsp8144Video", "dspIntelInfra", "dspUCGW" ] ],
	[ "infra",    [ "swInfra", "boardInfra", "loggerInfra", "rvfc", "configInfra", "nbu.contrib" ] ],
	[ "security", [ "securityApp", "securityInfra" ] ],
	[ "bsp",      [ "bspLinuxIntel" ] ]
	]

$mcu_7_7 = [
	[ "app",      [ "mcu", "web" ] ], 
	[ "proto",    [ "adapters", "dialingInfo", "mediaCtrlInfo", "NBU_SCCP_STACK", "NBU_COMMON_CORE", "NBU_H323_STACK", "NBU_SIP_STACK" ] ],
	[ "media",    [ "mvp", "mpc", "map", "mf", "mpInfra", "NBU_RTP_RTCP_STACK", "NBU_FEC" ] ],
	[ "dsp",      [ "dpm", "dsp8144Audio", "dsp8144Video", "dspC64Audio", "mpDsp" ] ],
	[ "infra",    [ "swInfra", "boardInfra", "loggerInfra", "rvfc", "configInfra", "nbu.contrib" ] ],
	[ "security", [ "securityApp", "securityInfra" ] ],
	[ "bsp",      [ "bspLinux8548" ] ]
	]

$mcu_7_5 = [
	[ "app",   [ "mcu", "web" ] ], 
	[ "media", [ "mvp", "mpc", "map", "mf", "mpInfra", "NBU_RTP_RTCP_STACK", "NBU_FEC" ] ],
	[ "dsp",   [ "dpm", "mpDsp", "dspC64Audio", "dsp8144Audio", "dsp8144Video" ] ],
	[ "proto", [ "adapters", "dialingInfo", "mediaCtrlInfo", "NBU_COMMON_CORE", "NBU_H323_STACK", "NBU_SIP_STACK", "NBU_SCCP_STACK" ] ],
	[ "infra", [ "swInfra", "boardInfra", "loggerInfra", "rvfc", "configInfra", "securityApp", "securityInfra" ] ],
	[ "bsp",   [ "bspLinux8548" ] ]
	]

$mcu_7_1_2 = [
	[ "app",   [ "mcu", "web" ] ], 
	[ "media", [ "mvp", "mpc", "map", "mf", "mpInfra" ] ],
	[ "dsp",   [ "dpm", "mpDsp", "dspC64Audio", "dsp8144Audio" ] ],
	[ "proto", [ "adapters", "dialingInfo", "mediaCtrlInfo", "NBU_COMMON_CORE", "NBU_H323_STACK", "NBU_SIP_STACK", "NBU_SCCP_STACK" ] ],
	[ "infra", [ "swInfra", "boardInfra", "loggerInfra", "rvfc", "configInfra", "securityApp", "securityInfra" ] ],
	[ "bsp",   [ "bsp8548", "bspLinux8548" ] ]
	]

$mcu_7_1_0 = [
	[ "app",   [ "mcu", "web" ] ], 
	[ "media", [ "mvp", "mpc", "map", "mf", "mpInfra" ] ],
	[ "dsp",   [ "dpm", "mpDsp", "dspC64Audio", "dsp8144Audio" ] ],
	[ "proto", [ "adapters", "dialingInfo", "mediaCtrlInfo", "NBU_COMMON_CORE", "NBU_H323_STACK", "NBU_SIP_STACK", "NBU_SCCP_STACK" ] ],
	[ "infra", [ "swInfra", "boardInfra", "loggerInfra", "rvfc", "configInfra", "securityApp", "securityInfra" ] ],
	[ "bsp",   [ "bsp8548", "bspLinux8548" ] ]
	]

$mcu_7_0_1 = [
	[ "app",   [ "mcu", "web" ] ], 
	[ "media", [ "mvp", "mpc", "map", "mf", "mpInfra" ] ],
	[ "dsp",   [ "dpm", "dspInfra", "dspC64Audio", "dsp8144Audio" ] ],
	[ "proto", [ "adapters", "dialingInfo", "mediaCtrlInfo", "NBU_COMMON_CORE", "NBU_H323_STACK", "NBU_SIP_STACK", "NBU_SCCP_STACK" ] ],
	[ "infra", [ "swInfra", "boardInfra", "loggerInfra", "rvfc", "configInfra", "securityApp", "securityInfra" ] ],
	[ "bsp",   [ "bsp8548", "bspLinux8548" ] ]
	]

$mcu_7_0_0 = [
	[ "app",   [ "mcu", "web" ] ], 
	[ "media", [ "mvp", "mpc", "map", "mf", "mpInfra" ] ],
	[ "dsp",   [ "dpm", "dspInfra", "dspC64Audio", "dsp8144Audio" ] ],
	[ "proto", [ "adapters", "dialingInfo", "mediaCtrlInfo", "NBU_COMMON_CORE", "NBU_H323_STACK", "NBU_SIP_STACK", "NBU_SCCP_STACK" ] ],
	[ "infra", [ "swInfra", "boardInfra", "loggerInfra", "rvfc", "configInfra", "securityApp", "securityInfra" ] ],
	[ "bsp",   [ "bsp8548", "bspLinux8548" ] ]
	]

# List of files to exlucde per vob
$excludes = [
	[ "mcu",				[ "Attic" ] ],
	[ "mvp",				[ ".attic" ] ],
	[ "NBU_COMMON_CORE",    [ "common/include" ] ],
	[ "NBU_SIP_STACK",      [ "rvsip/appl", "rvsip/include", "rvsip/samples" ] ],
	[ "NBU_H323_STACK",     [ "rvh323/appl", "rvh323/include", "rvh323/samples", "rvh323/testers" ] ],
	[ "NBU_RTP_RTCP_STACK", [ "samples" ] ],
	[ "NBU_FEC",            [ "samples" ] ],
	[ "mpInfra",            [ "CxImage" ] ],
	[ "configInfra",        [ "ASN.1", "ConfigApp", "Test" ] ],
	[ "loggerInfra",        [ "Attic" ] ],
	[ "securityApp",        [ "OpenSSL" ] ],
	[ "bspLinux8548", 		[ "RVCryptoTest", "RVHwTest", "RVsoTest", "RVSrioTest" ] ],
	]

$test_proj = [
	[ "test", [ "bspLinux8548" ] ]
	]

	#hash mapping from project name to project(hash)
$projects = [
	[ "mcu-8.0",   $mcu_8_0 ],
	[ "ucgw-7.7",  $ucgw_7_7 ],
	[ "mcu-7.7",   $mcu_7_7 ],
	[ "mcu-7.5",   $mcu_7_5 ],
	[ "mcu-7.1.2", $mcu_7_1_2 ],
	[ "mcu-7.1.0", $mcu_7_1_0 ],
	[ "mcu-7.0.1", $mcu_7_0_1 ],
	[ "mcu-7.0.0", $mcu_7_0_0 ],
	[ "test",      $test_proj ]
	]

#----------------------------------------------------------------------------------------------

# Returns true if f begins with prefix
def starts_with?(f, prefix)
	return false if prefix.size > f.size
	f1 = f[0 .. prefix.size-1]
	return f1 == prefix
end


def exclude?(excludes, f)
	return false if excludes == []
	name = excludes[0]
	for e in excludes[1]
		e1 = name + '/' + e
		return true if starts_with?(f, e1)
	end
	return false
end

#for each file in dir, count the number of lines unless file is excluded. return grand total
def count_lines(dir, excludes)

	files = Dir[dir + '/**/*.{c,cpp,h}']
	lines = 0
	for f in files                    
		next if exclude?(excludes, f)
		n = 0
		File.new(f, "r").each { n += 1 }
		puts "#{f} #{n}" if $print_files
		lines += n
	end

	return lines
end

def find_excludes(key)
	for e in $excludes
		return e if e[0] == key
	end
	return []
end

#----------------------------------------------------------------------------------------------
#Returns a full CC path
def view_dir(view)
	return "#{$ccase_root}/#{view}"
end

# Returns the current view
def curr_view
	v = %x[cleartool pwv -sh].chomp
	return v == "** NONE **" ? nil : v
end

# Starts the given directory in CC
def start_view(view)
	return true if File.directory?(view_dir(view))
	Kernel.system("cleartool startview #{view} > nul 2>&1")
	return $? == 0
end

# Calls a script to start a view with the given cspec
def create_view(view, cspec)
	Kernel.system("perl #{$scripts}/ct-mkview.pl -raw -name #{view} -dynamic -spec #{cspec}")
	return $? == 0
end

# Sets the given view with the given cspec
def set_view_cspec(view, cspec)
	Kernel.system("cleartool setcs -tag #{view} #{cspec} > nul 2>&1")
	return $? == 0
end

#----------------------------------------------------------------------------------------------
# Handle command line args:
opts = Trollop::options do
	version "count-src-lines 1.0"
	opt :project,  "Project name", :type => String
	opt :view,     "View name", :type => String
	opt :here,     "Operate from current directory"
	opt :makeview, "Create view"
	opt :cspec,    "Configspec file", :type => String
	opt :total,    "Only print total"
	opt :files,    "Print individual files"
	opt :projects, "Print project names and exit"
	opt :verbose,  "Be verbose"
end

if opts[:projects]
	puts "Projects:"
	$projects.each { |p| puts "\t" + p[0] }
	exit
end

# Get the project hash from the hash-of-hashes by its name
project_name = opts[:project]
project = []
for p in $projects
	if project_name == p[0]
		project = p[1]
		break
	end
end
Trollop::die "Invalid project: #{opts[:project]}" if project == [];

from_here = opts[:here]
view = ENV['username'] + "_" + opts[:view]
makeview = opts[:makeview]
cspec = opts[:cspec]

$verbose = opts[:verbose]
$print_files = opts[:files]
$print_only_total = opts[:total]

#----------------------------------------------------------------------------------------------

if from_here
	puts "working in current directory" if $verbose
else
	# check whether we should use the current view
	if !view && !makeview
		cview = curr_view
		Trollop::die "cannot determine ClearCASE view" if !cview
		view = curr_view
	else
		view = ENV['username'] + "_srclines_" + project_name if !view

		if makeview
			Trollop::die "view #{view} already exists" if start_view(view)
			Trollop::die "cannot create view: have not specified configspec" if !cspec
			unless create_view(view, cspec)
				Trollop::die "cannot create view #{view} due to ClearCASE error"
			end
		else
			Trollop::die "view #{view} does not exists" unless start_view(view)
			if cspec
				puts "setting configspec of view #{view} to #{cspec}" if $verbose
				set_view_cspec(view, cspec)
			end
		end
	end

	vdir = view_dir(view)
	Trollop::die "view #{view} is not accessible" if !File.directory?(vdir)
	puts "working in view #{view}" if $verbose
	Dir.chdir vdir
end

#----------------------------------------------------------------------------------------------
# for each of the projects, go over all the vobs and count the number of lines (exluding selected files)
lines = 0
for g in project
	vobs = g[1]
	for vob in vobs
		n = count_lines(vob, find_excludes(vob))
		puts "#{vob} #{n}" if !$print_only_total
		lines += n
	end
end

puts ($print_only_total ? "" : "total: ") + "#{lines}"
