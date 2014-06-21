@rem ='
@echo off
setlocal
call set-nbu-build-env.bat
%NBU_BUILD_PERL%\bin\perl.exe -S %0 %*
exit /b %errorlevel%
@rem ';
#line 9

use strict;

use Scaffolds;

my $root = $ENV{NBU_BUILD_ROOT};
my $user = $ENV{NBU_USERNAME};

systema("net start albd");
systema("net start lockmgr");
systema("net start cccredmgr");

my @views;
my $views_file = "$root/usr/$user/cfg/clearcase/views";
open H, "<$views_file" or die "cannot open views file";
while (<H>)
{
	wchomp();
	next if (! $_) || ($_ =~ "#.*");
	system "cleartool startview $_";
}

sub wchomp
{
	chomp;
	chop if (substr($_, -1, 1) eq "\r");
	return $_;
}
