
set _4NT_path=R:\Mcu_Ngp\Utilities\4NT\8.0
set _4NT_cfg_path=%UserConfigRoot_path%\4nt\8.0
set _4NT_default_cfg_path=%UserConfigRoot_path%\4NT\8.0\config\default
set _4NT_command=%_4NT_path%\4nt.exe

if exist %TotalCommander_cfg_path% goto cfg_good

mkdir %_4NT_cfg_path%
copy %_4NT_default_cfg_path%\4nt.ini %_4NT_cfg_path% > nul

:cfg_good
call %TotalCommander_path%\totalcmd.bat %TotalCommander_cfg_path%
