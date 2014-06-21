@rem ='
@echo off
setlocal
call set-nbu-build-env.bat
%NBU_BUILD_PERL%\bin\perl.exe -S %0 %*
exit /b %errorlevel%
@rem ';
#line 9

system("start M:\\rafie_home\\users\\rafie\\prj\\putty-dev\\windows\\MSVC\\pageant\\Debug\\pageant.exe r:\\build\\usr\\linora\\cfg\\pageant\\putty.ppk");

__END__

=cut
