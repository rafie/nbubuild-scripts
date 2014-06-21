if exist %windir%\msys.ini goto quit
echo [InstallSettings] > %windir%\msys.ini
echo InstallPath=%NBU_BUILD_ROOT%\sys\msys\1.0 >> %windir%\msys.ini

:quit
