@rem ='
@echo off
setlocal
call set-nbu-build-env.bat
%NBU_BUILD_PERL%\bin\perl.exe -S %0 %*
exit /b %errorlevel%
@rem ';
#line 9

use Cwd qw(realpath);
use FindBin;

use Scaffolds;

my $home = u2w($FindBin::Bin);
chdir($home);

systemxi("systemlog.bat", { log => 0 });
exit(0);
