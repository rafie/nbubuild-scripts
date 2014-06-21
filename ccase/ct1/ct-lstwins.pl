
use strict;
use File::Basename;
use File::Temp qw/ :POSIX /;
use Scaffolds::System;
use Scaffolds::Util qw(wchomp);
use Scaffolds::Command;

our $VERSION = "1.0";

my $windows = ($^O =~ /MSWin/) ? 1 : 0;
	
my $dir_delim   = $windows ? "\\"   : "/";
my $dir_delim_e = $windows ? "\\\\" : "\/";
my $null        = $windows ? "NUL"  : "/dev/null";


my $list_all_flag = 0;
my $list_ignored_flag = 1;
my $quiet_flag = 0;
my $strict_flag = 0;

while (@ARGV)
{
	my $a = $ARGV[0];
	if ($a eq '-a')
	{
		shift;
		$list_all_flag = 1;
	}
	elsif ($a eq '-i')
	{
		shift;
		$list_ignored_flag = 1;
	}
	elsif ($a eq '-i1')
	{
		shift;
		$list_ignored_flag = 2;
	}
	elsif ($a eq '-q')
	{
		shift;
		$quiet_flag = 1;
	}
	elsif ($a eq '-s')
	{
		shift;
		$strict_flag = 1;
	}
	else
	{
		last if ! other_options($a);
	}
}

die "Nothing to do.\n" if $#ARGV == -1;

my $pname = shift;
	
my ($element_name, $parent) = fileparse ($pname);

if ($parent =~ m/$dir_delim_e\.$dir_delim_e$/) 
{
	$parent =~ s/$dir_delim_e\.$dir_delim_e$/$dir_delim_e/;
}
elsif ($parent =~ m/\\$/) 
{
	$parent .= $dir_delim;
}

my $lsvtree = new Scaffolds::System("cleartool lsvtree -all -s \"$parent\"");
die "cannot query $parent\n" if $lsvtree->retcode;
my @parent_dir_branches = $lsvtree->out;
foreach (@parent_dir_branches)
{
	chomp;
	chop if /\r/;
	$_ .= $dir_delim . $element_name;
}

my @evil_twins;
foreach (@parent_dir_branches) 
{
	my $suspect = $_;

	my %desc = describe_element($suspect);
	next if ! keys %desc;
	
	my $type = $desc{elem_type};
	my $ignore = $desc{IgnoreEvilTwin} && !$strict_flag;

	next if $ignore;

	if (! $list_all_flag)
	{
		print "there are evil twins.\n" if !$quiet_flag;
		exit 1;
	}

	push @evil_twins, $suspect;
	my $ignore_clause = $list_ignored_flag > 1 ? " *" : "";
	print "$suspect$ignore_clause\n" if !$quiet_flag;
}
	
exit $#evil_twins == -1 ? 0 : 1;

#----------------------------------------------------------------------------------------------

sub describe_element
{
	my ($element) = @_;

	my %attrs;

	my $desc = new Scaffolds::System("cleartool describe $element");
	return %attrs if $desc->retcode;

	foreach ($desc->out)
	{
		$attrs{elem_type} = $1 if /element type\: (.*)/;
		$attrs{IgnoreEvilTwin} = $1 if /IgnoreEvilTwin = (.*)/;
	}
	
	return %attrs;
}

#----------------------------------------------------------------------------------------------

sub print_help
{
	print <<END;
Find (evil) twins on a given element.

usage:
ct1 lstwins [-a] [-i] [-m] [-q] [-s] <element>
ct1 lstwins [-h] [-v]

options:
  -q    quiet operation
  -a    list all evil twins
  -i    list ignored elements (those with IgnoreEvilTwin attribute)
  -i1   mark ignored elements with *
  -s    strict mode: do not ignore the ignored
  -h    print this message
  -v    print version
END
}
