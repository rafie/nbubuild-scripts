@echo off

set _rvavatar_arch=
set _rvavatar_sysroot=

if "%1"=="x86" (
	set _rvavatar_arch=i586-wrs-linux-gnu
	set _rvavatar_sysroot=common_pc-glibc_std
)
if "%1"=="x86_64" (
	set _rvavatar_arch=i586-wrs-linux-gnu
	set _rvavatar_sysroot=common_pc_64-glibc_std
)
if "%_rvavatar_arch%"=="" (
	set _rvavatar_arch=i586-wrs-linux-gnu
	set _rvavatar_sysroot=common_pc-glibc_std
)

set path=%NBU_BUILD_ROOT%\dev\tools\gcc\4.3.2-wrlinux-3.0\x86-win32\libexec\gcc\%_rvavatar_arch%\4.3.2;%path%
set path=%NBU_BUILD_ROOT%\dev\tools\gcc\4.3.2-wrlinux-3.0\x86-win32\%_rvavatar_arch%\bin;%path%
set path=%NBU_BUILD_ROOT%\dev\tools\gcc\4.3.2-wrlinux-3.0\x86-win32\bin;%path%

if not "%_rvavatar_arch%"=="i586-wrs-linux-gnu" goto x1
set sysroot=%NBU_BUILD_ROOT%/dev/libs/sles-11-sdk/default/sysroot
set _toolpref=%NBU_BUILD_ROOT%\dev\tools\gcc\4.3.2-wrlinux-3.0\x86-win32\bin\i586-wrs-linux-gnu
set gcc=%_toolpref%-gcc.exe --sysroot=%sysroot%
set g++=%_toolpref%-g++.exe --sysroot=%sysroot%
set gxx=%_toolpref%-g++.exe --sysroot=%sysroot%
set _toolpref=
:x1

echo Please use %%gcc%% and %%g++%% (%%gxx%%) instead of gcc and g++, correspondingly.
