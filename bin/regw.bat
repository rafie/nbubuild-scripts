@echo off

setlocal
set RegistryWorkshop_path=R:\Mcu_Ngp\Utilities\RegistryWorkshop\latest
if defined ProgramFiles(x86) (
	set RegistryWorkshop_command=%RegistryWorkshop_path%\RegWorkshopX64.exe
) else (
	set RegistryWorkshop_command=%RegistryWorkshop_path%\RegWorkshop.exe
)
start %RegistryWorkshop_command%
