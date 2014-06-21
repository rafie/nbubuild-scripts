
package Scaffolds::System;

use strict;
use Cwd;
use File::Temp qw(tmpnam);
use POSIX qw(strftime);
use Time::HiRes qw(usleep tv_interval gettimeofday);

use Scaffolds::Util qw(wchomp);

require Exporter;
use vars qw(@ISA @EXPORT);

@ISA = qw(Exporter);
@EXPORT = qw(systema systemi systemx systemxi log_hello);

#----------------------------------------------------------------------------------------------

# named arguments:
#  log    = [1|0] : enable/disable logging (both out and err streams)
#  outlog = [1|0] : enable/disable logging of out stream
#  errlog = [1|0] : enable/disable logging of err stream
#  tee =    [0|1] : disable/enable tee on output (out and err combined)
#  pre =    [0|1] : disable/enable pre-report

sub new
{
	my $invocant = shift;
	my $class = ref($invocant) || $invocant;

	my ($prog, $harg) = @_;

	my $no_log = $harg->{log} eq 0;
	my $no_outlog = $no_log ? 1 : $harg->{outlog} eq 0;
	my $no_errlog = $no_log ? 1 : $harg->{errlog} eq 0;
	my $no_tee = $harg->{tee} ne 1;
	my $pre = $harg->{pre} eq 1 || ! $no_tee;

	my $when = strftime("%y-%m-%d %H:%M:%S", localtime);
	my $where = getcwd;

	my $fout = tmpnam();
	my $ferr = tmpnam();
	my $t0 = [gettimeofday];

	my $system_log = $ENV{NBU_BUILD_LOG};
	$system_log = "c:/system.log" if !$system_log;

	if ($pre)
	{
		$no_log = 1;

		while (1)
		{
			open LOG, ">>$system_log" and last;
			Time::HiRes::sleep(1 + rand);
		}
	
		print LOG "=== $when (*) [$where]\n$prog\n";
		close LOG;
	}

	my $rc;
	if ($no_tee)
	{
		system("$prog 1> $fout 2> $ferr");
	}
	else
	{
#		system("$prog 2>&1 | wtee $fout");
		system($prog);
	}
	$rc = $? == -1 ? -1 : ($? >> 8);

	my $t1 = [gettimeofday];
	my $elapsed_sec = tv_interval($t0, $t1);

	if (! $no_log)
	{
		while (1)
		{
			open LOG, ">>$system_log" and last;
			Time::HiRes::sleep(1 + rand);
		}

		print LOG "=== $when (${elapsed_sec}s) [$where]\n$prog\n--- ($rc)\n";

		_append(\*LOG, $fout) if ! $no_outlog;
		print LOG "---\n";
		
		_append(\*LOG, $ferr) if ! $no_errlog;
		
		close LOG;
	}
	
	open OUT, "<$fout";
	my @out;
	while (<OUT>)
	{
		wchomp;
		push @out, $_;
	}
	close OUT;
	unlink $fout;
	
	open ERR, "<$ferr";
	my @err;
	while (<ERR>)
	{
		wchomp;
		push @err, $_;
	}
	close ERR;
	unlink $ferr;
	
	my $self = { cmd => $prog, rc => $rc, out => [ @out ], err => [ @err ] };
	
	bless($self, $class);
	return $self;
}

sub retcode
{
	my ($self) = @_;
	return $self->{rc};
}

sub ok
{
	my ($self) = @_;
	return ! $self->{rc};
}

sub failed
{
	my ($self) = @_;
	return !! $self->{rc};
}

sub out
{
	my ($self, $line) = @_;
	return @{$self->{out}} if ! defined $line;
	return @{$self->{out}}[$line];
}

sub out0
{
	my ($self) = @_;
	return @{$self->{out}}[0];
}

sub outText
{
	my ($self) = @_;
	return join("\n", @{$self->{out}}) . "\n";
}

sub err
{
	my ($self, $line) = @_;
	return @{$self->{err}} if ! defined $line;
	return @{$self->{err}}[$line];
}

sub err0
{
	my ($self) = @_;
	return @{$self->{err}}[0];
}

sub errText
{
	my ($self) = @_;
	return join("\n", @{$self->{err}}) . "\n";
}

sub ordie
{
	my ($self, $msg) = @_;
	$msg = "Failed: " . $self->{cmd} if ! $msg;
	die "$msg\n" if $self->{rc};
	return $self;
}

sub _append
{
	my ($to, $from) = @_;
	
	open F, "<$from" or return;
	while (<F>)
	{
		print $to $_;
	}
	close F;
}

sub system_tee
{
	my ($prog, $log) = @_;
	open PROG, "$prog 2>&1 |" or return -1;
	open LOG, ">$log" or return -1;
	while (<PROG>)
	{
		print $_;
		print LOG $_;
	}
	close PROG; # to get $?
	my $rc = $? >> 8;
	close LOG;
	return $rc;
}

#----------------------------------------------------------------------------------------------

sub systema
{
	return new Scaffolds::System(@_);
}

sub systemx
{
	return new Scaffolds::System(@_)->ordie;
}

sub systemi
{
	my @a = @_;
	if ($#a eq 0)
	{
		push @a, {tee => 1};
	}
	else
	{
		my $h = $a[1];
		$h->{tee} = 1;
		$a[1] = $h;
	}
	return systema(@a);
}

sub systemxi
{
	systemi(@_)->ordie;
}

sub log_hello
{
	my $prog = "$0 @ARGV";

	my $system_log = $ENV{NBU_BUILD_LOG};
	$system_log = "c:/system.log" if !$system_log;

	my $when = strftime("%y-%m-%d %H:%M:%S", localtime);
	my $where = getcwd;

	while (1)
	{
		open LOG, ">>$system_log" and last;
		Time::HiRes::sleep(1 + rand);
	}

	print LOG "=== $when (*) [$where]\n$prog\n";
	close LOG;
}

1;
