@echo off

setlocal
set bat2exe=%NBU_BUILD_ROOT%\sys\util\bat2exe\head\x86\bat2exe.exe

%bat2exe% -bat ..\stop-auto-updates.bat -save stop-auto-updates-d.exe -invisible -overwrite 
