
set TotalCommander_path=R:\Mcu_Ngp\Utilities\TotalCommander\7.
set TotalCommander_cfg_path=%UserConfigRoot_path%\total-commander\7.02
set TotalCommander_default_cfg_path=%TotalCommander_path%\config\default

if exist %TotalCommander_cfg_path% goto cfg_good

mkdir %TotalCommander_cfg_path%
copy %TotalCommander_default_cfg_path%\wincmd.ini  %TotalCommander_cfg_path% > nul
copy %TotalCommander_default_cfg_path%\default.br2 %TotalCommander_cfg_path% > nul
copy %TotalCommander_default_cfg_path%\wcx_ftp.ini %TotalCommander_cfg_path% > nul
copy %TotalCommander_default_cfg_path%\default.bar %TotalCommander_cfg_path% > nul

:cfg_good
call %TotalCommander_path%\totalcmd.bat %TotalCommander_cfg_path%
