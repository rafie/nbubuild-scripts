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
use Pod::Usage;
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
	my $killed = kill_proc("stop-auto-updates-d");
	print $killed ? "Stopped.\n" : "Not running.\n";
	exit($killed ? 0 : 1);
}

exit(0);

sub stop_system_agents
{
	my $ver = new Scaffolds::System("ver");
	my $winxp = $ver->out(1) =~ /Version 5/;
	
	my $service = $winxp ? "Automatic Updates" : "Windows Update";
	my $stop = new Scaffolds::System("net stop \"$service\"");
	print "$service: " . (! $stop->retcode ? "stopped.\n" : "not running.\n");

	my $killed = kill_proc("SMSCliUI");
	print "SMSCliUI: " . ($killed ? "stopped.\n" : "not running.\n");
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

sub kill_proc
{
	my ($pname) = @_;

	my $ps = systema("$pslist $pname", {log=>0});
	return if $ps->failed;
	my $line = $ps->out(3);
	$line =~ /^([^\s]+)\s*(\d+)/;
	my $pid = $2;
	return if ! $pid;
	my $kill = systema("$pskill $pid");
	return $kill->ok;
}

__END__

=head1 NAME

stop-auto-updates : suspend Windows automatic updates facilities

=head1 SYNOPSIS

stop-auto-updates [options]

=head1 OPTIONS

=over 12

=item B<--start>

Starts a daemon that periodically suspends updates.

=item B<--stop>

Stops the daemon that periodically suspends updates.

=item B<--now>

Stop automatic updates services and exit (do not start daemon).

=cut

:end
