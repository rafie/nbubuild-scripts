@echo off

set INTEL_PARALLEL_STUDIO_DIR=D:\dev\tools\intel\Parallel Studio
set ICPP_COMPILER11=%INTEL_PARALLEL_STUDIO_DIR%\Composer\
set INTEL_PARALLEL_STUDIO_PATH=%ICPP_COMPILER11%tbb\ia32\vc9\bin;%ICPP_COMPILER11%tbb\ia32\vc8\bin;%ICPP_COMPILER11%ipp\ia32\bin;%ICPP_COMPILER11%lib\ia32

set path=%INTEL_PARALLEL_STUDIO_PATH%;%path%
