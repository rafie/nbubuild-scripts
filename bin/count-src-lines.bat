@echo off

setlocal
call set-nbu-build-env.bat
ruby %NBU_BUILD_ROOT%\sys\scripts\bin\count-src-lines.rb %*
