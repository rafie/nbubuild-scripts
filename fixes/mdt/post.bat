@rem ='
@echo off
if not exist r:\ net use r: \\storage.RADVISION.com\NBU /user:GLOBAL\rvrobot RvShos42
call set-nbu-build-env.bat
%NBU_BUILD_PERL%\bin\perl.exe -S %0 %*
exit /b %errorlevel%
@rem ';
#line 9

use strict;

use Cwd qw(realpath);
use File::Copy::Recursive qw(dircopy rcopy);
use FindBin;

use Scaffolds::System;
use Scaffolds::Util;

my $root = $ENV{NBU_BUILD_ROOT};
		
add_local_admin();

systemx("$root/sys/scripts/fixes/avaya-win7/fix.bat");
systemx("$root/sys/scripts/fixes/clearcase/fix.bat");
systemx("mount-nbu-vobs");

exit(0);

sub add_local_admin
{
print "\nAdding local admins...\n";
	systema("net user rvroot RvShos42 /add /passwordchg:yes /expires:never");
	systema("net localgroup Administrators rvroot /add");

	return 0;
}
