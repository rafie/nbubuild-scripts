
require_relative 'Common'

#----------------------------------------------------------------------------------------------

module ClearCASE

#----------------------------------------------------------------------------------------------

class StorageLocation
	attr_reader :local_stg, :global_stg
end # StorageLocation

#----------------------------------------------------------------------------------------------

class LocalStorageLocation < StorageLocation

	CleartoolViewTool_key = "Software\\Atria\\ClearCase\\CurrentVersion\\clearviewtool"
	LastViewDir_val = "Last View Dir"

	def initialize
		if find_in_reg || find_local_view || make_stgloc
			vobs = "#{@local_stg}/.vobs"
			File.mkdir(vobs) if ! Dir.exists?(vobs)
			return true
		end
		raise "cannot determine storage location"
	end
	
	def find_in_reg
		begin
			Win32::Registry::HKEY_CURRENT_USER.open(CleartoolViewTool_key, Win32::Registry::KEY_READ) do |key|
				@global_stg = key[LastViewDir_val]
			end
		rescue
			return false
		end

		return false if @global_stg.empty?
		host, share, share_path = unc_split(@global_stg)
		net_share = System.commandx("net share #{share}")
		net_share.out.lines.each do |line|
			@local_stg = $1 if line =~ /Path *(.*)/
		end
		return !@local_stg.empty?
	end

	def unc_split(unc)
		unc = unc[1..-1] if unc[0..1] == "\\\\"
		p = []
		while true do
			unc1 = unc
			unc, d = File.split(unc)
			break if unc == unc1
			p << d
		end
		p.reverse!
		host = p.shift
		share = p.shift
		path = p.join("\\")
		return host, share, path
	end

	def find_local_view
		host = System.hostname
		lsview = System.commandx("cleartool lsview -short -quick -host #{host}")
		view = lsview.out0
		return false if view.empty?

		lsview = System.commandx("cleartool lsview -long #{view}")
		lsview.out.lines.each do |line|
			@global_stg = $1 if line =~ /Global path\: (.*)/
			@local_stg = $1 if line =~ /View server access path\: (.*)/
		end
		
		return false if @global_stg.empty? || @local_stg.empty?
	
		@global_stg = File.dirname(@global_stg)
		@local_stg = File.dirname(@local_stg)
		return true
	end
	
	def make_stgloc
		host = System.hostname
		share = 'ccstg1'
		@local_stg = "c:\\#{share}";
		@global_stg = "\\\\#{host}\\#{share}";
	
		Dir.mkdir(@local_stg)
		net_share = System.commandx("net share #{share}=#{@local_stg} /remark:\"ClearCASE Views Storage\" /unlimited")
		
		base = "Software\\Atria\\ClearCase\\CurrentVersion\\clearviewtool"
		begin
			Win32::Registry::HKEY_CURRENT_USER.open(CleartoolViewTool_key, Win32::Registry::KEY_WRITE) do |key|
				key[LastViewDir_val] = @global_stg
			end
		rescue
		end

		return true
	end
	

end # LocalStorageLocation

#----------------------------------------------------------------------------------------------

class RemoteStorageLocation < StorageLocation
end # RemoteStorageLocation

#----------------------------------------------------------------------------------------------

end # module ClearCASE
