#!/bin/perl

use strict;
use Sys::Hostname;

my $names_flag = 0;
my $all_flag = 0;
my $slots_flag = 0;
my $class;

while (@ARGV)
{
	my $a = $ARGV[0];
	if ($a eq '-names' || $a eq '-n')
	{
		$names_flag = 1;
		shift;
	}
	elsif ($a eq '-all' || $a eq '-a')
	{
		$all_flag = 1;
		shift;
	}
	elsif ($a eq '-slots' || $a eq '-s')
	{
		$slots_flag = 1;
		shift;
	}
	elsif ($a eq '-class' || $a eq '-c')
	{
		shift;
		$class = shift;
	}
	elsif ($a eq '-help' || $a eq '-h')
	{
		print_help();
		exit(0);
	}
	else
	{
		last;
	}
}

my $slots = 0;
my @hosts;
my $localhost = lc(hostname);
my $hosts_file = $ENV{NBU_BUILD_ROOT} . "/cfg/distcc/hosts" . ($class eq "" ? "" : ".$class");
open H, "<$hosts_file" or die "cannot open distcc hosts file";
while (<H>)
{
	wchomp();
	next if ($_ =~ "#.*");
	next if !($_ =~ '([^/]+)/(\d+)');
	my $h = lc($1), my $n = $2;
	next if $h eq $localhost && ! $all_flag;
	$slots += $n;
	if ($names_flag)
	{
		push @hosts, "$h"; 
	}
	else
	{
		push @hosts, "$h/$n";
	}
}
print join(' ', @hosts) . "\n" if ! $slots_flag;
print "$slots\n" if $slots_flag;

sub wchomp
{
	chomp;
	chop if (substr($_, -1, 1) eq "\r");
	return $_;
}

sub print_help
{
	print <<END;
distcc-hosts.pl [-n | -names | -a | -all | -s | -slots]
distcc-hosts.pl [-h | -help]

options:
  -n, -name           print list of host names (without slots)
  -a, -all            include localhost in hosts list
  -s, -slots          print total number of slots instead of hosts list
  -c, -class <CLASS>  print hosts of CLASS
  -h, -help           display this message
END
}
