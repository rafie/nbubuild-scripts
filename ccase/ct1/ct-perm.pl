#!/bin/perl

use strict;
use Cwd;
use Getopt::Long;
use Pod::Usage;

use Scaffolds::System;
use Scaffolds::Util;
use Win32::TieRegistry;

my $help;
my $user;

my $opt = GetOptions (
	'u|user=s' => \$user,
	'help|?|h' => \$help
	) or pod2usage(-exitstatus => 1, -verbose => 99, -sections => "SYNOPSIS|OPTIONS");
pod2usage(-exitstatus => 0, -verbose => 2) if $help;

$user = $ENV{USERNAME} if ! $user;

my $ccase = $Registry->{q"HKEY_LOCAL_MACHINE\SOFTWARE\Atria\ClearCase\CurrentVersion"} or die "Cannot find ClearCase key in registry\n";
my $host_data = $ccase->{"HostData"} or die "Cannot find ClearCase HostData configuration.\n";
my $creds = "$host_data\\etc\\utils\\creds.exe";
die "Cannot find creds.exe" if ! -e $creds;

system("\"$creds\" -c $user");

exit(0);

__END__

=head1 NAME

ct1 perm - show user permissions

=head1 SYNOPSIS

ct1 perm [options]

=head1 OPTIONS

=over 12

=item B<-u USER> / B<--user USER>

Show USER's permissions.

=item B<-n>

Print commands instead of executing them.

=cut

:end
