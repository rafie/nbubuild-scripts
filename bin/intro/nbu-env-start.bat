@echo off

call mount-nbu-vobs.bat
perl %NBU_BUILD_ROOT%\sys\scripts\bin\start-user-views.pl
call start-pageant.bat
