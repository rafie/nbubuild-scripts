@echo off

setlocal
call set-nbu-build-env.bat

set STA_ROOT=%NBU_BUILD_ROOT%\sys\tools\lintq\v1\001
%NBU_BUILD_PERL%\bin\perl %STA_ROOT%\sta.pl %*
exit /b %errorlevel%
