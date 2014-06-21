#!/bin/perl

use strict;
use Scaffolds::System;
use Scaffolds::Util;
use Scaffolds::Command;

our $VERSION = "1.0.0";

die "No files specified\n" if $#ARGV == -1;

my @args;
my $nop_flag = 0;

while (@ARGV)
{
	my $a = $ARGV[0];
	if ($a eq '-f')
	{
		shift;
		@args = read_list(shift); 
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

push @args, @ARGV;

foreach my $file (@args)
{
	if (! $nop_flag)
	{
		print "$file ... ";
		my $co = new Scaffolds::System("cleartool co -nc -ptime $file");
		print $co->retcode ? "FAILED\n" : "OK\n";
	}
	else
	{
		print "$file ... " . (-e $file ? "OK" : "FAILED") . "\n";
	}
}

exit 0;

sub print_help
{
	print <<END;
Check-out elements.

usage:
ct1 co [-n] [-f <file>] <filelist>
ct1 co [-h | -help | -v | -version]

options:
  -f <file>  operate on files listed in <file>
  -n         just print messages, don't execute commands
  -h         print this message
  -v         print version
END
}
