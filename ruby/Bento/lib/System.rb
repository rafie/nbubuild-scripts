
require 'open3'
require 'socket'
require 'tempfile'

module System

SystemLogFile = "c:/system.log"

#----------------------------------------------------------------------------------------------

def System.user
	ENV['USERNAME']
end

def System.domain
	ENV['USERDOMAIN']
end

#----------------------------------------------------------------------------------------------

def System.hostname
	Socket.gethostname
end

#----------------------------------------------------------------------------------------------

def System.command(cmd, *opt)
	return Command.new(cmd, *opt)
end

#----------------------------------------------------------------------------------------------

def System.commandx(cmd, *opt)
	c = Command.new(cmd, *opt)
	raise "Error in System.command(#{cmd})" if c.status != 0
	return c
end

#----------------------------------------------------------------------------------------------

class Command
	attr_reader :out, :err

	def initialize(prog, *opt)
		no_log = opt.include?(:nolog)
		no_outlog = no_log ? true : opt.include?(:outlog)
		no_errlog = no_log ? true : opt.include?(:errlog)
	
		when_ = Time.now.strftime("%y-%m-%d %H:%M:%S")
		where = Dir.pwd
	
		fout = Tempfile.new('sysout.')
		fout.close
		ferr = Tempfile.new('syserr.')
		ferr.close
		t0 = Time.now
		system("#{prog} 1> #{fout.path} 2> #{ferr.path}")
		@status = $?
		elapsed_sec = Time.now - t0
	
		if no_log
			@out = _append(nil, fout)
			@err = _append(nil, ferr)
		else
			begin
				log = File.new(SystemLogFile, "a+")
				log.puts "=== #{when_} (#{elapsed_sec}s) [#{where}]"
				log.puts prog
				log.puts "--- (#{status})"
		
				@out = _append(no_outlog ? nil : log, fout)
				log.puts "---"
	
				@err = _append(no_errlog ? nil : log, ferr)
				log.close
			rescue
				sleep 1 + rand
				retry
			end
		end
	end

#	# disabled due to Open3.capture3 bug on Windows
#	def initialize(cmd, *opt)
#		@out, @err, @status = Open3.capture3(cmd)
#		if ! opt.include?(:nolog)
#			log = File.open("c:/system.log", "a")
#			log.puts cmd
#			log.puts "---"
#			log.puts @out
#			log.puts "---"
#			log.puts @err
#			log.puts "=== (#{@status.exitstatus})"
#			log.close	
#		end
#	end
	
	def out0
		line = out.lines.first
		line == nil ? "" : line.chomp
	end

	def err0
		line = err.lines.first.chomp
		line == nil ? "" : line.chomp
	end
	
	def status
		@status.exitstatus
	end
	
	def failed?
		status != 0
	end
	
	def ok?
		status == 0
	end

private
	def _append(log, file)
		text = ""
		File.open(file.path) do |f|
			f.lines.each do |line|
				log.write line if log
				text += line
			end
		end
		file.close
		file.unlink
		return text
	end

end # Command

#----------------------------------------------------------------------------------------------

class RemoteCommand

	def initialize(cmd, *opt)
	end

end # RemoteCommand

#----------------------------------------------------------------------------------------------

end # modules System
