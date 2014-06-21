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

my $wmic = systema("wmic os get version | cat");
my $is_xp = $wmic->out(1) =~ /^5/;

my $domain = "RADVISION.com";
my $host = $ENV{COMPUTERNAME};
my $user = $ENV{USERNAME};
my $rsat = "$ENV{NBU_BUILD_ROOT}/sys/util/rsat";
my $netdom = $is_xp ? "netdom" : "$rsat/netdom";

chdir("$ENV{NBU_BUILD_ROOT}/sys/util/winxp") if $is_xp;

print "\nMoving machine to domain $domain...\n";

# netdom may return false negative result. we'll check in registery for the actual outcome.
systema("$netdom move $host /Domain:$domain /UserD:RADVISION\\vmadmin /PasswordD:giraFFFe5 /UserF:GLOBAL\\rvroot /PasswordF:Wallenberg.01");
# print "Please enter your GLOBAL password:\n";
# systemi("$netdom move $host /Domain:$domain /UserD:RADVISION\\vmadmin /PasswordD:giraFFFe5 /UserF:$user /PasswordF:* >nul 2>&1");

# check if we landed in new domain
my $sysdomain = $Registry->{q"HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\services\Tcpip\Parameters\NV Domain"};
die "Problem in switching to $domain domain.\n" if $sysdomain ne $domain;

print "\nSuccesfully moved machine to domain $domain.\n";

exit(0);
