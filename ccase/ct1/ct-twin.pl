#!/bin/perl

use strict;
use Scaffolds::System;
use Scaffolds::Util;
use Scaffolds::Command;

our $VERSION = "1.0.0";

my @files;
my $ignore_flag;
my $unignore_flag;
my $show_flag;
my $nop_flag = 0;

while (@ARGV)
{
	my $a = $ARGV[0];
	if ($a eq '-f')
	{
		shift;
		@files = read_list(shift);
	}
	elsif ($a eq '-i')
	{
		shift;
		$ignore_flag = 1;
	}
	elsif ($a eq '-u')
	{
		shift;
		$unignore_flag = 1;
	}
	elsif ($a eq '-s')
	{
		shift;
		$show_flag = 1;
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

push @files, @ARGV;
die "Nothing to do.\n" if $#files == -1;

foreach (@files)
{
	my $f = $_;
	my $cmd;
	if ($ignore_flag)
	{
		$cmd = "cleartool mkattr IgnoreEvilTwin 1 $f";
		my $mkattr = new Scaffolds::System($cmd) if ! $nop_flag;
	}
	elsif ($unignore_flag)
	{
		$cmd = "cleartool rmattr IgnoreEvilTwin $f";
		my $rmattr = new Scaffolds::System($cmd) if ! $nop_flag;
	}
	elsif ($show_flag)
	{
		$cmd = "cleartool describe -short -aattr IgnoreEvilTwin $f";
		if (! $nop_flag)
		{
			my $desc = new Scaffolds::System($cmd);
			print "$f is " . ($desc->out0 eq "1" ? "ignored" : "unignored") . "\n";
		}
	}
	print "$cmd\n" if $nop_flag;
}

exit(0);

sub print_help
{
	print <<END;
Control Evil Twin element checks.

usage:
ct1 twin [-i|-u] [-s] [-n] [-f <file>] <element> ...
ct1 twin [-h | -help | -v | -version]

options:
  -i         ignore evil twin <element>
  -u         un-ignore evil twin <element>
  -s         show whether evil twin <element> is ignored
  -f <file>  operate on elements listed in <file>
  -n         just print messages, don't execute commands
  -h         print this message
  -v         print version
END
}
