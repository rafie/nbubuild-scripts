@echo off

set MSVCDir=%NBU_BUILD_ROOT%\dev\tools\msc\14.00.50727.762
set PlatformSDKDir=%NBU_BUILD_ROOT%\Build\dev\libs\platform-sdk\2005-04

set PATH=%MSVCDir%\bin;%PATH%
set INCLUDE=%MSVCDir%\atlmfc\include;%MSVCDir%\include;%PlatformSDKDir%\include;%INCLUDE%
set LIB=%MSVCDir%\atlmfc\lib;%MSVCDir%\lib;%PlatformSDKDir%\lib;%LIB%
