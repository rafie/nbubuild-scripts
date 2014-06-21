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

# my $web = new Scaffolds::System("start http://nbuwiki/wiki/index.php?title=Special%3ASearch&search=nbu image&go=Go");
my $args = join('%20', @ARGV);
my $web = new Scaffolds::System("cmd /c \"start http://nbuwiki/wiki/index.php?title=Special^%3ASearch^&search=$args^&go=Go\"");

exit(0);