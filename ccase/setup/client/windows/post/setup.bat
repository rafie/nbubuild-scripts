@rem ='
@echo off
setlocal
call set-nbu-build-env.bat
%NBU_BUILD_PERL%\bin\perl.exe -S %0 %*
exit /b %errorlevel%
@rem ';
#line 9

use strict;

use FindBin;
use File::Copy;
use Win32::TieRegistry;

use Scaffolds::System;
use Scaffolds::Util;

my $wmic = systema("wmic os get version | cat");
my $is_xp = $wmic->out(1) =~ /^5/;

my $home = u2w($FindBin::Bin);
chdir($home);

print "\nConfiguring ClearCase Client...\n";

# verify ClearCase services are running
systema("net start albd");
systema("net start lockmgr");
systema("net start cccredmgr");

# ClearCase configuration

my $is_x64 = $ENV{"ProgramFiles(x86)"};
my $ccase_key = $is_x64 ? q"HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Atria\ClearCase\CurrentVersion" :
	q"HKEY_LOCAL_MACHINE\SOFTWARE\Atria\ClearCase\CurrentVersion";

my $ccase_cfg;
$ccase_cfg = $Registry->{$ccase_key} or die "Cannot find ClearCase configuration.\n";
my $ccase_dir = $ccase_cfg->{ProductHome};
die "Cannot find ClearCase directory\n" if ! -d $ccase_dir;

systemx("reg import mvfs-parameters.reg");
systemx("reg import client-config.reg");

my $ccase;
if (! $is_xp)
{
	mkdir("c:/root") if ! -d "c:/root";
	mkdir("c:/root/dev") if ! -d "c:/root/dev";
	$ccase = "c:/root/dev/clearcase";
	mklink($ccase, $ccase_dir);
	mklink("c:/root/dev/rational", "$ccase_dir\\..");
}
else
{
	$ccase = w2u($ccase_dir);
}

copy("default.magic", "$ccase/config/magic/default.magic") or die "Cannot copy default.magic file.\n";
copy("map", "$ccase/lib/mgrs/map") or die "Cannot copy map file.\n";

# this belongs in the user enviromnet (setx without -m)
systemx("setx CLEARCASE_PRIMARY_GROUP GLOBAL\\rvccgrp01") if $ENV{USERDOMAIN} eq "GLOBAL";

# Windows CIFS shares patch

systemx("cifs-shares.bat");

# mount VOBs

systemx("mount-nbu-vobs.bat");

# Create and remove a view to enable ClearCase view share

my $vname = $ENV{USERNAME} . "__view1";
systema("ct1 mkview -raw -name $vname")->ordie("Cannot create view.");
systema("ct endview -server $vname");
systema("ct rmview -tag $vname");

exit(0);

sub mklink
{
	my ($link, $target) = @_;
	
	my $link_w = u2w($link);
	system("rmdir $link_w") if -e $link;
	systemx("mklink /d $link_w \"$target\"");
}
