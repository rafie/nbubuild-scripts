#!/bin/perl

use strict;
use Scaffolds::System;
use Scaffolds::Util qw(wchomp);
use Scaffolds::Command;

our $VERSION = "2.0.0";
our $admin_vob = "TBU_PVOB_2";

die "No files specified\n" if $#ARGV == -1;

our @failed;

my %brnames = ();
my %vobs = ();

my $local_flag = 0;
my $raw_flag = 0;
my $nop_flag = 0;
my $short_flag = 0;

while (@ARGV)
{
	my $a = $ARGV[0];
	if ($a eq '-name')
	{
		shift;
		my $br = shift;
		$brnames{$br} = 1;
	}
	elsif ($a eq '-names')
	{
		shift;
		my $fname = shift;
		open F, "$fname" or die "Cannot open file $fname. Aborting.\n";
		foreach (<F>)
		{
			wchomp;
			$brnames{$_} = 1;
		}
		close F;
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
	elsif ($a eq '-vob')
	{
		shift;
		my $vob = shift;
		$vobs{$vob} = 1;
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
			$vobs{$_} = 1;
		}
		close F;
		$local_flag = 1;
	}
	elsif ($a eq '-short')
	{
		shift;
		$short_flag = 1;
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

mount_admin_vob();

$vobs{$admin_vob} = 1 if !$local_flag && ! keys(%vobs);

foreach my $branch (keys %brnames)
{
	$branch = $ENV{USERNAME} . "_${branch}_br" if ! $raw_flag;

	foreach my $vob (keys %vobs)
	{
		my $fail = 0;
		if (! $nop_flag)
		{
			my $global = $local_flag ? "" : "-global -acquire";
			my $mkbrtype = new Scaffolds::System("cleartool mkbrtype $global -nc $branch\@/$vob");
			if ($mkbrtype->retcode)
			{
				$fail = 1;
				push @failed, "branch $branch in VOB $vob" ;
			}			
		}
		if (!$fail)
		{
			if ($short_flag)
			{
				print "$branch\n";
			}
			else
			{
				print "Created $branch in VOB $vob\n" if $local_flag;
				print "Created global branch $branch\n" if !$local_flag;
			}
		}
	}
}

if ($#failed > -1)
{
	if (! $short_flag)
	{
		print "\nCreating errors:\n";
		foreach my $f (@failed)
		{
			print "$f\n";
		}
	}
	exit 1;
}
else
{
	exit 0;
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
Create a ClearCASE branch type.

usage:
ct1 mkbranch [-name <branch-name> | -names <filename>] [-raw] [-vob <vob> | -vob <filename>] [-local]
ct1 mkbranch [-h | -help | -v | -version]

options:
  -name <branch> branch name [repeatable]
  -names <file>  operate on branch names listed in <file> [repeatable]
  -raw           don\'t append username prefix and _br suffix to branch names
  -local         create local branch
  -vob <vob>     create local branch in specified VOB [repeatable]
  -vobs <file>   create local branch in VOBs listed in <file> [repeatable]
  -short         only print branch name as output
  -n             do nothing
  -h             print this message
  -v             print version
END
}
