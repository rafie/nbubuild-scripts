#!/bin/perl

use strict;

use Getopt::Long;
use Pod::Usage;

use Scaffolds;

my $help;

my $opt = GetOptions (
	'help|?|h' => \$help
	) or pod2usage(-exitstatus => 1, -verbose => 99, -sections => "SYNOPSIS|OPTIONS");
pod2usage(-exitstatus => 0, -verbose => 2) if $help;


systema("net start albd");
systema("net start lockmgr");
systema("net start cccredmgr");

systema("mount-nbu-vobs");

exit(0);

__END__

=head1 NAME

ct1 wakeup - Start ClearCase services and mount VOBs

=head1 SYNOPSIS

ct1 wakeup

=head1 OPTIONS

(none)

=cut

:end
