@echo off

setlocal

set d=%NBU_BUILD_ROOT%\usr\%USERNAME%\cfg\pageant
if not exist %d% mkdir %d%
echo r:\Mcu_Ngp\Utilities\Putty\plink -l %USERNAME% cobalt /tmp/pgen > %d%\putty.ppk
goto quit

:usage
echo Usage: install-pageant-key

:quit
