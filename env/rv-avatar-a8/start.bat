@echo off

set _gcc_root=%NBU_BUILD_ROOT%\dev\tools\code-sourcery\arm-2009q1-203
set _gcc_arch=arm-none-linux-gnueabi
set _gcc_ver=4.3.3
set _gcc_sysroot=xt5000/armv7a-tools-110614

set path=%_gcc_root%\libexec\gcc\%_gcc_arch%\%_gcc_ver%;%path%
set path=%_gcc_root%\%_gcc_arch%\bin;%path%
set path=%_gcc_root%\bin;%path%

set sysroot=%NBU_BUILD_ROOT%/dev/libs/%_gcc_sysroot%
set _gcc_toolpref=%_gcc_root%\%_gcc_arch%\bin
set gcc=%_gcc_toolpref%\gcc.exe --sysroot=%sysroot%
set g++=%_gcc_toolpref%\g++.exe --sysroot=%sysroot%
set gxx=%_gcc_toolpref%\g++.exe --sysroot=%sysroot%

echo Please use %%gcc%% and %%g++%% (%%gxx%%) instead of gcc and g++, correspondingly.
