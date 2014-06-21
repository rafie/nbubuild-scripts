#!/bin/perl

use strict;
use Cwd;
use Scaffolds::System;
use Scaffolds::Util qw(wchomp);
use Sys::CPU;

sub terminate
{
	exit(1);
}

$SIG{INT} = 'terminate';
$SIG{QUIT} = 'terminate';
$SIG{ABRT} = 'terminate';
$SIG{TERM} = 'terminate';
#$SIG{__DIE__} = 'terminate';

# make.exe location
my $broot = $ENV{NBU_BUILD_ROOT};
my $perl  = $ENV{NBU_BUILD_PERL} . "/bin/perl.exe";
my $scripts = "$broot/sys/scripts/bin";

my $pwv = new Scaffolds::System("cleartool pwv -root -sh", { log => 0 });
my $from_view = ! $pwv->retcode;
print "warning: running make from network\n" if ! $from_view;

my $vroot;
$vroot = $pwv->out(0) if $from_view;
if (!$from_view && $ENV{VIEW_ROOT})
{
	$from_view = -d $ENV{VIEW_ROOT};
	$vroot = $ENV{VIEW_ROOT} if $from_view;
} 

my $mkpath = $from_view ? "$vroot\\freemasonBuild\\freemason\\4\\bin\\windows" : "$broot\\sys\\util\\bin";
my $make = "$mkpath\\make.exe";

if (! -x $make)
{
	$mkpath = $from_view ? "$vroot\\NBU_BUILD\\freemason\\4\\bin\\windows" : "$broot\\sys\\util\\bin";
	$make = "$mkpath\\make.exe";

	if (! -x $make)
	{
		die "Cannot find make. Check NBU_BUILD_ROOT environment variable.\n" if ! $from_view;
		die "Cannot find make. Check if NBU_BUILD/freemasonBuild VOB is in the current view.\n" if $from_view;
	}
}

# determine view type

my $pwv1 = new Scaffolds::System("cleartool pwv -sh", { log => 0 });
my $view = $pwv1->out(0);

my $dyn_view = 1;
my $lsview = new Scaffolds::System("cleartool lsview -long -cview", { log => 0 });
my @view_attr = grep { $_ =~ '^View attributes:' } $lsview->out;
if (@view_attr[0] =~ /^View attributes: (.*)/)
{
	my $snap = $1;
	$dyn_view = ($snap =~ /.*snapshot.*/) ? 0 : 1;
}

# distributed compilation

my $distcc_on_server = $dyn_view && $ENV{DISTCC_ON_SERVER} ne "0";

print "Preprocessing on client.\n" if ! $distcc_on_server; # @@

$ENV{DISTCC_VIEW_OPT} = "--view=$view --on-server" if $distcc_on_server;

my $dist_spec = 0;
my $dist = 1;
my @dist = grep { $_ =~ 'DIST=\d+' } @ARGV;
if (pop(@dist) =~ /DIST=(\d+)/)
{   
	$dist_spec = 1;
	$dist = 0 if $1 == 0;
}

my $jobs = 0;
my @jobs = grep { $_ =~ 'JOBS=\d+' } @ARGV;
if (pop(@jobs) =~ /JOBS=(\d+)/)
{   
	$jobs = $1 if $1 > 1;
}
else
{
	my $max_distcc_jobs = 16;
	my $distcc_jobs = $ENV{DISTCC_JOBS};
	if (! $distcc_jobs)
	{
		if ($distcc_on_server)
		{
			$distcc_jobs = `$perl $scripts/distcc-hosts.pl -slots`;
		}
		else
		{
			$distcc_jobs = 8 * Sys::CPU::cpu_count();
		}
		$jobs = $max_distcc_jobs if $distcc_jobs > $max_distcc_jobs;
	}
	else
	{
		$jobs = $distcc_jobs;
	}
}

$jobs = 1 if ! $jobs;

my $dist_opt;
$dist_opt .= "-j$jobs" if $dist && $jobs > 1;
$dist_opt .= " DIST=$dist" if ! $dist_spec;

$ENV{DISTCC_HOSTS} = `$perl $scripts/distcc-hosts.pl` if ! $ENV{DISTCC_HOSTS};
$ENV{DISTCC_HOSTS_diab} = `$perl $scripts/distcc-hosts.pl -c diab` if ! $ENV{DISTCC_HOSTS_diab};
$ENV{DISTCC_HOSTS_linux} = `$perl $scripts/distcc-hosts.pl -c linux` if ! $ENV{DISTCC_HOSTS_linux};

# $ENV{DISTCC_DIR} = "c:\\root\\distcc";
# mkdir("c:\\root\\distcc") if ! -d "c:\\root\\distcc";

# print "DISTCC_HOSTS=" . $ENV{DISTCC_HOSTS} . "\n";
# print "DISTCC_HOSTS_diab=" . $ENV{DISTCC_HOSTS_diab} . "\n";
# print "$make --no-print-directory --no-builtin-rules $dist_opt @ARGV\n";

# here we go...
my $rc = system("$make --no-print-directory --no-builtin-rules $dist_opt @ARGV");
die "error: cannot exeute $make\n" if $? == -1;
exit $? >> 8;
