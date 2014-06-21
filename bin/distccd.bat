@rem ='
@echo off
setlocal
call set-nbu-build-env.bat
%NBU_BUILD_PERL%\bin\perl.exe -S %0 %*
exit /b %errorlevel%
@rem ';
#line 9

use strict;
use Getopt::Long;
use Pod::Usage;

use Scaffolds::System;
use Scaffolds::Util;

our $root = $ENV{NBU_BUILD_ROOT};
our $pstools = "$root/sys/util/ps-tools/2.4";
our $psservice = "$pstools/psservice.exe";
our $psshutdown = "$pstools/psshutdown.exe";

our $service_name = "distccd";
our $user = "RADVISION\\nbubuild";
our $passwd = "Mason1";

our $help = 0;
our $verbose;

our $host;
our $status;
our $start;
our $stop;
our $restart;
our $reboot;
our $fix;

our @hosts;

my $opt = GetOptions (
	'help|?|h' => \$help,
	'host=s' => \$host,
	'status' => \$status,
	'start' => \$start,
	'stop' => \$stop,
	'restart' => \$restart,
	'reboot' => \$reboot,
	'fix' => \$fix,
	'verbose' => \$verbose
	) or pod2usage(-exitstatus => 1, -verbose => 99, -sections => "SYNOPSIS|OPTIONS");
pod2usage(-exitstatus => 0, -verbose => 2) if $help;

if ($host)
{
	push @hosts, $host;
}
else
{
	@hosts = read_list("$root/cfg/distcc/hosts");
	map { $_ =~ /([^\/]+)\/\d+/; $_ = $1; } @hosts;
}

print "hosts: @hosts\n" if $verbose;

my %host_status = ();
my $good_command = 0;

for my $host (@hosts)
{
	if ($status)
	{
		my $state = service_state($host);
		$state = "*ERROR*" if ! $state;
		print "$host: $state\n";
	}
	elsif ($start || $stop || $restart)
	{
		my $cmd;
		$cmd = "start" if $start;
		$cmd = "stop" if $stop;
		$cmd = "restart" if $restart;
		
		my $state = service_state($host);
		if (! $state)
		{
			print "$host: *ERROR*\n";
			next;
		}
		if ($start && $state eq "RUNNING")
		{
			print "$host: already running\n";
			next
		}
		if ($stop && $state eq "STOPPED")
		{
			print "$host: not running\n";
			next;
		}

		my $psserv = systema("$psservice -u $user -p $passwd \\\\$host $cmd $service_name");
		$host_status{$host} = $psserv->retcode;
		++$good_command if ! $psserv->retcode;
	}
	elsif ($reboot)
	{
	}
}

exit 1 if ! $good_command;

exit $good_command == $#hosts ? 0 : 1 if $status;

my $delay = 0;
$delay = 2 if $start;
$delay = 5 if $stop;
$delay = 7 if $restart;
$delay = 60 if $reboot;
sleep($delay);

for my $host (@hosts)
{
	my $state = service_state($host);
	if (! $state)
	{
		print "$host: *ERROR*\n";
		next;
	}
	
	if ($start || $restart || $reboot)
	{
		if ($state eq "RUNNING")
		{
			print "$host: running\n";
		}
		else
		{
		}
		next;
	}
	
	if ($stop)
	{
		if ($state eq "STOPPED")
		{
			print "$host: stopped\n";
		}
		else
		{
		}
		next;
	}
}

exit $good_command == $#hosts ? 0 : 1;

sub service_state
{
	my ($host) = @_;
	
	my $sc = systema("sc \\\\$host query $service_name");
	return "" if $sc->retcode;

	my $state;
	foreach ($sc->out)
	{
		next if ! /STATE/;
		my @x = split(' ', $_);
		return $x[3];
	}
	return "";
}

__END__

=head1 NAME

distccd - Distcc daemon (distccd) control script

=head1 SYNOPSIS

distccd [--host HOST] [--start|--stop|--restart|--reboot]

=head1 OPTIONS

=over 12

=item B<--host HOST>

Operate on HOST. If not specified, read host list from R:\Build\cfg\distcc\hosts.

=item B<--status>

Query distccd service status.

=item B<--start>

Start distccd service.

=item B<--stop>

Stop distccd service.

=item B<--restart>

Restart distccd service.

=item B<--reboot>

Boot distccd host.

=cut
