@echo off

setlocal
call set-nbu-build-env.bat
ruby %RUBY_SCRIPTS_DIR%\Confetti\bin\tt.rb %*
