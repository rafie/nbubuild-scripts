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

my $ver = systema("ver");
my $is_xp = $ver->out(1) =~ /Version 5/;

my $to_domain = "rnd.avaya.com";
my $to_admin = "RND\\rvadmin";
my $to_admin_pwd = q(@v@y@123!);

my $from_admin = "RADVISION\\vmadmin";
my $from_admin_pwd = q(giraFFFe5);

my $host = $ENV{COMPUTERNAME};
my $rsat = "$ENV{NBU_BUILD_ROOT}/sys/util/rsat";
my $netdom = $is_xp ? "netdom" : "$rsat/netdom";

chdir("$ENV{NBU_BUILD_ROOT}/sys/util/winxp") if $is_xp;

print "\nMoving machine to domain $to_domain...\n";

# netdom may return false negative result. we'll check in registery for the actual outcome.
my $try1 = systema("$netdom move $host /Domain:$to_domain /UserD:$to_admin /PasswordD:$to_admin_pwd /UserF:$from_admin /PasswordF:$from_admin_pwd");

# check if we landed in new domain
die "Problem in switching to $to_domain domain.\n" if ! is_in_domain($to_domain);

print "\nSuccesfully moved machine to domain $to_domain.\n";

exit(0);

sub is_in_domain
{
	my ($domain) = @_;
	
	my $sysdomain = $Registry->{q"HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\services\Tcpip\Parameters\NV Domain"};	
	return $sysdomain eq $domain;
}
