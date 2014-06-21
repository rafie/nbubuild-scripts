#!/bin/perl

use strict;
use Cwd;
use Getopt::Long;
use Pod::Usage;

use Scaffolds::System;
use Scaffolds::Util;
use Win32::TieRegistry;

our $host = lc($ENV{COMPUTERNAME});
our $user = $ENV{USERNAME};
our $domain = $ENV{USERDOMAIN};
our $unix_group = "rvccgrp01";

my $help;
my $view;
my $dir;
my $nop;

my $opt = GetOptions (
	'name=s' => \$view,
	'dir=s' => \$dir,
	'n|nop' => \$nop,
	'help|?|h' => \$help
	) or pod2usage(-exitstatus => 1, -verbose => 99, -sections => "SYNOPSIS|OPTIONS");
pod2usage(-exitstatus => 0, -verbose => 2) if $help;

die "Directory $dir does not exist.\n" if ! -d $dir;

my $lsview = systema("cleartool lsview -long $view");
$lsview->ordie("View does not exist. Aborting.");

my $uuid;
foreach ($lsview->out)
{
	$uuid = $1 if $_ =~ /View uuid: (.*)/;
}
die "Cannot determine view UUID\n" if ! $uuid;

my $ccase = $Registry->{q"HKEY_LOCAL_MACHINE\SOFTWARE\Atria\ClearCase\CurrentVersion"} or die "Cannot find ClearCase key in registry\n";
my $host_data = $ccase->{"HostData"} or die "Cannot find ClearCase HostData configuration.\n";
my $fix_prot = "$host_data\\etc\\utils\\fix_prot.exe";
die "Cannot find fix_prot" if ! -e $fix_prot;

my $fix_cmd = "\"$fix_prot\" -force -root -r -chown $domain\\$user -chgrp $domain\\$unix_group $dir";
if (! $nop)
{
	systema($fix_cmd)->ordie("Error changing view files permissions.");
}
else
{
	print "$fix_cmd\n";
}

my $tag = $view;
my $region = "ccav_win";
my $hpath = $dir;
my $gpath = "\\\\$host\\ccstg\\$tag.vws";

my $unreg_cmd = "ct1 unregview -name $tag";
if (! $nop)
{
	systema($unreg_cmd)->ordie("Error unregistering view");
}
else
{
	print "$unreg_cmd\n";
}

# re-registration
my $reg_cmd = "cleartool register -view -host $host -hpath $hpath $hpath";
my $mktag_cmd = "cleartool mktag -view -tag $tag -region $region -host $host -gpath $gpath $hpath";

if (! $nop)
{
	systema($reg_cmd)->ordie("cannot register view.");
	my $mktag = systema($mktag_cmd);
	if ($mktag->retcode)
	{
		systema("cleartool unregister -view $hpath");
		die "cannot create view tag.\n";
	}
}
else
{
	print "$reg_cmd\n";
	print "$mktag_cmd\n";
}

print "View $view fixed.\n";
exit(0);

__END__

=head1 NAME

ct1 fixview - fix view permissions and re-register it

=head1 SYNOPSIS

ct1 fixview [options]

=head1 OPTIONS

=over 12

=item B<-name VIEW>

View name

=item B<-dir DIR>

View storage directory

=item B<-n>

Print commands instead of executing them.

=cut

:end
