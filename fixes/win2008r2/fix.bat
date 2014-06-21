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

use Scaffolds::System;
use Scaffolds::Util;

my $home = u2w($FindBin::Bin);
chdir($home);

print "\nFixing Windows 2008 R2 configuration...\n\n";

systemx("reg import putty-hyperlink.reg");
systemx("reg import chm-from-network.reg");
systemx("reg import keyboard.reg");
systemx("cifs-shares.bat");
systemx("symbolic-links.bat");

exit(0);
