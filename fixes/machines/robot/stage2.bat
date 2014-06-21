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

print "\nAdding local admins...\n";
add_local_admins();

systema("$root/sys/util/sysinternals/autologon.exe rvrobot GLOBAL RvShos42");

print "\nStage 2 completed successfully.\n";
print "Please logout and login as GLOBAL\\robot.\n";

exit(0);

sub add_local_admins
{
	systema("net user rvroot RvShos42 /add /passwordchg:yes /expires:never");
	systema("net localgroup Administrators rvroot /add");

	systema("net localgroup Administrators GLOBAL\\rvroot /add");
	systema("net localgroup Administrators GLOBAL\\rvrobot /add");

	return 0;
}
