@rem ='
@echo off
setlocal
call set-nbu-build-env.bat
%NBU_BUILD_PERL%\bin\perl.exe -S %0 %*
exit /b %errorlevel%
@rem ';
#line 9

use strict;

use Cwd qw(realpath);
use FindBin;

use Scaffolds::System;
use Scaffolds::Util;

print "\nSetting up Avaya Windows 7 workstation...\n";

my $home = realpath($FindBin::Bin . "/..");
chdir($home);

systemxi("devito\\fix.bat");

systemi("avaya-global-policy\\fix.bat") if ! $ENV{DEVITO_SYSEVENTS};

systemxi("win7\\fix.bat");
systemxi("ipv6\\fix.bat");
systemxi("network\\fix.bat");
systemxi("powershell\\fix.bat");

systemxi("clearcase\\fix.bat");

exit(0);
