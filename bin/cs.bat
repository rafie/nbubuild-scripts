@echo off

if "%1" == "/?" goto help
%NBU_BUILD_ROOT%\dev\lang\cs-script\3.4.0\cscs.exe /nl %*
exit /b

:help
%NBU_BUILD_ROOT%\dev\lang\cs-script\3.4.0\cscs.exe /?
