#!/bin/perl

use strict;
use Scaffolds::System;
use Scaffolds::Util qw(wchomp);
use Scaffolds::Command;

our $VERSION = "1.0.0";

#------------------------------------------------------------------------------

my @filter_extensions = qw(
	d
	o
	obj
	sbr
	pch
	lib
	exe
	dll
	idb
	pdb
	ncb
	opt
	bsc
	res
	plg
	i
	itree
	obj-files
	exp
	ilk
	map
	a
	out
	out\.ctdt.*
	out\.objects
	keep.*
	contrib.*
	merge.*
	RADVISION.*.user
	ib_pdb_index
	ib_tag
	manifest
	kw
	kwspec
	);

my @filter_files = qw(
	\.mvfs_*
	\.cvsignore
	.*~ BuildLog\.htm
	make\.log
	mt\.dep
	_ReSharper.*
	);

my @filter_dirs = qw(
	\.svn
	CVS
	lost\+found
	);

my @filter_jokers = qw(
	rv-win32-debug
	rv-755-opt
	rv-tamar-opt
	\\.mvfs_
	bin\\\\rv-win32-debug
	bin\\\\rv-avatar-opt
	bin\\\\rv-avatar-debug
	bin\\\\rv-avatar-a8-opt
	bin\\\\rv-avatar-a8-debug
	bin\\\\rv-avatar-v2-opt
	bin\\\\rv-avatar-v2-debug
	);

#------------------------------------------------------------------------------

our @failed;

my @args;
my $view;
my $avobs_flag;
my $allvob_flag;
my $scope;
my $pri_flag;
my $co_flag;
my $who_flag;

while (@ARGV)
{
	my $a = $ARGV[0];
	if ($a eq '-view')
	{
		$view = shift;
	}
	elsif ($a eq '-avobs')
	{
		$avobs_flag = 1;
		shift;
	}
	elsif ($a eq '-all')
	{
		$allvob_flag = 1;
		shift;
	}
	elsif ($a eq '-pri')
	{
		$pri_flag = 1;
		shift;
	}
	elsif ($a eq '-who')
	{
		$who_flag = 1;
		shift;
	}
	elsif ($a eq '-co')
	{
		$co_flag = 1;
		shift;
	}
	else
	{
		last if ! other_options($a);
	}
}

if (!$pri_flag && !$co_flag)
{
	$pri_flag = 1;
	$co_flag = 1;
}

if (!$avobs_flag && !$allvob_flag)
{
	$avobs_flag = 1;
}

$scope = "-avobs" if $avobs_flag;
$scope = "-all" if $allvob_flag;

my $fmt = "-short";
$fmt = "-fmt \"%u %n\\n\"" if $who_flag;

if ($co_flag)
{
	my $lsco = new Scaffolds::System("cleartool lsco -cview $fmt $scope");
	if (! $lsco->retcode)
	{
		my @a = $lsco->out;
		print $lsco->outText if $#a > -1;

#		foreach my $file ($lsco->out)
#		{
#			print "$file\n";
#		}
	}
	else
	{
		print "Error querying checked-out files. Trying something else.\n";

		my $pwv = systema("cleartool pwv -root");
		my $vroot = $pwv->out0;
	
		opendir(DIR, $vroot) || die "Cannot access view\n";
		my @vobs = readdir(DIR); 
		closedir DIR;
		foreach my $vob (@vobs)
		{
			next if $vob eq "." || $vob eq "..";
			my $lsco = new Scaffolds::System("cleartool lsco -cview $fmt -all $vroot/$vob");
			my @a = $lsco->out;
			print $lsco->outText if $#a > -1;
		}
	}
#	die "Error querying checked-out files. Aborting.\n" if ;

}

if ($pri_flag)
{
	my $lspri = new Scaffolds::System("cleartool lspri -short -other");
	die "Error querying private files. Aborting.\n" if $lspri->retcode;
	
	FILE: foreach my $file ($lspri->out)
	{
		foreach my $f (@filter_extensions)
		{
			next FILE if $file =~ "\.$f\$";
		}
	
		foreach my $f (@filter_files)
		{
			next FILE if $file =~ "$f\$";
		}
		
		foreach my $f (@filter_jokers)
		{
			next FILE if $file =~ $f;
		}
	
		next if -d $file;
	
		print "$file\n";
	}
}

if ($#failed > -1)
{
	print "\nFiles with errors:\n";
	foreach my $f (@failed)
	{
		print "$f\n";
	}
	exit 1;
}
else
{
	exit 0;
}

sub print_help
{
	print <<END
ct1 pri [-view <name>] [-co] [-pri]
ct1 pri [-r | -avobs | -all] [-d] [-n] [-co] [-f <file>] <filelist>
ct1 pri [-h | -help | -v | -version]

options:
  -view <name> operate on view <name>
  -avobs       operate on all VOBs       
  -all         operate on all files in current VOB
  -co          print checked-out files
  -pri         print private files
  -who         print check-out owner
  -h           print this message
  -v           print version
END
}
