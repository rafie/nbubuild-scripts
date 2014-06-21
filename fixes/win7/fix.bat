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

print "\nFixing Windows 7 configuration...\n\n";

systema("allow-rdc.bat");
systema("tempdir.bat");
systemx("disable-offline-files.bat");
systemx("reg import disable-aero-peek.reg");
systemx("reg import putty-hyperlink.reg");
systemx("reg import chm-from-network.reg");
systemx("reg import java.reg");
systemx("reg import international.reg");
systemx("reg import keyboard.reg");
systemx("reg import lync2010.reg");
systemx("reg import sounds.reg");
systemx("reg import folders.reg");
systemx("reg import screen-saver.reg");
systemx("cifs-shares.bat");
systemx("symbolic-links.bat");

exit(0);
