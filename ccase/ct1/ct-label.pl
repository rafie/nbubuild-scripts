#!/bin/perl

use strict;
use Cwd qw(realpath);
use Scaffolds::System;
use Scaffolds::Util;
use Scaffolds::Command;

#----------------------------------------------------------------------------------------------

our $VERSION = "2.0.0";
our $admin_vob = "TBU_PVOB_2";

our $view_root;
our $view;
our $rel_pwd;

our @failed;

my $name;
my $raw_flag = 0;
my $repl_flag = 0;
my $local_flag = 0;
our $nop_flag = 0;

my @vobs;
my @lots;

my @files;
my $recurse_flag = 0;

our %vobhash = (); # vob => 1
our %filehash = (); # file => recursive
our $view_root;

#----------------------------------------------------------------------------------------------

mount_admin_vob();

die "No files specified\n" if $#ARGV == -1;

while (@ARGV)
{
	my $a = $ARGV[0];
	if ($a eq '-f')
	{
		shift;
		@files = read_list(shift);
	}
	elsif ($a eq '-vobs')
	{
		shift;
		@vobs = read_list(shift);
	}
	elsif ($a eq '-vob')
	{
		shift;
		push @vobs, shift;
	}
	elsif ($a eq '-lot')
	{
		shift;
		push @lots, shift;
	}
	elsif ($a eq '-name')
	{
		shift;
		$name = shift;
	}
	elsif ($a eq '-raw')
	{
		shift;
		$raw_flag = 1;
	}
	elsif ($a eq '-replace')
	{
		shift;
		$repl_flag = 1;
	}
	elsif ($a eq '-local')
	{
		shift;
		$local_flag = 1;
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
	else
	{
		last if ! other_options($a);
	}
}

push @files, @ARGV;

mount_admin_vob();

# establish view and working directory
stand_in_the_place();

if (!$name && $#lots == 0)
{
	my $lot = @lots[0];
	$name = "${lot}_" . lot_get_version($lot);
	$raw_flag = 1;
}

die "cannot determine label name.\n" if !$name;
my $label = ($raw_flag ? "" : $ENV{USERNAME} . "_") . $name;

# they're not really conflicting, but it's better not to mix
die "files and vobs/lots specifications are conflicting.\n" if $#files != -1 && ($#vobs != -1 || $#lots != -1);

for my $lot (@lots)
{
	push @vobs, lot_get_vobs($lot);
}

if (! $local_flag)
{
	create_label_type($label, $admin_vob, 1);
}
else
{
	for my $vob (@vobs)
	{
		create_label_type($label, $vob, 0);
	}
}

# process explicit element specification
for my $file (@files)
{
	filehash_add_file($file);
}

for my $vob (@vobs)
{
	filehash_add_vob($vob);
}

put_label($label);

if ($#failed > -1)
{
	print "\nErrors:\n";
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

#----------------------------------------------------------------------------------------------

sub mount_admin_vob
{
	my $mount = new Scaffolds::System("cleartool mount -persistent \\$admin_vob", { log => 0 });
}

#----------------------------------------------------------------------------------------------

sub stand_in_the_place
{
	my $pwv = new Scaffolds::System("cleartool pwv -root -sh", { log => 0 });
	die "cannot determine view.\n" if $pwv->retcode;
	$view_root = $pwv->out(0);
	$view_root =~ /.:\\(.*)/;
	$view = $1;
	$view_root =~ s/\\/\//g;
	
	my $pwd = new Scaffolds::System("cleartool pwd", { log => 0 });
	$rel_pwd = substr($pwd->out(0), length($view_root));
	$rel_pwd =~ s/\\/\//g;
}

#----------------------------------------------------------------------------------------------

sub create_label_type
{
	my ($label, $vob, $global) = @_;
	my $global_opt = $global ? "-global -acquire" : "";
	
	my $desc_type = new Scaffolds::System("cleartool describe -sh lbtype:$label\@/$vob");
	my $lb_exist = ! $desc_type->retcode;

	if (! $lb_exist)
	{
		if (! $nop_flag)
		{
			my $mklbtype = new Scaffolds::System("cleartool mklbtype -nc $global_opt $label\@/$vob");
			push @failed, "label $label in VOB $vob" if $mklbtype->retcode;
		}
		else
		{
			print "cleartool mklbtype -nc $global_opt $label\@/$vob\n";
		}
		print "Created $label in VOB $vob\n";
	}
	else
	{
		print "Label $label exists in VOB $vob: not created.\n";
	}
}

#----------------------------------------------------------------------------------------------

sub put_label
{
	my ($label) = @_;
	
	my $repl = $repl_flag ? "-replace" : "";

	for my $f (keys %filehash)
	{
		my $recurse = $filehash{$f} ? "-r" : "";
		my $file = $f =~ /\// ? "$view_root$f" : $f;
		$file = realpath($file);
		my $mklb_cmd = "cleartool mklabel -nc $repl $recurse lbtype:$label $file";
		if (! $nop_flag)
		{
			my $mklb = new Scaffolds::System($mklb_cmd);
			push @failed, "$label on $f" if $mklb->retcode;
		}
		else
		{
			print "$mklb_cmd\n";
		}
		print "Labeled $f with $label\n";
	}
}

#----------------------------------------------------------------------------------------------

sub lot_get_list
{
	my ($lot, $list) = @_;
	return read_list("$view_root/$lot/Doc/$list");
}

#----------------------------------------------------------------------------------------------

sub lot_get_version
{
	my ($lot) = @_;
	my @list = lot_get_list($lot, "VERSION");
	return $list[0];
}

#----------------------------------------------------------------------------------------------

sub lot_get_vobs
{
	my ($lot) = @_;
	return lot_get_list($lot, "VOBS");
}

#----------------------------------------------------------------------------------------------

sub filehash_add_file
{
	my ($file) = @_;

	$file =~ s/\\/\//g;
	if ($file =~ /.:\/([^\/]*)(\/.*)/)
	{
		# M:/view/vob/...
		my $v = $1;
		my $f = $2;
		die "file '$file' is foriegn to view $view\n" if $v ne $view;
		$filehash{$f} = $recurse_flag;
	}
	elsif ($file =~ /^\//)
	{
		# /vob/...
		$filehash{$file} = $recurse_flag;
	}
	else
	{
		# relative
		$filehash{"$rel_pwd/$file"} = $recurse_flag;
	}
}

#----------------------------------------------------------------------------------------------

sub filehash_add_vob
{
	my ($vob) = @_;
	$filehash{"/$vob"} = 1; # recursive
}

#----------------------------------------------------------------------------------------------

sub print_help
{
	print <<END;
Apply label on elements.

usage:
ct1 label [options]

general options:
    -name <label-name> [-raw]
    [-replace]
    [-n] [-h | -help | -v | -version]

    -name <l>  label type name
    -raw       don't append username prefix to label name
    -replace   replace existing label
    -local     create local label types
    -n         do nothing
    -h         print this message
    -v         print version

vob|lot specification:
    [-vob <vob>|-vobs <file>|-lot <lot>]

    -vob <vob>    place label on specified VOB (repeatable)
    -vobs <file>  place label on VOB names listed in <file> (repeatable)
    -lot <lot>    place label on specified lot (repeatable)

file specifications:
    [-f <file>] files...
    [-r|-recurse]

    -f <file>  applies label on files listed in <file> (repeatable)
    -r         recurse directories
 
END
}
