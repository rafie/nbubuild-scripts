@rem ='
@echo off
if not exist r:\ net use r: \\storage.RADVISION.com\NBU
call set-nbu-build-env.bat
%NBU_BUILD_PERL%\bin\perl.exe -S %0 %*
exit /b %errorlevel%
@rem ';
#line 9

use strict;

use Scaffolds::System;
use Scaffolds::Util;

my $root = $ENV{NBU_BUILD_ROOT};

my $domain = "rnd.avaya.com";
my $host = $ENV{COMPUTERNAME};

my $rsat = "$root/sys/util/rsat";
my $netdom = "$rsat/netdom";

print "\nClearCase post-installation...\n";
chdir("$root/sys/scripts/ccase/setup/client/windows/post") or die $!;
systemi("setup.bat")->ordie("ClearCase Post-installation.\n");

print "\nLeaving $domain domain...\n";
my $password = q(@v@y@123!);
systema("$netdom remove $host /Domain:$domain /UserD:$domain\\rvadmin /PasswordD:$password /UserO:rvroot /PasswordO:RvShos42 /force");

print "Please reboot.\n";

exit(0);
