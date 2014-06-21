#!/bin/perl

use strict;
use Cwd;
use Getopt::Long;
use Pod::Usage;

use Scaffolds::System;
use Scaffolds::Util;

our $help;
our $quiet;
our $nop;

my $view;
my $views_file;
our $keep_rec = 0;
#my $raw;

my $opt = GetOptions (
	'help|?|h' => \$help,
	'q|quiet' => \$quiet,
	'name=s' => \$view,
	'file=s' => \$views_file,
	'keeprec' => \$keep_rec,
#	'raw' => \$raw,
	'n' => \$nop
	) or pod2usage(-exitstatus => 1, -verbose => 99, -sections => "SYNOPSIS|OPTIONS");
pod2usage(-exitstatus => 0, -verbose => 2) if $help;

my @views;
@views = read_list($views_file) if $views_file;
push @views, $view if $view;

foreach my $v (@views)
{
	unreg_view($v);
}

exit(0);

#----------------------------------------------------------------------------------------------

sub unreg_view
{
	my ($view) = @_;
	
	my $lsview = systema("cleartool lsview -long $view");
	if ($lsview->failed)
	{
		print "View $view does not exist.\n";
		return;
	}

	if ($nop)
	{
		write_to_file("${view}.viewrec", $lsview->outText) if $keep_rec;
	}
	else
	{
		print "Wrote view record into ${view}.viewrec\n" if $keep_rec;
	}

	my ($uuid, $host, $gpath, $hpath);
	foreach ($lsview->out)
	{
		$uuid = $1 if $_ =~ /View uuid: (.*)/;
		$uuid = $1 if ! $uuid && ($_ =~ /View tag uuid:(.*)/);
		$host = $1 if $_ =~ /Server host: (.*)/;
		$gpath = $1 if $_ =~ /Global path: (.*)/;
		$hpath = $1 if $_ =~ /View server access path: (.*)/;
	}
	die "Cannot determine view UUID\n" if ! $uuid;
#	die "Cannot determine view host\n" if ! $host;
#	die "Cannot determine view global path\n" if ! $gpath;
#	die "Cannot determine view host path\n" if ! $hpath;
	
	if ($nop)
	{
		print "cleartool unregister -view -uuid $uuid\n";
		print "cleartool rmtag -all -view $view\n";
	}
	else
	{
		my $unreg = systema("cleartool unregister -view -uuid $uuid");
#		$unreg->ordie("Cannot unregister view");
		my $rmtag = systema("cleartool rmtag -all -view $view");
#		if ($rmtag->retcode && $hpath && $host && $gpath)
#		{
#			my $reg = systema("cleartool register -view -host $host -hpath $hpath $gpath");
#			warn "Cannot re-register view\n" if $reg->retcode;
#			die "Cannot remove tag of view\n" if $rmtag->retcode;
#		}
	}
	
	print "Unregistered view $view\n" if ! $quiet;
}

#----------------------------------------------------------------------------------------------

sub print_help
{
	print <<END;
Unregisters view from ClearCASE server.
This can be used to get rid of non-existant views, or to relocate view\'s storage.
To remove an existing view, use ct1 rmview.

usage:
ct1 unregview -name <view> [ -vspec <spec-file> ]
ct1 unregview [-h | -help | -v | -version]

options:
  -name <view>   remove view named <view>
  -vspec <file>  write view spec into <file>
END
}

#----------------------------------------------------------------------------------------------

__END__

=head1 NAME

unregview - Unregisters view from ClearCASE and remove its tag.

=head1 SYNOPSIS

ct1 rmview [options]

=head1 OPTIONS

=over 12

=item B<--name NAME>

Remove view named NAME.

=item B<--file FILE>

Take view names from file FILE.

=item B<--keeprec>

Save view record in .

=item B<-q> / B<--quiet>

Don't print messages.

=item B<-n>

Print commands instead of executing them.

=cut

:end
