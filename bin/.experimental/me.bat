
if "%NBU_USERNAME%" == "" set NBU_USERNAME=%USERNAME%

if "%1" == "" goto tell
if "%1" == "-" goto reset

set NBU_USERNAME=%1
exit /b

:tell
echo %NBU_USERNAME%
exit /b

:reset
set NBU_USERNAME=%USERNAME%
exit /b
