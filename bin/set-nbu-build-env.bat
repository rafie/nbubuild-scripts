@echo off

if "%NBU_USERNAME%" == "" set NBU_USERNAME=%USERNAME%

if "%NBU_BUILD_ENV%" == "1" goto quit
set NBU_BUILD_ENV=1

if "%NBU_BUILD_ROOT%" == "" set NBU_BUILD_ROOT=r:\build

set scripts=%NBU_BUILD_ROOT%\sys\scripts\bin

call %scripts%\system\perlenv.bat
: if "%NBU_BUILD_NO_RUBY%" == "" 
call %scripts%\system\rubyenv.bat
call %scripts%\system\msys.bat
call %scripts%\system\openssl.bat

set nbu_build_path=%NBU_BUILD_ROOT%\sys\scripts\bin;%NBU_BUILD_ROOT%\sys\util\bin

ver | findstr /L "6.1." > nul
if %ERRORLEVEL% neq 0 set nbu_build_path=%nbu_build_path%;%NBU_BUILD_ROOT%\sys\util\winxp

: if "%no_cygwin_bash%" == "" set nbu_build_path=%nbu_build_path%;%NBU_BUILD_ROOT%\sys\util\bin\cygwin-bash
set nbu_build_path=%nbu_build_path%;%NBU_BUILD_ROOT%\sys\msys\1.0\bin;%NBU_BUILD_PERL%\bin;%OPENSSL_BIN_PATH%
set X1=%nbu_build_path%

set path=%nbu_build_path%;%path%

: echo NBU_USERNAME=%NBU_USERNAME%
set UserConfigRoot_path=%NBU_BUILD_ROOT%\usr\%NBU_USERNAME%\cfg
if not exist %UserConfigRoot_path% md %UserConfigRoot_path%

:quit
