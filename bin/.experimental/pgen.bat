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
use Scaffolds::Command;
use Scaffolds::Util;

use Sys::Hostname;
use File::Basename;
use XML::Simple;

my $root = $ENV{NBU_BUILD_ROOT};

my $simple = new XML::Simple;
my $users = $simple->XMLin("$root/cfg/users/users.xml", KeyAttr => { user => "+username" });

foreach my $user (sort keys %{$users->{user}})
{
	print $users->{user}->{$user}->{username} . "\n";
}
exit 1;
my $hosts = $simple->XMLin("R:/Build/cfg/hosts/hosts.xml");

my $linuxhost = "cobalt";
my $linux_pgen = "/users/nbubuild/putty/pgen";
my $plink = "M:/rafie_home/users/rafie/prj/putty-dev/windows/MSVC/plink/Debug/plink.exe";

# my $user = $ENV{USERNAME};
my $user = "zvib";
my $cfg = "$root/usr/$user/cfg/pageant";
my $key = "$cfg/putty.ppk";

mkdir($cfg) if ! -d $cfg;

my $pgen_cmd = new Scaffolds::System("$plink -nobatch -l $user $linuxhost $linux_pgen", { log => 0 });
if ($pgen_cmd->retcode)
{
	die "plink failed.\n"
}

open KEY, ">$key";
print KEY $pgen_cmd->outText;
close KEY;

exit 0;
