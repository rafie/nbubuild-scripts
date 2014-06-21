#!/bin/perl

use strict;
use Scaffolds::System;
use Scaffolds::Util qw(wchomp);
use Scaffolds::Command;

our $VERSION = "1.0.0";

my @vobs;
my $branch;
my $int_branch;

while (@ARGV)
{
	my $a = $ARGV[0];
	if ($a eq '-vob' || $a eq '-in')
	{
		shift;
		push @vobs, shift;
	}
	elsif ($a eq '-br')
	{
		shift;
		$branch = shift;
	}
	elsif ($a eq '-intbr')
	{
		shift;
		$int_branch = shift;
	}
	elsif ($a eq '-avobs')
	{
		push @vobs, shift;
	}
	else
	{
		last if ! other_options($a);
	}
}

$int_branch = 'main' if ! $int_branch;

die "Branch not specified.\n" if ! $branch;

push @vobs, '-avobs' if $#vobs == -1;

my $vobs = join(" ", sort @vobs);

# find checkedout elements
my $lsco = new Scaffolds::System("cleartool lsco -short -cview -me -recurse $vobs");
die "Error querying checked-out files. Aborting.\n" if $lsco->retcode;
foreach ($lsco->out)
{
	next if $_ =~ 'lost\+found';
	s/\\/\//g;
	print "$_\n";
}

# find elements with activity branch with no integration branch
my $find_nointbr = new Scaffolds::System("cleartool find $vobs -cview -print -nxname -element \"brtype($branch) && ! brtype($int_branch)\"");
die "Error querying elements. Aborting.\n" if $find_nointbr->retcode;
foreach ($find_nointbr->out)
{
	next if $_ =~ 'lost\+found';
	s/\\/\//g;
	print "$_\n";
}

# find elements that have no sync neither commit transaction
my $find_pending = new Scaffolds::System("cleartool find $vobs -cview -print -nxname -element \"brtype($branch)\" -version \"version(.../$branch/LATEST) && !merge(.../$int_branch,.../$branch) && !merge(.../$branch,.../$int_branch)\"");
foreach ($find_pending->out)
{
	next if $_ =~ 'lost\+found';
	s/\\/\//g;
	print "$_\n";
}

## find elements with both activity branch and integration branch
#my $find_br_and_intbr = new Scaffolds::System("cleartool find $vobs -cview -print -nxname -element \"brtype($branch) && brtype($int_branch)\"");
#die "Error querying elements. Aborting.\n" if $find_br_and_intbr->retcode;
#foreach ($find_br_and_intbr->out)
#{
#	next if $_ =~ 'lost\+found';
#
#	# find elements that have no sync neither commit transaction
#	my $find_pending = new Scaffolds::System("cleartool find $_ -cview -nr -print -nxname -element \"brtype($branch)\" -version \"version(.../$branch/LATEST) && !merge(.../$int_branch,.../$branch) && !merge(.../$branch,.../$int_branch)\"");
#
#	foreach ($find_pending->out)
#	{
#		next if $_ =~ 'lost\+found';
#		s/\\/\//g;
#		print "$_\n";
#	}
#}

exit 0;

sub print_help
{
	print <<END;
ct1 pending {-br|-branch} branch [-intbr branch] [-in vob | -vob vob | -avobs]
ct1 pending [-h | -help | -v | -version]

options:
  -br <branch>     activity branch
  -intbr <branch>  integration branch
  -vob <v>         scan all files in VOB <v> (repeatable)
  -in <v>          scan all files in VOB <v> (repeatable)
  -avobs           scan all mounted VOBs
  -h            print this message
  -v            print version
END
}
