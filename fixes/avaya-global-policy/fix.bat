@rem ='
@echo off
setlocal
call set-nbu-build-env.bat
%NBU_BUILD_PERL%\bin\perl.exe -S %0 %*
exit /b %errorlevel%
@rem ';
#line 9

use strict;
use File::Basename;
use FindBin;
use Win32::Registry;

use Scaffolds::System;
use Scaffolds::Util;

print "\nInstalling system event scripts...\n";

my $home = $FindBin::Bin;
chdir($home);

my $scripts_dir = "c:/root/cfg/policy";
my $scripts_dir_w = u2w($scripts_dir);

my $windir_w = $ENV{SystemRoot};
my $is_x64 = $ENV{"ProgramFiles(x86)"} ? 1 : 0;

my $group_pol_dir_w;
my $sys32 = $is_x64 ? "Sysnative" : "System32";
$group_pol_dir_w = u2w("$windir_w/$sys32/GroupPolicy");

systemx("coin --no-view --strict " .
	"-d windir=$windir_w -d local=$scripts_dir_w -d GroupPolicy=$group_pol_dir_w " .
 	"--from $home/template --to $scripts_dir");

systemx("schtasks /create /tn \"Policy customization\" /f /xml $scripts_dir_w\\policy-mod-task.xml");
systemx("schtasks /run /tn \"Policy customization\"");

systemx("setx DEVITO_SYSEVENTS 1 -m");

print "Sysevents installed. Please enable local policy scripts.\n";

exit(0);
