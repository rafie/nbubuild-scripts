@echo off

setlocal
if "%1"=="" goto usage

set d=%NBU_BUILD_ROOT%\usr\%USERNAME%\cfg\pageant
set f=%1
mkdir %d%
copy %f% %d%\putty.ppk
goto quit

:usage
echo Usage: install-pageant-key file.ppk

:quit
