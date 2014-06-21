#!/bin/perl

use strict;

use Scaffolds;
use Scaffolds::Command;

our $VERSION = "1.0.0";

my @views;

while (@ARGV)
{
	my $a = $ARGV[0];
	last if ! other_options($a);
}

push @views, @ARGV;

foreach my $view (@views)
{
	my $end = systema("cleartool endview -server $view");
	print "stopped: $view\n" if $end->ok;
}

exit 0;

sub print_help
{
	print <<END;
End (stop) dynamic views.

ct1 endview [optinos] <views>

options:
  -f FILE   stop views listed in FILE

general options:
  -h   print this message
  -v   print version

END
}
