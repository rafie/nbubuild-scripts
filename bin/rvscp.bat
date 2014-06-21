@echo off

: RV_LINUX_TARGET
: RV_LINUX_TARGET_PWD

setlocal
if "%RV_LINUX_TARGET%" == "" goto err
if "%RV_LINUX_TARGET_PWD%" == "" set RV_LINUX_TARGET_PWD=linux

r:\Mcu_Ngp\Utilities\Putty\pscp-batch -l root -pw %RV_LINUX_TARGET_PWD% %1 %RV_LINUX_TARGET%:%2
goto :exit

:nohost
r:\Mcu_Ngp\Utilities\Putty\pscp-batch -l root -pw %RV_LINUX_TARGET_PWD% %1 %2
goto exit

:err
echo RV_LINUX_TARGET is not set
goto exit

:exit
