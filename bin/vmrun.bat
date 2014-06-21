@echo off

setlocal

set vmrun=%NBU_BUILD_ROOT%\sys\vm\vmware-vix\vmrun.exe
set vcenter=vbu-vcenter.emea.avaya.com

%vmrun% -h %vcenter% -T vc -u root -p RvShos42 %*
