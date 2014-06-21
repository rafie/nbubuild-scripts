@echo off

setlocal
call set-nbu-build-env.bat

set BARTQ_ROOT=%NBU_BUILD_ROOT%\sys\tools\bart\v2\002
%NBU_BUILD_PERL%\bin\perl.exe %BARTQ_ROOT%\bart.pl %*
exit /b %errorlevel%
