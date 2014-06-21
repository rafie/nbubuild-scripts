@echo off

call \\storage\nbu\build\sys\scripts\bin\start-nbu-shares.bat
call set-nbu-build-env.bat
call %NBU_BUILD_ROOT%\sys\scripts\bin\intro\nbu-env-start.bat
