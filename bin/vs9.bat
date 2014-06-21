@echo off

if "%1" == "-h" goto help
if not exist "C:\Program Files (x86)\Microsoft Visual Studio 9.0\Common7\IDE\devenv.exe" exit /b
"C:\Program Files (x86)\Microsoft Visual Studio 9.0\Common7\IDE\devenv.exe" %*
exit /b

:help
type %NBU_BUILD_ROOT%\sys\scripts\bin\vs9.man
