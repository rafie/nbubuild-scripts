
set RUBY_VER=1.9.2
set RUBY_FULLVER=1.9.2-p180

if "%RV_RUBY_LOCAL%" == "1" goto local

set RUBY_DIR=%NBU_BUILD_ROOT%\dev\lang\ruby\%RUBY_FULLVER%
: %RUBY_DIR%\lib\site_ruby\%RUBY_VER%

set GEM_HOME=%NBU_BUILD_ROOT%\sys\libs\ruby\gems\%RUBY_VER%

set RUBY_SCRIPTS_DIR=%NBU_BUILD_ROOT%\sys\scripts\ruby
goto common

:local
set RUBY_DIR=c:\rvdev\ruby\%RUBY_FULLVER%
set GEM_HOME=c:\rvdev\ruby\gems\%RUBY_VER%
set RUBY_SCRIPTS_DIR=c:\rvdev\scripts\ruby

:common
set PATH=%RUBY_DIR%\bin;%GEM_HOME%\bin;%PATH%
set RUBYLIB=%RUBY_DIR%\lib\ruby;%RUBY_SCRIPTS_DIR%;%RUBYLIB%

:end
