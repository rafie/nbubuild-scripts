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

my $domain = "global.avaya.com";
my $host = $ENV{COMPUTERNAME};
my $global_user = $ENV{GLOBAL_USERNAME};
$global_user = $ENV{USERNAME} if ! $global_user;
my $rsat = "$ENV{NBU_BUILD_ROOT}/sys/util/rsat";
my $netdom = $is_xp ? "netdom" : "$rsat/netdom";

chdir("$ENV{NBU_BUILD_ROOT}/sys/util/winxp") if $is_xp;

print "\nMoving machine to domain $domain...\n";

# netdom may return false negative result. we'll check in registery for the actual outcome.
my $try1 = systema("$netdom move $host /Domain:$domain /UserD:GLOBAL\\rvroot /PasswordD:Wallenberg.01 /UserF:RADVISION\\vmadmin /PasswordF:giraFFFe5");
if (! is_in_domain($domain))
{
	# rvroot may lack sufficient permissions to join GLOBAL domain
	# will try with GLOBAL username
	print "Please enter your GLOBAL password:\n";
	systemi("$netdom move $host /Domain:$domain /UserD:$global_user /PasswordD:* /UserF:vmadmin /PasswordF:giraFFFe5 >nul 2>&1");

	# check if we landed in new domain
	die "Problem in switching to $domain domain.\n" if ! is_in_domain($domain);
}

print "\nSuccesfully moved machine to domain $domain.\n";

exit(0);

sub is_in_domain
{
	my ($domain) = @_;
	
	my $sysdomain = $Registry->{q"HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\services\Tcpip\Parameters\NV Domain"};	
	return $sysdomain eq $domain;
}
