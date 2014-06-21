@echo off

setlocal
if "%@eval[2 + 2]%" == "4" on break cancel

call set-nbu-build-env.bat
: ruby %RUBY_SCRIPTS_DIR%\Confetti\bin\tt.rb %*
ruby R:\Build\tmp\classico\Confetti\Confetti\bin\tt.rb %*
