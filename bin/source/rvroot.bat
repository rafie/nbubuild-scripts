@echo off

copy %NBU_BUILD_ROOT%\sys\scripts\bin\rvroot\rvroot.bat %TEMP%\rvroot.bat > nul 2>&1
%NBU_BUILD_ROOT%\sys\util\ps-tools\latest\psexec.exe -accepteula -d -u GLOBAL\rvroot -p Wallenberg.01 cmd.exe /k %TEMP%\rvroot.bat > nul 2>&1
