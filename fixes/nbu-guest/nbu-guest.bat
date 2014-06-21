@echo off

setlocal
set user=%1
set domain=RADVISION
if exist r:\ goto L1
if not "%user%" == "" goto L2
set /p user="Login as: "

:L2
net use r: \\storage\NBU /user:%domain%\%user%
if exist r: goto L1
echo Cannot map \\storage\NBU. Aborting.
exit /b 1

:L1
call r:\Build\sys\scripts\bin\nbu-guest.bat
