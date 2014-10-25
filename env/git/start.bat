@echo off

set GIT_DIR=%NBU_BUILD_ROOT%\dev\cm\git\head
set GIT_PATH=%GIT_DIR%\cmd;%GIT_DIR%\bin

set path=%GIT_PATH%;%path%
: call gitsh.bat
