@echo off

set _wrl2_arch=

if "%1"=="x86" set _wrl2_arch=i586-wrs-linux-gnu
if "%1"=="ppc" set _wrl2_arch=powerpc-wrs-linux-gnu
if "%_wrl2_arch%"=="" set _wrl2_arch=powerpc-wrs-linux-gnu

set path=%NBU_BUILD_ROOT%\dev\tools\gcc\4.1-wrlinux-2.0\x86-win32\libexec\gcc\%_wrl2_arch%\4.1.2;%path%
set path=%NBU_BUILD_ROOT%\dev\tools\gcc\4.1-wrlinux-2.0\x86-win32\%_wrl2_arch%\bin;%path%
set path=%NBU_BUILD_ROOT%\dev\tools\gcc\4.1-wrlinux-2.0\x86-win32\bin;%path%

if "%_wrl2_arch%"=="i586-wrs-linux-gnu" (
	set sysroot=%NBU_BUILD_ROOT%/dev/libs/wrlinux-2.0/common_pc-glibc_std/sysroot
	set gcc=%NBU_BUILD_ROOT%\dev\tools\gcc\4.1-wrlinux-2.0\x86-win32\bin\i586-wrs-linux-gnu-gcc.exe --sysroot=%sysroot%
	set g++=%NBU_BUILD_ROOT%\dev\tools\gcc\4.1-wrlinux-2.0\x86-win32\bin\i586-wrs-linux-gnu-g++.exe --sysroot=%sysroot%
	set gxx=%NBU_BUILD_ROOT%\dev\tools\gcc\4.1-wrlinux-2.0\x86-win32\bin\i586-wrs-linux-gnu-g++.exe --sysroot=%sysroot%
)

if "%_wrl2_arch%"=="powerpc-wrs-linux-gnu" (
	set sysroot=%NBU_BUILD_ROOT%/dev/libs/wrlinux-2.0/powerpc-wrs-linux-gnu-ppc_e500v2-glibc_small/sysroot
	set gcc=%NBU_BUILD_ROOT%\dev\tools\gcc\4.1-wrlinux-2.0\x86-win32\bin\powerpc-wrs-linux-gnu-gcc.exe --sysroot=%sysroot% -te500v2
	set g++=%NBU_BUILD_ROOT%\dev\tools\gcc\4.1-wrlinux-2.0\x86-win32\bin\powerpc-wrs-linux-gnu-g++.exe --sysroot=%sysroot% -te500v2
	set gxx=%NBU_BUILD_ROOT%\dev\tools\gcc\4.1-wrlinux-2.0\x86-win32\bin\powerpc-wrs-linux-gnu-g++.exe --sysroot=%sysroot% -te500v2
)

echo Please use %%gcc%% and %%g++%% (%%gxx%%) instead of gcc and g++, correspondingly.
