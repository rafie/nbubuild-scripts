@rem ='
@echo off
if not exist r:\ net use r: \\storage.RADVISION.com\NBU
call set-nbu-build-env.bat
%NBU_BUILD_PERL%\bin\perl.exe -S %0 %*
exit /b %errorlevel%
@rem ';
#line 9

use strict;

use FindBin;

use Scaffolds::System;
use Scaffolds::Util;

my $root = $ENV{NBU_BUILD_ROOT};

print "\nSetting up Avaya robot...\n";

chdir("$root/sys/scripts/fixes");

systemxi("win2008r2\\fix.bat");
systemxi("ipv6\\fix.bat");
systemxi("network\\fix.bat");

print "\nInstalling ClearCase Client...\n";
chdir("$root/sys/scripts/ccase/setup/client/windows/8.0.0.6") or die $!;
systemi("install.bat avaya")->ordie("Installation of ClearCase Client failed.");

print "\nStage 3 completed successfully.\n";
print "You can reboot now.\n";

exit(0);

sub add_local_admins
{
	systema("net localgroup Administrators GLOBAL\\rvroot /add");
	systema("net localgroup Administrators GLOBAL\\rvrobot /add");

	return 0;
}
