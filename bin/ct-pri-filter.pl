#!/bin/perl

my @extensions = qw(
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
	pl
	out
	out\.ctdt.*
	out\.objects
	keep.*
	contrib.*
	merge.*
	ib_pdb_index
	);

my @files = qw(
	\.cvsignore
	.*~ BuildLog\.htm
	make\.log
	);

my @dirs = qw(
	\.svn
	CVS
	lost\+found
	bin
	);

my @jokers = qw(
	rv-win32-debug
	rv-755-opt
	rv-tamar-opt
	rv-dora-opt
	rv-avatar-opt
	rv-avatar-a8-opt
	);

NEXT: while (<>)
{
	chomp;

	foreach my $f (@extensions)
	{
		next NEXT if $_ =~ "\.$f\$";
	}

	foreach my $f (@files)
	{
		next NEXT if $_ =~ "$f\$";
	}
	
	foreach my $f (@jokers)
	{
		next NEXT if $_ =~ "$f";
	}

	next if -d $_;

	print "$_\n";
}
