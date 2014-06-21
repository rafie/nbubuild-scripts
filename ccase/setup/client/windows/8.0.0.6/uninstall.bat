@rem ='
@echo off
setlocal
call set-nbu-build-env.bat
%NBU_BUILD_PERL%\bin\perl.exe -S %0 %*
exit /b %errorlevel%
@rem ';
#line 9

use strict;

use Scaffolds::System;

# my $services = systema("net start");
# if (! ($services->outText =~ /Atria/))
# {
# 	print "ClearCase client is not installed.\n";
# 	exit(0);
# }

my $ccver = "8.0.0.6";
my $imver = "1.6.2";

my $root = $ENV{NBU_BUILD_ROOT};
my $ccase = "$root/sys/scripts/ccase/setup/client/windows/$ccver";
my $inst_mgr = "$root/sys/scripts/ccase/setup/installation-manager/windows/$imver";

my $installer="IBMIMc.exe --launcher.ini silent-install.ini -ShowVerboseProgress";

my $progs = $ENV{"ProgramFiles(x86)"};
if (! $progs || ! -d $progs)
{
	$progs = $ENV{ProgramFiles};
	die "Error: cannot determine Program Files directory.\n" if ! $progs || ! -d $progs;
}

chdir("$progs/IBM/Installation Manager/eclipse") or die "Error: cannot find Installation Manager.\n";

# systema("$installer -input $ccase/uninstall/clearcase_uninstall_response_nt_i386_8.0.0.5_8.0.0.X.xml")->ordie("Removal of ClearCase client failed.");

systema("$installer -input $ccase/uninstall/clearcase_uninstall_response_nt_i386.xml")->ordie("Removal of ClearCase client failed.");

systema("perl $inst_mgr/uninstall.bat")->ordie("Removal of installation manager failed.");

print "OK.\n";
print "Please reboot your machine.\n";

exit(0);
