@echo off

set INTEL_IPP_PATH=%NBU_BUILD_ROOT%\dev\libs\intel-ipp\7.0.1.127\bin\windows-x86
set INTEL_ICC_PATH=%NBU_BUILD_ROOT%\dev\libs\intel-icc-redist\12.0.127\bin\windows-x86

set path=%INTEL_IPP_PATH%;%INTEL_ICC_PATH%;%path%
