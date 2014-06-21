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
use File::Copy;
use File::Path qw(mkpath);
use FindBin;
use Win32::TieRegistry;

use Scaffolds;

my $primary_group = "GLOBAL\\rvccgrp01";

my $home = u2w($FindBin::Bin);
chdir($home);

print "\nFixing ClearCase configuration...\n";

my $ccase_key = is_x64() ? q"HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Atria\ClearCase\CurrentVersion" :
	q"HKEY_LOCAL_MACHINE\SOFTWARE\Atria\ClearCase\CurrentVersion";

my $ccase_cfg;
$ccase_cfg = $Registry->{$ccase_key} or die "Cannot find ClearCase configuration\n";
my $ccase_dir = $ccase_cfg->{ProductHome};
die "Cannot find ClearCase directory\n" if ! -d $ccase_dir;

systemx("reg import $home\\mvfs-parameters.reg");
systemx("reg import $home\\client-config.reg");
systemx("reg import $home\\visual-studio.reg");

my $ccase = "c:/root/dev/clearcase";
mkpath("c:/root/dev");
mk_dir_link($ccase, $ccase_dir);
mk_dir_link("c:/root/dev/rational", realpath("$ccase_dir/.."));

copy("default.magic", "$ccase/config/magic/default.magic") or die "Cannot copy default.magic file\n";
copy("map", "$ccase/lib/mgrs/map") or die "Cannot copy map file\n";

# this belongs in the user enviromnet (setx without -m)
systemx("setx CLEARCASE_PRIMARY_GROUP $primary_group") if $ENV{USERDOMAIN} eq "GLOBAL";

exit(0);

sub mk_dir_link
{
	my ($link, $target) = @_;
	
	my $link_w = u2w($link);
	if (is_xp())
	{
		system("jn -d $link_w") if -e $link;
		systemx("jn $link_w \"$target\"");
	}
	else
	{
		system("rmdir $link_w") if -e $link;
		systemx("mklink /d $link_w \"$target\"");
	}
}
