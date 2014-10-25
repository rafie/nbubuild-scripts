@echo off

setlocal
set f=
if not "%*" == "" set f=-f %*
C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe -psc "D:\sys\vm\vmware\power-cli\vim.psc1" %f%
: -c ". \"D:\sys\vm\vmware\power-cli\Scripts\Initialize-PowerCLIEnvironment.ps1\""
: -noe