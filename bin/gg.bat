@rem ='
@echo off
setlocal
call set-nbu-build-env.bat
%NBU_BUILD_PERL%\bin\perl.exe -S %0 %*
exit /b %errorlevel%
@rem ';
#line 9
#!/bin/perl

use strict;
use Scaffolds::System;

my $args = join('+', @ARGV);
my $web = new Scaffolds::System("cmd /c \"start http://google.com/webhp#q=$args");
