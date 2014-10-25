@rem ='
@echo off
setlocal
call set-nbu-build-env.bat
%NBU_BUILD_PERL%\bin\perl.exe -S %0 %*
exit /b %errorlevel%
@rem ';
#line 9

use strict;

use Cwd qw(realpath);
use FindBin;
use Win32::TieRegistry;

use Scaffolds;

my $home = u2w($FindBin::Bin);
chdir($home);

print "\nFixing Visual Studio 2013 ClearCase configuration...\n";

my $ccase_key = is_x64() ? q"HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Atria\ClearCase\CurrentVersion" :
	q"HKEY_LOCAL_MACHINE\SOFTWARE\Atria\ClearCase\CurrentVersion";

my $ccase_cfg;
$ccase_cfg = $Registry->{$ccase_key} or die "Cannot find ClearCase configuration\n";
my $ccase_dir = $ccase_cfg->{ProductHome};
die "Cannot find ClearCase directory\n" if ! -d $ccase_dir;

my $ccvsi_dir = $ccase_dir . q"\CCVSI\bin";
my $ccvsisearchtoolwin_dll = "$ccvsi_dir\\ccvsisearchtoolwin.dll";

die "Cannot find ccvsisearchtoolwin.dll\n" if ! -f $ccvsisearchtoolwin_dll;

my @dlls = qw(ccvsiinterfaces.dll ccvsisearchdefs.dll Banner.dll HelpPage.dll HomePage.dll PageSelector.dll ToolsPage.dll ViewsPage.dll CTPackage.dll);
for (@dlls)
{
	systemx("regsvr32 /s $ccase_dir\\bin\\$_");
}

systemx("reg import ccvsi_vs2013.reg");

systemx("regsvr32 /s $ccvsi_dir\\ccvsilanservice.dll");

exit(0);
