#!/bin/perl

use strict;
use Scaffolds::System;
use Scaffolds::Util qw(wchomp);
use Scaffolds::Command;

our $VERSION = "1.0.0";
our $admin_vob = "TBU_PVOB_2";

die "No files specified\n" if $#ARGV == -1;

our @failed;

my @vobs;
my @names;
my $raw_flag = 0;
my $local_flag = 0;
my $avobs_flag = 0;
my $vob_flag = 0;
my $nop_flag = 0;

while (@ARGV)
{
	my $a = $ARGV[0];
	if ($a eq '-names')
	{
		shift;
		my $fname = shift;
		open F, "$fname" or die "Cannot open file $fname. Aborting.\n";
		foreach (<F>)
		{
			wchomp;
			push @names, $_;
		}
		close F;
	}
	elsif ($a eq '-name')
	{
		shift;
		push @names, shift;
	}
	elsif ($a eq '-raw')
	{
		shift;
		$raw_flag = 1;
	}
	elsif ($a eq '-local')
	{
		shift;
		$local_flag = 1;
	}
	elsif ($a eq '-vobs')
	{
		shift;
		my $fname = shift;
		open F, "$fname" or die "Cannot open file $fname. Aborting.\n";
		foreach (<F>)
		{
			wchomp;
			push @vobs, $_;
		}
		close F;
		$vob_flag = 1;
	}
	elsif ($a eq '-vob')
	{
		shift;
		push @vobs, shift;
		$vob_flag = 1;
	}
	elsif ($a eq '-avobs')
	{
		shift;
		$avobs_flag = 1;
	}
	elsif ($a eq '-n')
	{
		shift;
		$nop_flag = 1;
	}
	else
	{
		last if ! other_options($a);
	}
}

die "Conflicting flags.\n" if $avobs_flag && $vob_flag;

if ($avobs_flag)
{
	my $lsvobs = new Scaffolds::System("ct-lsvobs.pl");
	die "Error querying VOBs. Aborting.\n" if $lsvobs->retcode;
	push @vobs, $lsvobs->out;
}
else
{
	for (@vobs)
	{
		$_ = "/$_";
	}
}

die "-vob, -vobs, -avobs options require -local\n" if $#vobs > -1 && !$local_flag;

push @vobs, $admin_vob if !$local_flag;

mount_admin_vob();

my $global_opt = $local_flag ? "" : "-global";

foreach my $label (@names)
{
	$label = $ENV{USERNAME} . "_${label}" if ! $raw_flag;

	foreach my $vob (@vobs)
	{
		my $mklbtype;
		if (!$nop_flag)
		{
			$mklbtype = new Scaffolds::System("cleartool mklbtype -nc $global_opt $label\@$vob");
			push @failed, "label $label in VOB $vob" if $mklbtype->retcode;
		}
		print "Created $label" . ($local_flag ? " in VOB $vob" : "") . "\n" if $nop_flag || !$mklbtype->retcode;
	}
}

if ($#failed > -1)
{
	print "\nCreating errors:\n";
	foreach my $f (@failed)
	{
		print "$f\n";
	}
	exit 1
}
else
{
	exit 0
}

#----------------------------------------------------------------------------------------------

sub mount_admin_vob
{
	my $mount = new Scaffolds::System("cleartool mount -persistent \\$admin_vob", { log => 0 });
}

#----------------------------------------------------------------------------------------------

sub print_help
{
	print <<END;
ct1 mklabel [-vob <vob> | -vobs <f> | -avobs] [-raw] [-names <file>] -name <label-name>
ct1 mklabel [-h | -help | -v | -version]

options:
  -name <l>  label type name (repeatable)
  -names <f> operate on label type names listed in <f> (repeatable)
  -raw       don't append username prefix to label name
  -local     create a local type
  -avobs     create local label type on all mounted VOBs
  -vobs <f>  create local label type on specified VOB in <f> (repeatable)
  -vob <vob> create local label type on specified VOB (repeatable)
  -n         do nothing
  -h         print this message
  -v         print version
END
}
