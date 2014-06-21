@echo off

if "%1" == "" goto tell
if "%1" == "?" goto tell
if "%1" == "!" goto default

set NBU_BUILD_USER=%1
quit

:default
set NBU_BUILD_USER=%USERNAME%
quit

:tell
set NBU_BUILD_USER
