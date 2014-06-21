@echo off

echo %date% %time% %~f0 >> ${local}\log
call ${local}\policy-mod.bat
