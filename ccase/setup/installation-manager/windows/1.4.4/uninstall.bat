@rem ='
@echo off
setlocal
call set-nbu-build-env.bat
%NBU_BUILD_PERL%\bin\perl.exe -S %0 %*
exit /b %errorlevel%
@rem ';
#line 9

use strict;

use Scaffolds::System;

print "\nUninstalling IBM Installation Manager...\n";

# my $uninstaller_dir = "C:\\Documents and Settings\\All Users\\Application Data\\IBM\\Installation Manager\\uninstall";
my $uninstaller_dir = "C:\\ProgramData\\IBM\\Installation Manager\\uninstall";

my $uninstaller = "\"$uninstaller_dir\\uninstallc.exe\" --launcher.ini \"$uninstaller_dir\\silent-uninstall.ini\"";

my $progs = $ENV{"ProgramFiles(x86)"};
if (! $progs || ! -d $progs)
{
	$progs = $ENV{ProgramFiles};
	die "Error: cannot determine Program Files directory.\n" if ! $progs || ! -d $progs;
}

systema("$uninstaller") if -f "$progs/IBM/Installation Manager/eclipse/IBMIMc.exe";;
exit(0);
