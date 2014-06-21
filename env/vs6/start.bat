@echo off

set MSVCDir=%NBU_BUILD_ROOT%\dev\tools\msc\12.0.8804

set PATH=%MSVCDir%\bin;%PATH%
set INCLUDE=%MSVCDir%\atl\include;%MSVCDir%\include;%MSVCDir%\mfc\include;%INCLUDE%
set LIB=%MSVCDir%\lib;%MSVCDir%\mfc\lib;%LIB%
