#!/bin/perl

use strict;
use List::Util 'max';
use Scaffolds::System;
use Scaffolds::Util qw(wchomp);
use Scaffolds::Command;

our $VERSION = "2.0.0";

my $env_user = $ENV{USERNAME};

my $noact_flag = 0;
my $act_flag = 0;
my $snap_flag = 0;
my $dyn_flag = 0;
my $user;
my $showhost_flag = 0;
my $byhost_flag = 0;
my $local_flag = 0;
my $dumpspec_flag = 0;
my $filter_host;

while (@ARGV)
{
	my $a = $ARGV[0];
	if ($a eq '-my')
	{
		shift;
		$user = $env_user;
	}
	elsif ($a eq '-user')
	{
		shift;
		$user = shift;
	}
	elsif ($a eq '-act')
	{
		shift;
		$act_flag = 1;
	}
	elsif ($a eq '-noact')
	{
		shift;
		$noact_flag = 1;
	}
	elsif ($a eq '-showhost')
	{
		shift;
		$showhost_flag = 1;
	}
	elsif ($a eq '-byhost')
	{
		shift;
		$byhost_flag = 1;
		$showhost_flag = 1;
	}
	elsif ($a eq '-host')
	{
		shift;
		$filter_host = shift;
	}
	elsif ($a eq '-local')
	{
		shift;
		$local_flag = 1;
	}
	elsif ($a eq '-snap')
	{
		shift;
		$snap_flag = 1;
	}
	elsif ($a eq '-dyn')
	{
		shift;
		$dyn_flag = 1;
	}
	elsif ($a eq '-dumpspec')
	{
		shift;
		$dumpspec_flag = 1;
	}
	else
	{
		last if ! other_options($a);
	}
}

my $localhost = lc($ENV{COMPUTERNAME});

my $lsview = new Scaffolds::System("cleartool lsview");
die "Error querying views. Aborting.\n" if $lsview->retcode;

my %views;
my %hosts;
foreach ($lsview->out)
{
	next if $_ !~ '(\*)? ([^ ]+)\s*\\\\\\\\([^\\\\]+).*';

	my $act = $1 eq "*";
	my $view = $2;
	my $host = lc $3;
	next if $local_flag && $host ne $localhost;
	next if $user ne "" && lc($view) !~ lc("^$user");
	next if $act_flag && ! $act || $noact_flag && $act;
	
	if ($snap_flag || $dyn_flag)
	{
	}

	$views{$view} = $host;
	$hosts{$host} = 1;
}

# View attributes: snapshot

my $max_view_length = max(map { length $_ } sort keys %views);

if (! $byhost_flag)
{
	for my $view (sort keys %views)
	{
		my $host = $views{$view};
		next if $filter_host && $host ne $filter_host;
		print "$view\n" if !$showhost_flag;;
		printf("%-*s %s\n", $max_view_length, $view, $host) if $showhost_flag;
		view_op($view);
	}
}
else
{
	for my $host1 (sort keys %hosts)
	{
		for my $view (sort keys %views)
		{
			my $host = $views{$view};
			next if $host ne $host1;
			printf("%-*s %s\n", $max_view_length, $view, $host);
			view_op($view);
		}
	}
}

1;

sub view_op
{
	my ($view) = @_;
	
	if ($dumpspec_flag)
	{
		my $catcs = systema("cleartool catcs -tag $view");
		open F, ">$view.cspec" or die "Error: cannot create file $view.spec\n";
		print F $catcs->outText;
		close F;
	}
}

sub print_help
{
	print <<END;
List names of ClearCASE views.

ct1 lsviews [-my | -user name] [-act | -noact] [-showhost|-byhost] [-host name]
ct1 lsviews [-h | -help | -v | -version]

options:
  -my          list my views (name starting with user_)
  -user name   list specified users\'s views
  -snap        list only snapshot views
  -dyn         list only dynamic views
  -act         list only active (started) views
  -noact       list only inactive (non-started) views
  -showhost    also show where view is located
  -byhost      sort by host
  -host name   only list views on host <name>
  -local       only list views on localhost
  -dumpspec    write view configspec to file
  -h           print this message
  -v           print version
END
}
