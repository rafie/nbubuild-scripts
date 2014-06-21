@rem ='
@echo off
setlocal
call set-nbu-build-env.bat
%NBU_BUILD_PERL%\bin\perl.exe -S %0 %*
exit /b %errorlevel%
@rem ';
#line 9

use strict;

use FindBin;
use Win32::TieRegistry;

use Scaffolds::System;
use Scaffolds::Util;

my $home = u2w($FindBin::Bin);
chdir($home);

print "\nFixing various permissions...\n\n";

# add storage.RADVISION.com to trusted sites
systemx("reg add \"HKEY_CURRENT_USER\\Software\\Microsoft\\Windows\\CurrentVersion\\Internet Settings\\ZoneMap\\Domains\\RADVISION.com\\storage\" /f /v file /t REG_DWORD /d 2");
systemx("reg add \"HKEY_CURRENT_USER\\Software\\Microsoft\\Windows\\CurrentVersion\\Internet Settings\\ZoneMap\\Domains\\emea.avaya.com\\storage\" /f /v file /t REG_DWORD /d 2");
systemx("reg add \"HKEY_CURRENT_USER\\Software\\Microsoft\\Windows\\CurrentVersion\\Internet Settings\\ZoneMap\\Domains\\global.avaya.com\\storage\" /f /v file /t REG_DWORD /d 2");
# @@ add nx1 here

# add users to local administrators group
add_local_admins();

# .net stuff
systemx("dotnet-network-permissions.bat");

exit(0);

sub add_local_admins
{
	systema("net user rvroot RvShos42 /add /passwordchg:yes /expires:never");

	systema("net localgroup Administrators rvroot /add");
	systema("net localgroup Administrators GLOBAL\\rvroot /add");

	return 0;
}
