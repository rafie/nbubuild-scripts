@echo off

set _gcc_root=%NBU_BUILD_ROOT%\dev\tools\code-sourcery\ia32-2012.09-62
set _gcc_arch=i686-pc-linux-gnu
set _gcc_ver=4.7.2
set _gcc_sysroot=centos-6.4

set path=%_gcc_root%\libexec\gcc\%_gcc_arch%\%_gcc_ver%;%path%
set path=%_gcc_root%\%_gcc_arch%\bin;%path%
set path=%_gcc_root%\bin;%path%

set sysroot=%NBU_BUILD_ROOT%/dev/libs/%_gcc_sysroot%
set _gcc_toolpref=%_gcc_root%\%_gcc_arch%\bin
set gcc=%_gcc_toolpref%\gcc.exe --sysroot=%sysroot% -I%_gcc_root%\lib\gcc\%_gcc_arch%\%_gcc_ver%\include
set g++=%_gcc_toolpref%\g++.exe --sysroot=%sysroot% -I%_gcc_root%\lib\gcc\%_gcc_arch%\%_gcc_ver%\include -I%_gcc_root%/%_gcc_arch%/include/c++/%_gcc_ver%
set gxx=%_gcc_toolpref%\g++.exe --sysroot=%sysroot% -I%_gcc_root%\lib\gcc\%_gcc_arch%\%_gcc_ver%\include -I%_gcc_root%/%_gcc_arch%/include/c++/%_gcc_ver%

echo Please use %%gcc%% and %%g++%% (%%gxx%%) instead of gcc and g++, correspondingly.
