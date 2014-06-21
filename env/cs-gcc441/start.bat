@echo off

set _cs_gcc441_arch=i686-pc-linux-gnu
set _cs_gcc441_sysroot=%NBU_BUILD_ROOT%\dev\libs\code-sourcery\gcc-4.4.1-ia32\sysroot
set _cs_gcc441_tools_root=%NBU_BUILD_ROOT%\dev\tools\gcc\4.4.1-sourcery\x86-win32

set path=%_cs_gcc441_tools_root%\libexec\gcc\%gcc441_arch%\4.4.1;%path%
set path=%_cs_gcc441_tools_root%\%gcc441_arch%\bin;%path%
set path=%_cs_gcc441_tools_root%\bin;%path%

set gcc=%_cs_gcc441_tools_root%\bin\%_cs_gcc441_arch%-gcc.exe --sysroot=%_cs_gcc441_sysroot%
set g++=%_cs_gcc441_tools_root%\bin\%_cs_gcc441_arch%-g++.exe --sysroot=%_cs_gcc441_sysroot%
set gxx=%_cs_gcc441_tools_root%\bin\%_cs_gcc441_arch%-g++.exe --sysroot=%_cs_gcc441_sysroot%

echo Please use %%gcc%% and %%g++%% (%%gxx%%) instead of gcc and g++, correspondingly.
