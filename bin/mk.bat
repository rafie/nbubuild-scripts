@echo off

setlocal
call set-nbu-build-env.bat
%NBU_BUILD_PERL%\bin\perl.exe %NBU_BUILD_ROOT%\sys\scripts\bin\mk.pl %*
exit /b %errorlevel%
