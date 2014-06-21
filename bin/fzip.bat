@echo off

setlocal

set zip=%1
set files=%2

type %files% | %NBU_BUILD_ROOT%\sys\arc\info-zip\zip.exe -@ %1
