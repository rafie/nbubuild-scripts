@echo off

setlocal
path %NBU_BUILD_ROOT%\sys\msys\1.0.17-1\bin;%path%
%NBU_BUILD_ROOT%\sys\msys\1.0.17-1\bin\rsync.exe %*
