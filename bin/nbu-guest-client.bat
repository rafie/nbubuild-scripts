@echo off

setlocal
set root=\\storage\NBU
set user=%1
set domain=RADVISION
if exist r:\ goto L1
if not "%user%" == "" goto L2
set /p user="Login as: "

:L2
net use r: %root% /user:%domain%\%user%
if exist r: goto L1
echo Cannot map %root%. Aborting.
exit /b 1

:L1
call r:\Build\sys\scripts\bin\nbu-guest.bat
