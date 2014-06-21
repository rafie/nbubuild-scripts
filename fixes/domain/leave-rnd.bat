@rem ='
@echo off
setlocal
call set-nbu-build-env.bat
%NBU_BUILD_PERL%\bin\perl.exe -S %0 %*
exit /b %errorlevel%
@rem ';
#line 9

use strict;

use Win32::TieRegistry;

use Scaffolds::System;
use Scaffolds::Util;

my $root = $ENV{NBU_BUILD_ROOT};

my $domain = "rnd.avaya.com";
my $dom_user = "rvadmin";
my $dom_pwd = q(@v@y@123!);

my $workgroup = "RADVISION";

my $host = $ENV{COMPUTERNAME};
my $user = $ENV{USERNAME};

my $rsat = "$root/sys/util/rsat";
my $netdom = "$rsat/netdom";

print "\nLeaving $domain domain...\n";
systema("$netdom remove $host /Domain:$domain /UserD:$domain\\$dom_user /PasswordD:$dom_pwd");

# check if we left domain
my $sysdomain = $Registry->{q"HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\services\Tcpip\Parameters\NV Domain"};
die "Problem leaving $domain domain.\n" if $sysdomain eq $domain;

systema("wmic computersystem where name=\"$host\" call joindomainorworkgroup name=\"$workgroup\"");

print "\nSuccesfully moved machine to workgroup $workgroup.\n";
print "Please reboot.\n";
exit(0);
