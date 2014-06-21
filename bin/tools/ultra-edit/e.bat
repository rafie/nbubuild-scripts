@echo off

setlocal
set UltraEdit_ver=15.20

set UltraEdit_path=R:\Mcu_Ngp\Utilities\UltraEdit\%UltraEdit_ver%
set UltraEdit_cfg_base=%UserConfigRoot_path%\ultra-edit
set UltraEdit_cfg_path=%UltraEdit_cfg_base%\%UltraEdit_ver%
set UltraEdit_default_cfg_path=%UserConfigRoot_path%\ultra-edit\%UltraEdit_ver%\config
set UltraEdit_command=%UltraEdit_path%\uedit32.exe /i=%UltraEdit_cfg_path%\uedit32.ini

if exist %UltraEdit_cfg_path% goto go

mkdir %UltraEdit_cfg_path%
copy %UltraEdit_default_cfg_path%\config\*.* %UltraEdit_cfg_path% > nul

:go
start %UltraEdit_command% %*
