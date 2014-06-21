@echo off

reg import cifs-shares.reg
: the following is required because a .reg script can't set this value
reg add HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\services\LanmanServer\Parameters /f /v Size /t reg_dword /d 3
