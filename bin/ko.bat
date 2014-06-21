@echo off

setlocal
call set-nbu-build-env.bat
%NBU_BUILD_ROOT%\dev\ide\komodo\7.0\ko.exe %*
