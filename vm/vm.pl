#!/bin/perl

# powercli
#	http://www.vmdev.info/?p=202
# vmrun: https://docs.google.com/viewer?a=v&q=cache:56Etq6SrtqkJ:www.vmware.com/pdf/vix160_vmrun_command.pdf+vmrun&hl=en&gl=il&pid=bl&srcid=ADGEESgVYBllsABWNlpMBFvfKFh2ilZKVdydr1A9vWEHfwjwnKXxyFIMjXcjVR_arr_ZPC7mvwZWoPpIgem0vZ4fp_4XoHc62YhHffYRRny1CwheMwiIs8jxuyRMVIAlJ1aX0yIb2CUB&sig=AHIEtbQ1PolFCTo-x9R0MKYrPK5mmjIWsQ
# vboxmanage, vboxtool
# libvirt

use strict;
use Getopt::Long qw(:config require_order);
use Pod::Usage;
use Log::Log4perl qw(:easy);

use Scaffolds::System;

our $VERSION = "1.0";

my $vm_root = $ENV{NBU_BUILD_ROOT} . "/sys/scripts/vm";

Log::Log4perl::init("$vm_root/vm.log.conf");
Log::Log4perl::MDC->put("user", $ENV{username});
my $logger = get_logger("vm");
$logger->info("$0 @ARGV");

my $help = 0;
my $nop = 0;
my $debug = 0;

my $opt = GetOptions (
	'help|?|h' => \$help,
	'debug' => \$debug,
	)
	or pod2usage(-exitstatus => 1, -verbose => 99, -sections => "SYNOPSIS|OPTIONS|COMMANDS");
pod2usage(-exitstatus => 0, -verbose => 2) if $help;

my $command = shift;
if ($command eq "help")
{
	$command = shift;
	exit run($command, "-h") if $command;
	pod2usage(-exitstatus => 0, -verbose => 2);
	exit;
}

my $args = join("\n", @ARGV);
exit run($command, $args);
 
#----------------------------------------------------------------------------------------------

sub run
{
	my ($cmd, $args) = @_;
	
	my $stem = "$vm_root/${cmd}";
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
	return system("$driver $args");
}

#----------------------------------------------------------------------------------------------
 
__END__

=head1 NAME

vm - Virtual machine operations

=head1 SYNOPSIS

vm [global options] command [options]

=head1 GLOBAL OPTIONS

=over 12

=item B<-h>, B<--help>

Print a brief help message and exits.

=back

=head1 COMMANDS

=over 12

=item B<create>

Create a new virtual machine

=item B<list>

List available virtual machines

=item B<start>

Start a virtual machine

=item B<stop>

Stop a virtual machine

=item B<suspend>

Suspend a virtual machine

=item B<resume>

Resme a virtual machine

=item B<move>

Move (migrage) a virtual machine between two servers

=item B<help>

Explain given command

=cut

