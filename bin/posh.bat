@echo off

setlocal
set f=
if not "%*" == "" set f=-f %*
%SystemRoot%\system32\WindowsPowerShell\v1.0\powershell.exe %f%
