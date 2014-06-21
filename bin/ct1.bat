@echo off

setlocal
call set-nbu-build-env.bat
%NBU_BUILD_PERL%\bin\perl.exe %NBU_BUILD_ROOT%\sys\scripts\ccase\ct1\ct1.pl %*
exit /b %errorlevel%
