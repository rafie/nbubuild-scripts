#!/bin/perl

use strict;
use Getopt::Long;
use Pod::Usage;

use Scaffolds::System;

my $help = 0;
my $nop = 0;
my $debug = 0;

my $vsphere = 0;
my $vmware_ws = 0;
my $vbox = 0;

my $opt = GetOptions (
	'help|?|h' => \$help,
	'debug' => \$debug,
	'vsphere' => \$vsphere,
	'ws' => \$vmware_ws,
	'vbox' => \$vbox,
	)
	or pod2usage(-exitstatus => 1, -verbose => 99, -sections => "SYNOPSIS|OPTIONS|COMMANDS");
pod2usage(-exitstatus => 0, -verbose => 2) if $help;

exit 1;
 
#----------------------------------------------------------------------------------------------

__END__

=head1 NAME

vm list - List available Virtual machines

=head1 SYNOPSIS

vm list [options]

=head1 GLOBAL OPTIONS

=over 12

=item B<-h>, B<--help>

Print a brief help message and exits.

=back

=head1 COMMANDS

=over 12

=item B<vsphere>

List vSphere machines.

=item B<ws>

List local VMware Workstation machines.

=item B<vbox>

List local VirtualBox machines.

=item B<help>

Explain given command

=cut

