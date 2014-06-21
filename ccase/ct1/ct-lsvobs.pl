#!/bin/perl

use strict;
use Scaffolds::Command;
use Scaffolds::System;
use Scaffolds::Util qw(wchomp);

our $VERSION = "1.0.0";

while (@ARGV)
{
	my $a = $ARGV[0];
	last if ! other_options($a);
}

my $lsvob = new Scaffolds::System("cleartool lsvob");
die "Error querying VOBs. Aborting.\n" if $lsvob->retcode;

my @vobs;
foreach ($lsvob->out)
{
	if ($_ =~ '\* ([^ ]+) .*')
	{
		my $s = $1;
		$s =~ s/\\/\//g;
		push @vobs, $s;
	}
}
print join("\n", sort @vobs) . "\n";
exit 0;

sub print_help
{
	print <<END;
Dispaly mounted VOBs.

ct1 lsvobs <general-options>

options:
  (none)

general options:
  -h   print this message
  -v   print version

END
}
