@echo off

setlocal
set view=%1
if "%view" == "" exit /b
"c:\Program Files\IBM\RationalSDLC\ClearCase\etc\utils\fix_prot.exe" -force -root -r -chown RADVISION\%USERNAME% -chgrp RADVISION\rvil_ccusers C:\Views\%view%.vws
