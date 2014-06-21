@rem ='
@echo off
setlocal
call set-nbu-build-env.bat
%NBU_BUILD_PERL%\bin\perl.exe -S %0 %*
exit /b %errorlevel%
@rem ';
#line 9

use strict;

use File::Copy::Recursive qw(dircopy rcopy);

use Scaffolds::System;
use Scaffolds::Util;

my $root = $ENV{NBU_BUILD_ROOT};

my $domain = "rnd.avaya.com";
my $host = $ENV{COMPUTERNAME};

my $rsat = "$root/sys/util/rsat";
my $netdom = "$rsat/netdom";

print "\nCopying scripts to local drive...\n";
dircopy("$root/sys/scripts/machines/robot", "c:/robot-setup") or die $!;

chdir("$root/sys/scripts/fixes");

systemi("avaya-global-policy\\fix.bat") if ! $ENV{DEVITO_SYSEVENTS};

print "\nAdding local admins...\n";
add_local_admins();

print "\nSwitching to $domain domain...\n";
my $password = q(@v@y@123!);
# systema("$netdom move $host /Domain:$domain /UserD:$domain\\rvadmin /PasswordD:$password /UserF:rvroot /PasswordF:RvShos42");
systema("$netdom join $host /Domain:$domain /UserD:$domain\\rvadmin /PasswordD:$password");

print "\nStage 1 completed successfully.\n";
print "Please add system event scripts via gpedit.msc.\n";
print "Afterwards, please reboot.\n";
print "After reboot, please login as local Administrator.\n";

exit(0);

sub add_local_admins
{
	systema("net user rvroot RvShos42 /add /passwordchg:yes /expires:never");
	systema("net localgroup Administrators rvroot /add");

	return 0;
}
