
require 'enumerator'
require 'pathname'
require 'win32/registry'
require 'uuid'

require_relative '../System.rb'

#----------------------------------------------------------------------------------------------

module ClearCASE

#----------------------------------------------------------------------------------------------

DEFAULT_ADMIN_VOB = "TBU_PVOB_2"
# DEFAULT_ADMIN_VOB = ".test"
DEFAULT_GROUP = "rvil_ccusers"
DEFAULT_WIN_REGION = "radvision_nt"
DEFAULT_UNIX_REGION = "radvision"

#----------------------------------------------------------------------------------------------

def ClearCASE.rootdir
  Win32::Registry::HKEY_LOCAL_MACHINE.open("SOFTWARE\\Atria\\ClearCase\\CurrentVersion")["HostData"]
end

#----------------------------------------------------------------------------------------------

def ClearCASE.utility(name)
  root = ClearCASE.rootdir
  "\"#{root}\\etc\\utils\\#{name}\""
end

#----------------------------------------------------------------------------------------------

class UUID < String
	def initialize
		s = ::UUID.new.generate.delete('-')
		super(s[0..7] + "." + s[8..15] + "." + s[16..19] + "." + s[20..21] +
		 ":" + s[22..23] + ":" + s[24..25] + ":" + s[26..27] + ":" + s[28..29] + ":" + s[30..31])
	end
end # UUID

#----------------------------------------------------------------------------------------------

class Explorer

	# modifies the registry to create ClearCase explorer shortcut
	# only works for dynamic views

	def Explorer.add_view_shortcut(name)
		ccase_exporer_key = "Software\\Atria\\ClearCase\\CurrentVersion\\ClearCase Explorer\\ViewsPage\\General"

		Win32::Registry::HKEY_CURRENT_USER.open(ccase_exporer_key).create(name)
		Win32::Registry::HKEY_CURRENT_USER.open("#{ccase_exporer_key}\\#{name}") do |key|
			key["AccessString"] = "M:\\#{name}"
			key["Default"] = 0
			key["Dependency"] = ""
			key["IconKey"] = 30
			key["IntegrationView"] = 0
			key["LastFolder"] = ""
			key["ProjectName"] = ""
			key["Redefined"] = 0
			key["Removed"] = 0
			key["SnapshotView"] = 0
			key["ToolTip"] = name
			key["Type"] = "view"
			key["UcmView"] = 0
			key["UsesDriveMapping"] = 0
			key["Version"] = 1
			key["Visible"] = 1
		end
	end

end # Explorer

#----------------------------------------------------------------------------------------------

end # module ClearCASE
