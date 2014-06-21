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
use Scaffolds::Util;

my $root = $ENV{NBU_BUILD_ROOT};
my @vobs = read_list("$root/cfg/clearcase/vobs/dsp");
my $view_root = systema("cleartool pwv -root");
die "error: cannot determine view\n" if $view_root->failed;
my $view = $view_root->out0;
my @m1 = map { "$view\\$_" } @vobs;
my $dirs = join(";", @m1);
my @files = read_list("$root/cfg/clearcase/vobs/files");
my $files_mask = join(";", @files);

system("start R:/Mcu_Ngp/Utilities/PowerGREP/latest/PowerGREP.exe /folderrecurse \"$dirs\" /searchtext \"jojo\" /regex /masks \"$files_mask\" \"lost+found/*\" 0");
