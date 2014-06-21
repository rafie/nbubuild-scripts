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

print "\nFixing network configuration...\n\n";

# set system-wise DNS search suffixes and eth0 DNS suffix
my @suffixes = qw(vbu.avaya.com rnd.avaya.com emea.avaya.com RADVISION.com global.avaya.com);
my $search_list = join(',', @suffixes);
systemx("reg add HKEY_LOCAL_MACHINE\\SYSTEM\\CurrentControlSet\\services\\Tcpip\\Parameters /f /v SearchList /t REG_SZ /d $search_list");
set_eth0_dns_suffix("emea.avaya.com");

# configure inet proxy (zscaler)
systemx("reg import inet-proxy.reg");

# stop and disable firewall
systema("sc config mpssvc start= disabled");
systema("sc stop mpssvc");

# enable persistent network drive maps 
systemx("reg add \"HKEY_LOCAL_MACHINE\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Policies\\System\" /f /v EnableLinkedConnections /t REG_DWORD /d 1");

# map drivers
systemx("drives.bat");

# instal printers
systemx("cscript //b //nologo printers.vbs");

exit(0);

sub set_eth0_dns_suffix
{
	my ($domain) = @_;

	my $nics = $Registry->{q"HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\services\Tcpip\Parameters\Interfaces"};
	foreach my $ifguid ($nics->SubKeyNames)
	{
		my $conn = $Registry->{q"HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Network\{4D36E972-E325-11CE-BFC1-08002BE10318}"}->{$ifguid}->{"Connection"};
		next if ! $conn;
		my $ifname = $conn->{Name};
	 	next if ! ($ifname eq "Local Area Connection" || $ifname eq "eth0");
	 	
	 	my $params = $Registry->{q"HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\services\Tcpip\Parameters\Interfaces"}->{$ifguid};
		$params->{"Domain"} = $domain;
	}
}
