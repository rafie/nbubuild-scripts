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

log_hello();

my $root = $ENV{NBU_BUILD_ROOT};

print "\nConfiguring Avaya workstation...\n";
chdir("$root/sys/scripts/fixes/avaya-win7") or die $!;
systemi("fix.bat")->ordie("Failed in Avaya workstation configuration.\n");

print "\nInstalling ClearCase Client...\n";
chdir("$root/sys/scripts/ccase/setup/client/windows/8.0.0.6") or die $!;
systemi("install.bat avaya")->ordie("Installation of ClearCase Client failed.");

print "\nStage 2 completed successfully.\n";
print "You can reboot now.\n";

exit(0);
