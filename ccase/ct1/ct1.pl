#!/bin/perl

use strict;
use Log::Log4perl qw(:easy);
use Scaffolds::Command;

our $VERSION = "1.0";

my $ct_root = $ENV{NBU_BUILD_ROOT} . "/sys/scripts/ccase/ct1";

Log::Log4perl::init("$ct_root/ct1.log.conf");
Log::Log4perl::MDC->put("user", $ENV{username});
my $logger = get_logger("ct1");
$logger->info("$0 @ARGV");

while (@ARGV)
{
	my $a = $ARGV[0];
	last if ! other_options($a);
}

my $command = shift;
if (!$command || $command eq "help")
{
	my $cmd = shift;
	exit run($cmd, "-h") if $cmd;
	print_help();
	exit;
}

my $args = join("\n", @ARGV);
exit run($command, $args);
 
#----------------------------------------------------------------------------------------------

sub run
{
	my ($cmd, $args) = @_;
	
	my $stem = "$ct_root/ct-${cmd}";
	my $driver;
	my %drivers = (pl => 'perl', rb => 'ruby');
	foreach my $ext (keys %drivers)
	{
		if (-e "$stem.$ext")
		{
			$driver = $drivers{$ext} . " $stem.$ext";
			last;
		}
	}
	die "$cmd: invalid command.\n" if ! $driver;
	system("$driver $args");
	return $? == -1 ? -1 : ($? >> 8); 
}

#----------------------------------------------------------------------------------------------
 
sub print_help
{
	print <<END;
Extended ClearCASE commands

usage:
ct1 [options] command [command-options]

options:
    [-h|-help] [-v|-version]

    -h         print this message
    -v         print version

command: one of the following
    add         Add elements to ClearCASE
    ci          Check-in elements
    co          Check-out elements
    find        Search for elements
    help        Print help
    label       Apply label
    lspri       List private files and checked-out elements
    lstwins     List twins of an elements
    lsviews     List views
    lsvobs      List VOBs
    mkact       Create an activity (branch+view)
    mkbranch    Create branch type
    mkview      Create view
    prop        Show ClearCASE properties dialog
    rmview      Remove view
    tree        Show ClearCASE version tree
    twin        Operation on twin elements
    unregview   Unregister view
    vob         Operations on VOBs
    wakeup      Start ClarCase services and mount VOBs
END
}
