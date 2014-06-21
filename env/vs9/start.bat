@echo off

: set MSVCDir=%NBU_BUILD_ROOT%\dev\tools\msc\15.00.21022.08
set MSVCDir=%NBU_BUILD_ROOT%\dev\tools\msc\15.00.30729.01
set WindowsSDKDir=%NBU_BUILD_ROOT%\dev\libs\windows-sdk\6.0a

set PATH=%MSVCDir%\bin;%PATH%
set INCLUDE=%MSVCDir%\atlmfc\include;%MSVCDir%\include;%WindowsSDKDir%\include;%INCLUDE%
set LIB=%MSVCDir%\atlmfc\lib;%MSVCDir%\lib;%WindowsSDKDir%\lib;%LIB%
