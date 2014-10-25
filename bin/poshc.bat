@echo off

setlocal
set cmd=%*
%SystemRoot%\system32\WindowsPowerShell\v1.0\powershell.exe -c "& {%cmd%}"
