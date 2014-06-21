@rem ='
@echo off
setlocal
call set-nbu-build-env.bat
%NBU_BUILD_PERL%\bin\perl.exe -S %0 %*
exit /b %errorlevel%
@rem ';
#line 9

use strict;

use Cwd;
use Win32::Process;
use Getopt::Long;
use English;

use Scaffolds;

my $start_service;
my $stop_service;
my $run_service;
my $now;
my $help;

my $root = $ENV{NBU_BUILD_ROOT};
my $pskill = "$root/sys/util/ps-tools/latest/pskill.exe -accepteula";
my $pslist = "$root/sys/util/ps-tools/latest/pslist.exe -accepteula";

my $opt = GetOptions (
	'help|?|h' => \$help,
	'start' => \$start_service,
	'stop' => \$stop_service,
	'service' => \$run_service,
	'now' => \$now
	) or pod2usage(-exitstatus => 1, -verbose => 99, -sections => "SYNOPSIS|OPTIONS");
pod2usage(-exitstatus => 0, -verbose => 2) if $help;

$start_service = 1 if ! ($now || $stop_service || $run_service);

if ($now)
{
	stop_system_agents();
	exit(0);
}

if ($start_service)
{
	my $ps = systema("$pslist stop-auto-updates-d", {log=>0});
	die "Already running.\n" if $ps->ok;

	print "Automatic updates are now suspended.\n";	
	detach("$root/sys/scripts/bin/stop-auto-updates-d.exe", "stop-auto-updates-d.exe --service");
	exit(0);
}

if ($run_service)
{
	while (1)
	{
		systema("stop-auto-updates --now");
		sleep(15 * 60); # every 15 mins
	}
}

if ($stop_service)
{
	my $kill = systema("$pskill -t stop-auto-updates-d");
	print $kill->ok ? "Stopped.\n" : "Not running.\n";
	exit($kill->ok ? 0 : 1);
}

exit(0);

sub stop_system_agents
{
	my $ver = new Scaffolds::System("ver");
	my $winxp = $ver->out(1) =~ /Version 5/;
	
	my $service = $winxp ? "Automatic Updates" : "Windows Update";
	my $stop = new Scaffolds::System("net stop \"$service\"");
	print "$service: " . (! $stop->retcode ? "stopped.\n" : "not running.\n");
	
	my $kill = systema("$pskill -t SMSCliUI.exe");
	print "SMSCliUI: " . ($kill->ok ? "stopped.\n" : "not running.\n");
}

sub detach
{
	my ($exe, $command) = @_;

	my $process;
	my @proc_params = (
		\$process,
		$exe,
		$command,
		0,
		DETACHED_PROCESS,
		cwd);

    Win32::Process::Create(@proc_params) or die Win32::FormatMessage(Win32::GetLastError());
}
