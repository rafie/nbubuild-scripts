@rem ='
@echo off
setlocal
call set-nbu-build-env.bat
%NBU_BUILD_PERL%\bin\perl.exe -S %0 %*
exit /b %errorlevel%
@rem ';
#line 9

use strict;

use Win32::TieRegistry;

use Scaffolds::System;

my $ccase;
$ccase = $Registry->{q"HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Atria\ClearCase\CurrentVersion"} or die "Cannot find ClearCase configuration\n";
my $home = $ccase->{ProductHome};
die "Cannot find ClearCase directory\n" if ! -d $home;

my $user = shift;
$user = $ENV{USERNAME} if ! $user;
my $host = shift;
$host = $ENV{COMPUTERNAME} if ! $host;

systemx("\"$home\\etc\\utils\\creds.exe\" -c " . $user);
systemx("\"$home\\etc\\utils\\credmap.exe\" -u " . $user . " " . $host);

exit(0);
