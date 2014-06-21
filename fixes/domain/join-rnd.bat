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

my $host = $ENV{COMPUTERNAME};
my $user = $ENV{USERNAME};

my $rsat = "$root/sys/util/rsat";
my $netdom = "$rsat/netdom";

print "\nJoining $domain domain...\n";
systema("$netdom join $host /Domain:$domain /UserD:$domain\\$dom_user /PasswordD:$dom_pwd /UserO:rvroot /PasswordO:RvShos42");
# systemi("$netdom join $host /Domain:$domain /UserD:$user /PasswordD:* /UserO:rvroot /PasswordO:RvShos42 >nul 2>&1");

# check if we landed in new domain
my $sysdomain = $Registry->{q"HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\services\Tcpip\Parameters\NV Domain"};
die "Problem in switching to $domain domain.\n" if $sysdomain ne $domain;

print "\nSuccesfully moved machine to domain $domain.\n";
print "Please reboot.\n";
exit(0);
