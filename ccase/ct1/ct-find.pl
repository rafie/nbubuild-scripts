#!/bin/perl

use strict;
use Scaffolds::System;
use Scaffolds::Util qw(wchomp);
use Scaffolds::Command;

our $VERSION = "2.0.0";

my $branch;
my $label;
my $branch_v0_flag;
my $merged_flag;
my $unmerged_flag;
my $xpn_flag = 0;
my $type;

while (@ARGV)
{
	my $a = $ARGV[0];
	if ($a eq '-br' || $a eq '-branch')
	{
		shift;
		$branch = shift;
	}
	elsif ($a eq '-br0')
	{
		shift;
		$branch = shift;
		$branch_v0_flag = 1;
	}
	elsif ($a eq '-lb' || $a eq '-label')
	{
		shift;
		$label = shift;
	}
	elsif ($a eq '-merged')
	{
		shift;
		$merged_flag = 1;
	}
	elsif ($a eq '-unmerged')
	{
		shift;
		$unmerged_flag = 1;
	}
	elsif ($a eq '-xpn')
	{
		shift;
		$xpn_flag = 1;
	}
	elsif ($a eq '-type')
	{
		shift;
		$type .= "-type " . shift() . " ";
	}
	else
	{
		last if ! other_options($a);
	}
}

my $nxname = $xpn_flag ? "" : "-nxname";

my $query;

if ($branch_v0_flag)
{
	$query = "-element \"version(.../$branch/0) && !version(.../$branch/1)\"";
}
elsif ($merged_flag) # ($merged_flag || $unmerged_flag)
{
	my $non = $merged_flag ? "" : "!";
	$query = "-version \"version(.../$branch/LATEST) && ${non}hltype(Merge)\"";
}
elsif ($unmerged_flag)
{
	$query = "-fversion .../$branch/LATEST";
}
elsif ($branch)
{
	$query = "-element brtype($branch)";
}
elsif ($label)
{
	$query = "-element lbtype_sub($label)";
}

my $find_cmd = !$unmerged_flag ? 
				"cleartool find -avobs $query $type $nxname -visible -print" : 
				"cleartool findmerge -avobs $query $type $nxname -visible -print";
my $find = new Scaffolds::System($find_cmd);
if ($find->retcode)
{
	print STDERR join("\n", $find->err);
	die "\nError querying branch files. Aborting.\n";
}

foreach ($find->out)
{
	next if ! $xpn_flag && $_ =~ '@@'; 
	next if $_ =~ 'lost\+found';
	s/\\/\//g;
	print "$_\n";
}

exit 0;

sub print_help
{
	print <<END;
ct1 find <general-options> [-merged | -unmerged] {-br|-branch} <branch>
ct1 find <general-options> -br0 <branch>
ct1 find <general-options> {-lb|-label} <label>
ct1 find [-h | -help | -v | -version]

options:
  -br <branch>  look for elements with branch <branch> (repeatable)
  -lb <label>   look for elements with label <label> (repeatable)
  -br0 <branch> look for files elements with branch <branch> with version 0 only. implies -xpn.
  -h            print this message
  -v            print version

general options:
  -type {f|d|l} select only specified file types (file|dir|link)
  -xpn          display extended path names
  -follow       follow symbolic links

END
}
