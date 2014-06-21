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

print "\nHotkeys settings...\n";

my $home = realpath($FindBin::Bin . "/..");
chdir($home);

systemx("reg import disable-winkeys.reg");
systemx("start %NBU_BUILD_ROOT%\sys\util\autohotkey\curr\AutoHotkey.exe %NBU_BUILD_ROOT%\sys\scripts\ahk\hotkeys.ahk");

exit(0);
