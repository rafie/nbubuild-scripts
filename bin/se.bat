@echo off

%NBU_BUILD_PERL%\bin\perl -I%NBU_BUILD_ROOT%\sys\scripts\perl -I%NBU_BUILD_ROOT%\sys\libs\perl\ext -I%NBU_BUILD_ROOT%\sys\libs\perl\site\lib %NBU_BUILD_ROOT%\sys\scripts\bin\setenv.pl %*
