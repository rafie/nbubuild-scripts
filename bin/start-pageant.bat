@echo off

setlocal
set keyfile=%NBU_BUILD_ROOT%\usr\%USERNAME%\cfg\pageant\putty.ppk
if not exist %keyfile% goto error
start %NBU_BUILD_ROOT%\sys\scripts\bin\rvputty\pageant.exe %keyfile%
goto quit

:error
echo Pageant key file for user %USERNAME% does not exist.
echo See http://nbuwiki/wiki/index.php/Pageant_Key_Installation for installation instructions.

:quit
