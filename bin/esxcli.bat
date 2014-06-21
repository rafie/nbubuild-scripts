@echo off

setlocal

set esxcli=%NBU_BUILD_ROOT%\sys\vm\vsphere-cli\5.5\bin\esxcli.exe
set vcenter=vbu-vcenter.emea.avaya.com

%esxcli% --vihost %vcenter% --username root --password RvShos42 %*
