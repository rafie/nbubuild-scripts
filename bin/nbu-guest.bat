@echo off

setlocal

set NBU_BUILD_ROOT=r:\build
set NBU_BUILD_PERL=%NBU_BUILD_ROOT%\dev\lang\active-perl\5.8.8

set PATH=%PATH%;%NBU_BUILD_ROOT%\sys\scripts\bin

title NBU development environment
call se nbu
