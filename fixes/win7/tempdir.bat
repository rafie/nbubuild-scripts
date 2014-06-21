@echo off

exit /b

mkdir c:\tmp\%USERNAME%
mkdir c:\tmp\windows
setx TEMP c:\tmp\%%USERNAME%%
setx TMP  c:\tmp\%%USERNAME%%
setx TEMP c:\tmp\windows -m
setx TMP  c:\tmp\windows -m

setx TEMP %%USERPROFILE%%\AppData\Local\Temp
setx TMP  %%USERPROFILE%%\AppData\Local\Temp
setx TEMP %%SystemRoot%%\TEMP -m
setx TMP  %%SystemRoot%%\TEMP -m
