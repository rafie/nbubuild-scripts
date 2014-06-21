@echo off

setlocal
call set-nbu-build-env.bat
if "%1" == "--debug" set __debug=-d
%NBU_BUILD_PERL%\bin\perl.exe %__debug% %NBU_BUILD_ROOT%\sys\scripts\vm\vm.pl %*
exit /b %errorlevel%
