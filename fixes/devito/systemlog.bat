@rem ='
@echo off
setlocal
call set-nbu-build-env.bat
%NBU_BUILD_PERL%\bin\perl.exe -S %0 %*
exit /b %errorlevel%
@rem ';
#line 9

use strict;

use File::Path;
use File::Copy;
use Scaffolds;

my $logname = "system.log";
my $log = "c:/$logname";
my $logs_dir = "c:/root/dat/logs";
my $real_log = "$logs_dir/$logname";

if (is_link($log))
{
	my $bad = 0;
	open F, "<$log" or $bad = 1; 
	exit if !$bad;
	unlink $log;
}

mkpath($logs_dir) if ! -d $logs_dir;

if (! -f $log)
{
	if (! -f $real_log)
	{
		open F, ">$real_log";
		close F;
	}
}
else
{
	if (! -f $real_log)
	{
		move($log, $real_log);
	}
	else
	{
		append_file_to_file($real_log, $log);
		unlink($log);
	}
}

system("mklink " . u2w($log) . " " . u2w($real_log));
exit(0);
