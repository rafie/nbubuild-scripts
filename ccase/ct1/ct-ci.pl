#!/bin/perl

use strict;
use Scaffolds::System;
use Scaffolds::Util qw(wchomp);
use Scaffolds::Command;

our $VERSION = "2.0.0";

die "No files specified\n" if $#ARGV == -1;

our @failed;

my @elements;
my $recurse_flag = 0;
my $all_flag = 0;
my $nop_flag = 0;
my $keepco_flag = 0;
my $unco_flag = 0;
my @vobs;

while (@ARGV)
{
	my $a = $ARGV[0];
	if ($a eq '-f')
	{
		shift;
		@elements = read_list(shift); 
	}
	elsif ($a eq '-all')
	{
		shift;
		$all_flag = 1;
	}
	elsif ($a eq '-vob')
	{
		shift;
		push @elements, shift;
	}
	elsif ($a eq '-r')
	{
		shift;
		$recurse_flag = 1;
	}
	elsif ($a eq '-n')
	{
		shift;
		$nop_flag = 1;
	}
	elsif ($a eq '-co')
	{
		shift;
		$keepco_flag = 1;
	}
	else
	{
		last if ! other_options($a);
	}
}

die "Conflicting flags.\n" if $all_flag && $recurse_flag;

push @elements, @ARGV;

if ($recurse_flag)
{
	my $pwd = new Scaffolds::System("cleartool pwd");
	my $pwv = new Scaffolds::System("cleartool pwv -root");
	if (!$pwd->retcode && !$pwv->retcode && $pwd->out0 eq $pwv->out0)
	{
		$all_flag = 1;
		$recurse_flag = 0;
	}
}

my $avobs = $all_flag ? "-avobs" : "";
my $recurse = $recurse_flag ? "-recurse" : "";

my @chouts;

if ($all_flag)
{
	@chouts = all_checkouts();
}
else
{
	my $lsco = new Scaffolds::System("cleartool lsco -short -cview -me $avobs $recurse @elements");
	die "Error querying checked-out files. Aborting.\n" if $lsco->retcode;
	@chouts = $lsco->out;
}

my $suffix = $nop_flag ? "\n" : "";

foreach my $file (@chouts)
{
	my $diff = new Scaffolds::System("cleartool diff -pred $file");
	my $rc;
	if (! $diff->retcode)
	{
		# no changes

		if ($keepco_flag)
		{
			print "$file (no changes, kept checked-out)\n";
			next;
		}

		print "$file: UNDO" . $suffix;
		next if $nop_flag;

		print " ... ";
		my $unco = new Scaffolds::System("cleartool unco -rm $file");
		$rc = $unco->retcode;
	}
	else
	{
		# file changed

		print "$file" . $suffix;
		next if $nop_flag;

		print " ... ";
		my $ci = new Scaffolds::System("cleartool ci -nc -ptime $file");
		$rc = $ci->retcode;
		if ($keepco_flag && ! $rc)
		{
			my $co = new Scaffolds::System("cleartool co -nc -ptime $file");
			$rc = $co->retcode;
		}
	}
	if (! $rc)
	{
		print "OK\n";
	}
	else
	{
		print "FAILED\n";
		push @failed, $file;
	}
}

exit 0 if $#failed == -1;

print "\nFiles with errors:\n";
foreach my $f (@failed)
{
	print "$f\n";
}

exit 1;

sub all_checkouts
{
	my @a;

	my $lsco = new Scaffolds::System("cleartool lsco -short -cview -me -avobs");
	if (! $lsco->retcode)
	{
		@a = $lsco->out;
		return @a;
	}

	my $pwv = systema("cleartool pwv -root");
	my $vroot = $pwv->out0;

	opendir(DIR, $vroot) || die "Cannot access view\n";
	my @vobs = readdir(DIR); 
	closedir DIR;
	foreach my $vob (@vobs)
	{
		next if $vob eq "." || $vob eq "..";
		my $lsco = new Scaffolds::System("cleartool lsco -short -cview -me -all $vroot/$vob");
		
		my @b = $lsco->out;
		push @a, @b;
	}

	return @a;
}

sub print_help
{
	print <<END;
Check-in elements.

usage:
ct1 ci [options] -all
ct1 ci [options] -vob <vob> 
ct1 ci [options] [-r] [-f <file>] <filelist>

selection:
  -all       check-in all checked-out elements in view
  -vob <vob> check-in files in <vob> (repeatable)
  -f <file>  operate on files listed in <file>
  -r         recursive operation

options:
  -co        keep checked-out (do not undo if identical to predecessor)
  -unco      un-checkout files identical to predecessor
  -n         just print messages, don't execute commands
  -h         print this message
  -v         print version
END
}
