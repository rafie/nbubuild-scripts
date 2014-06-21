@echo off

set _wrl3_arch=
set _wrl3_sysroot=

if "%1"=="x86" (
	set _wrl3_arch=i586-wrs-linux-gnu
	set _wrl3_sysroot=common_pc-glibc_std
)
if "%1"=="x86_64" (
	set _wrl3_arch=i586-wrs-linux-gnu
	set _wrl3_sysroot=common_pc_64-glibc_std
)
if "%_wrl3_arch%"=="" (
	set _wrl3_arch=i586-wrs-linux-gnu
	set _wrl3_sysroot=common_pc-glibc_std
)

set path=%NBU_BUILD_ROOT%\dev\tools\gcc\4.3.2-wrlinux-3.0\x86-win32\libexec\gcc\%_wrl3_arch%\4.3.2;%path%
set path=%NBU_BUILD_ROOT%\dev\tools\gcc\4.3.2-wrlinux-3.0\x86-win32\%_wrl3_arch%\bin;%path%
set path=%NBU_BUILD_ROOT%\dev\tools\gcc\4.3.2-wrlinux-3.0\x86-win32\bin;%path%

if not "%_wrl3_arch%"=="i586-wrs-linux-gnu" goto x1
set sysroot=%NBU_BUILD_ROOT%/dev/libs/wrlinux-3.0/%_wrl3_sysroot%/sysroot
set _toolpref=%NBU_BUILD_ROOT%\dev\tools\gcc\4.3.2-wrlinux-3.0\x86-win32\bin\i586-wrs-linux-gnu
set gcc=%_toolpref%-gcc.exe --sysroot=%sysroot%
set g++=%_toolpref%-g++.exe --sysroot=%sysroot%
set gxx=%_toolpref%-g++.exe --sysroot=%sysroot%
set _toolpref=
:x1

echo Please use %%gcc%% and %%g++%% (%%gxx%%) instead of gcc and g++, correspondingly.
