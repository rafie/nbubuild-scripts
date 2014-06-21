@rem ='
@echo off
setlocal
call set-nbu-build-env.bat
%NBU_BUILD_PERL%\bin\perl.exe -S %0 %*
pause
exit /b %errorlevel%
@rem ';
#line 10

use strict;

use FindBin;
use Term::ReadKey;

use Scaffolds;

my $home = u2w($FindBin::Bin);
chdir($home);

my $wlan = systema("netsh wlan show interfaces");
die "Cannot find Wifi interface. Aborting.\n" if $wlan->failed;

my $csproduct = systema("wmic csproduct get name");
my $model = lc($csproduct->out(1));
die "Cannot configure OptiPlex desktop workstation.\n" if $model =~ /optiplex/;

print "Installing an SSL Certificate...\n";
systema("certutil -f -addstore -enterprise root ATA_CA_Cert.cer")->ordie("Error.");
	
print "Configuring Wireless SSID...\n";
systema("netsh wlan add profile filename=\"avayaWirelessSettings.xml\" interface=w*")->ordie("Error.");

print "OK.\n";
exit(0);
