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

print "\nClearCase post-installation...\n";
chdir("$root/sys/scripts/ccase/setup/client/windows/post") or die $!;
systemi("setup.bat")->ordie("ClearCase Post-installation.\n");

print "Please reboot.\n";

exit(0);
