@echo off

setlocal
call set-nbu-build-env.bat

set SVN_PATH=%NBU_BUILD_ROOT%\dev\cm\svn\1.7.8
set APR_ICONV_PATH=%SVN_PATH%\iconv

%SVN_PATH%\bin\svn.exe %*
