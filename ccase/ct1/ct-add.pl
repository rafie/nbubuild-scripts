#!/bin/perl

use strict;
use Cwd qw(getcwd realpath);
use File::Basename;
use File::Spec;
use Scaffolds::System;
use Scaffolds::Util qw(wchomp read_list);
use Scaffolds::Command;

our $VERSION = "1.1.0";

our @failed;

my @args;
my $quiet = 0;

while (@ARGV)
{
	my $a = $ARGV[0];
	if ($a eq '-f')
	{
		shift;
		@args = read_list(shift);
	}
	elsif ($a eq '-q')
	{
		shift;
		$quiet = 1;
	}
	else
	{
		last if ! other_options($a);
	}
}

push @args, @ARGV;

die "No files specified\n" if $#args == -1;

my %dirs;
foreach (@args)
{
	my $d = dirname($_);
	my $f = basename($_);
	if (exists $dirs{$d})
	{
		my $a = $dirs{$d};
		push @$a, $f;
	}
	else
	{
		$dirs{$d} = [ $f ];
	}
}

foreach my $d (sort keys %dirs)
{
	my @a = @{$dirs{$d}};
	my $s;
	map { $s .= "$_ " } @a;
	add_dir($d, $s, 0, -1);
}

if ($#failed > -1)
{
	print "\nFailed to add:\n";
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

sub add_dir
{
	my ($dir, $filespec, $depth, $max_depth) = @_;

	my $iselem = systema("cleartool ls -sh -d $dir");
	if (! ($iselem->out0 =~ /@@/))
	{
		add_dir(realpath("$dir/.."), basename(realpath($dir)), 0, 0);
	}

	my $root = getcwd;
	chdir $dir or do { warn "Cannot access $dir.\n"; return; };

	print "\nWorking in directory $dir\n" if !$quiet;

	my @filespec = glob($filespec);
	my @subdirs = grep { -d } @filespec;
	my @files = grep { -f } @filespec;
	
	if ($depth == 0 && ! is_dir_checked_out('.'))
	{                                  
		print "Checking out directory $dir\n" if !$quiet;
		systema("cleartool co -nc -ptime .")->ordie("Cannot check out $dir");
	}

	my $ls = systema("cleartool ls -short");
	my %state;
	map { my ($f, $c) = classify($_); $state{$f} = $c; } $ls->out;
	
	foreach my $file (@files)
	{
		next if $state{$file} ne 'pri';
		print "Adding $file... " if !$quiet;
		my $mkelem_files = new Scaffolds::System("cleartool mkelem -nc -ci -ptime \"$file\"");
		if ($mkelem_files->retcode)
		{
			print "FAILED\n" if !$quiet;
			push @failed, "$dir/$file";
			if (! -e $file && -e "$file.mkelem")
			{
				rename "$file.mkelem", $file;
			}
		}
		else
		{
			print "OK\n" if !$quiet;
		}
	}
	
	my @good_subdirs;
	foreach my $subdir (@subdirs)
	{
		if (-e "$subdir.mkelem")
		{ 
			warn "$subdir.mkelem exists, $subdir not added.\n"; 
			next; 
		}
		if ($state{$subdir} ne 'elem' && $state{$subdir} ne 'co')
		{
			rename $subdir, "$subdir.mkelem" or do { warn "Cannot add $subdir.\n"; next; };
			rename "$subdir.mkelem", $subdir;
		}
		push @good_subdirs, $subdir;
	}

	foreach my $subdir (@good_subdirs)
	{
		if ($state{$subdir} ne 'elem' && $state{$subdir} ne 'co')
		{
			rename $subdir, "$subdir.mkelem";
			print "Adding directory $subdir...\n" if !$quiet;
			my $mkelem = new Scaffolds::System("cleartool mkelem -nc -eltype directory \"$subdir\"");
			if ($mkelem->retcode)
			{
				rename "$subdir.mkelem", $subdir;
				warn "Cannot create directory $subdir\n";
				next;
			}
			my @subdir_files = glob("$subdir.mkelem/*");
			if ($#subdir_files > -1)
			{
				my $chmod = new Scaffolds::System("chmod +w \"$subdir.mkelem\"/*");
				my $mv = new Scaffolds::System("mv \"$subdir.mkelem\"/* \"$subdir\"");
				die "Error adding directory $subdir. Aborting.\n" if $mv->retcode;
			}
			rmdir "$subdir.mkelem" or warn "Cannot remove directory $subdir.mkelem\n";
		} 
		elsif ($state{$subdir} ne 'co')
		{
			my $co = new Scaffolds::System("cleartool co -ptime -nc \"$subdir\"") or die "Cannot check out $subdir\n";
		}

		if ($max_depth == -1 || $depth + 1 < $max_depth)
		{
			add_dir($subdir, '*', $depth + 1, $max_depth == -1 ? -1 : $max_depth - 1);
		}
	}

	print "Done with directory $dir\n" if !$quiet;
	my $ci = new Scaffolds::System("cleartool ci -nc -ptime -identical .");
	warn "Cannot check-in $dir\n" if $ci->retcode;

#	my $m1 = "Done with directory $dir";
#	my $diff = new Scaffolds::System("cleartool diff -pred .");
#	if ($diff->retcode == 0)
#	{
#		print "$m1 - undoing check-out\n" if !$quiet;
#		my $unco = new Scaffolds::System("cleartool unco .");
#		warn "Problem undoing check-out of $dir\n" if $unco->retcode;
#	}
#	else
#	{
#		print "$m1\n";
#		my $ci = new Scaffolds::System("cleartool ci -nc -ptime .");
#		warn "Cannot check-in $dir\n" if $ci->retcode;
#	}
	
	chdir $root;
}

sub is_dir_checked_out
{
	my ($dir) = @_;
	my $lsco = new Scaffolds::System("cleartool lsco -dir -me -cview \"$dir\"");
	return ! $lsco->retcode && scalar($lsco->out);
}

sub is_dir_element
{
	my ($dir) = @_;
	my $ls = new Scaffolds::System("cleartool ls -vob_only -d \"$dir\"");
	return ! $ls->retcode && scalar($ls->out);
}

sub is_file_element
{
	my ($file) = @_;
	my $ls = new Scaffolds::System("cleartool ls -vob_only \"$file\"");
	return ! $ls->retcode && scalar($ls->out);
}

sub classify
{
	my ($file) = @_;
	my $c;
	if ($file =~ /(.*)@@(.*)/)
	{
		$file = $1;
		my $br = $2;
		$c = $br =~ /CHECKEDOUT$/ ? 'co' : 'elem';
	}
	else
	{
		$c = 'pri';
	}
	return ($file, $c);
}

sub print_help
{
	print <<END;
Add elements to ClearCASE.

usage:
ct1 add [-f <file>] [-q] <filelist>
ct1 add [-h | -help]

options:
  -f <file>  take file list from <file> (repeatable)
  -q         quiet operation (print only errors)
END
}
