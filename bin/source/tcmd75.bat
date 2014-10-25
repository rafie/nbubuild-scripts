@echo off

setlocal
call set-nbu-build-env.bat

set UserConfigRoot_path=%NBU_BUILD_ROOT%\usr\%NBU_USERNAME%\cfg

set TotalCommander_path=R:\Mcu_Ngp\Utilities\TotalCommander\7.50
set TotalCommander_cfg_path=%UserConfigRoot_path%\total-commander\7.50
set TotalCommander_default_cfg_path=%TotalCommander_path%\config\7.50

set UltraEdit_ver=15.20
set UltraEdit_path=R:\Mcu_Ngp\Utilities\UltraEdit\%UltraEdit_ver%
set UltraEdit_cfg_base=%UserConfigRoot_path%\ultra-edit
set UltraEdit_cfg_path=%UltraEdit_cfg_base%\%UltraEdit_ver%
set UltraEdit_default_cfg_path=%UserConfigRoot_path%\ultra-edit\%UltraEdit_ver%\config
set UltraEdit_command=%UltraEdit_path%\uedit32.exe /i=%UltraEdit_cfg_path%\uedit32.ini

set BeyondCompare_path=R:\Mcu_Ngp\Utilities\BeyondCompare\head
set BeyondCompare_command=%BeyondCompare_path%\BCompare.exe

set PowerGREP_path=R:\Mcu_Ngp\Utilities\PowerGREP\latest
set PowerGREP_command=%PowerGREP_path%\PowerGREP.exe

set RegistryWorkshop_path=R:\Mcu_Ngp\Utilities\RegistryWorkshop\latest
if defined ProgramFiles(x86) (
	set RegistryWorkshop_command=%RegistryWorkshop_path%\RegWorkshopX64.exe
) else (
	set RegistryWorkshop_command=%RegistryWorkshop_path%\RegWorkshop.exe
)

if defined ProgramFiles(x86) (
	set ProcessExplorer_path=R:\Mcu_Ngp\Utilities\ProcessExplorer\latest
) else (
	set ProcessExplorer_path=R:\Mcu_Ngp\Utilities\ProcessExplorer\11.33
)
set ProcessExplorer_command=%ProcessExplorer_path%\procexp.exe

set ProcessMonitor_path=R:\Mcu_Ngp\Utilities\ProcessMonitor\latest
set ProcessMonitor_command=%ProcessMonitor_path%\Procmon.exe

set Depends_path=R:\Mcu_Ngp\Utilities\Depends
set Depends_command=%Depends_path%\Depends.exe

set _4NT_path=R:\Mcu_Ngp\Utilities\4NT\8.0
set _4NT_cfg_path=%UserConfigRoot_path%\4nt\8.0
set _4NT_default_cfg_path=%UserConfigRoot_path%\4NT\8.0\config\default
set _4NT_command=%_4NT_path%\4nt.exe

set Putty_path=R:\Mcu_Ngp\Utilities\Putty
set Putty_command=%Putty_path%\putty.exe

set Baretail_path=R:\Mcu_Ngp\Utilities\Baretail\2.5
set Baretail_command=%Baretail_path%\baretailpro.exe

: -----------------------------------------------------------------------------

if exist %TotalCommander_cfg_path% goto cfg_good

mkdir %TotalCommander_cfg_path%
copy %TotalCommander_default_cfg_path%\wincmd.ini  %TotalCommander_cfg_path% > nul
copy %TotalCommander_default_cfg_path%\default.br2 %TotalCommander_cfg_path% > nul
copy %TotalCommander_default_cfg_path%\wcx_ftp.ini %TotalCommander_cfg_path% > nul
copy %TotalCommander_default_cfg_path%\default.bar %TotalCommander_cfg_path% > nul

if not exist %UltraEdit_cfg_path% (
	mkdir %UltraEdit_cfg_path%
	copy %UltraEdit_default_cfg_path%\config\*.* %UltraEdit_cfg_path% > nul
)

mkdir %UltraEdit_cfg_path%
copy %UltraEdit_default_cfg_path%\uedit32.ini %UltraEdit_cfg_path% > nul

mkdir %_4NT_cfg_path%
copy %_4NT_default_cfg_path%\4nt.ini %_4NT_cfg_path% > nul

: -----------------------------------------------------------------------------
:cfg_good
call %TotalCommander_path%\totalcmd.bat %TotalCommander_cfg_path%
