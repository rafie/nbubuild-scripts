@echo off

set _rvlinuxppc_arch=
set _rvlinuxppc_sysroot=

set _rvlinuxppc_arch=i586-wrs-linux-gnu

set path=%NBU_BUILD_ROOT%\dev\tools\gcc\4.1-wrlinux-2.0\x86-win32\libexec\gcc\%_rvlinuxppc_arch%\4.1.2;%path%
set path=%NBU_BUILD_ROOT%\dev\tools\gcc\4.1-wrlinux-2.0\x86-win32\%_rvlinuxppc_arch%\bin;%path%
set path=%NBU_BUILD_ROOT%\dev\tools\gcc\4.1-wrlinux-2.0\x86-win32\bin;%path%

set sysroot=%NBU_BUILD_ROOT%/dev/libs/wrlinux-2.0/bspLinux5848_100516_MAIO_0.2.7-openssl-fips/sysroot
set _toolpref=%NBU_BUILD_ROOT%\dev\tools\gcc\4.1-wrlinux-2.0\x86-win32\bin\powerpc-wrs-linux-gnu
set gcc=%_toolpref%-gcc.exe --sysroot=%sysroot% -te500v2
set g++=%_toolpref%-g++.exe --sysroot=%sysroot% -te500v2
set gxx=%_toolpref%-g++.exe --sysroot=%sysroot% -te500v2
set _toolpref=
:x1

echo Please use %%gcc%% and %%g++%% (%%gxx%%) instead of gcc and g++, correspondingly.
