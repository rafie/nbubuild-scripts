@echo off

set WIND_HOME=%NBU_BUILD_ROOT%\dev\libs\vxworks\6.3
set WIND_BASE=%WIND_HOME%
: set WIND_USR=%WIND_BASE%\target\usr

set path=%NBU_BUILD_ROOT%\dev\tools\diab\5.4\win32\bin;%NBU_BUILD_ROOT%\dev\libs\vxworks\6.3\host\x86-win32\bin;%NBU_BUILD_ROOT%\dev\libs\vxworks\6.3\tools\x86-win32\bin;%NBU_BUILD_ROOT%\dev\libs\vxworks\6.3\foundation\4.0.9\x86-win32\bin;%path%

if not "%_4ver%" == "" alias dplus=dplus.exe -tPPCE500FS:vxworks63
