#!/bin/perl

use strict;
use Cwd;
use Getopt::Long;
use Pod::Usage;
use Archive::Zip;
use Archive::Zip::Tree;
  
use Scaffolds::System;
use Scaffolds::Util;

my $help;
my $quiet;
my @views;
my $view;
my $views_file;
my $chin = 1;
my $unchout = 0;
my $unreg = 0;
our $keep_rec;
my $arc;
my $quiet;
my $nop;

my $opt = GetOptions (
	'help|?|h' => \$help,
	'q|quiet' => \$quiet,
	'name=s' => \$view,
	'file=s' => \$views_file,
	'ci' => \$chin,
	'unco' => \$unchout,
	'unreg!' => \$unreg,
	'keep-rec' => \$keep_rec,
	'a|arc!' => \$arc,
	'q|quiet' => \$quiet,
	'n' => \$nop
	) or pod2usage(-exitstatus => 1, -verbose => 99, -sections => "SYNOPSIS|OPTIONS");
pod2usage(-exitstatus => 0, -verbose => 2) if $help;

die "Conflicting options: --ci and --unco.\n" if $chin && $unchout;

push @views, $view if $view;
push @views, read_list($views_file) if $views_file;
push @views, @ARGV;

die "no views specified\n" if $#views < 0;

my $lsviews = systema("cleartool lsview -sh", {log => 0})->ordie;
my %all_views = map { $_ => 1 } $lsviews->out;

my $rc = 1;
foreach my $v (@views)
{
	if (! exists $all_views{$v})
	{
		print "View $v does not exist.\n";
		$rc = 0;
		next;
	}
	$rc = rmview($v) && $rc;
}

exit(!$rc);

sub rmview
{
	my ($view) = @_;

	my $vprops = view_properties($view);
	
	if ($vprops->{snap})
	{
		print "Snapshot view $view not removed.\n";
		return 0;
	}
	
	if ($chin || $unchout)
	{
		if (systema("cleartool startview $view")->failed)
		{
			print "Cannot start view $view\n";
			unregview($view) if $unreg;
			return 1;
		}

		my $dir = getcwd;
		chdir("m:/$view") or die;

		if ($chin)
		{
			if ($nop)
			{
				print "ct1 ci -all\n";
			}
			elsif (systema("ct1 ci -all")->failed)
			{
				print "Cannot check-in elements in view $view\n";
				return 0;
			}
		}
		
		if ($unchout)
		{
			die "unimplemented.\n";
			if (systema("ct1 unco -all")->failed)
			{
				print "Cannot undo checkouts in view $view\n";
				return 0;
			}
		}
		
		chdir($dir);
	}

	if (-d "m:/$view")
	{
		if (systema("cleartool endview -server $view")->failed)
		{
			print "Cannot stop view $view\n";
			return 0;
		}
	}

	if ($arc)
	{
#		print "Creating archive file $arc\n";

		die "Invalid view host path: " . $vprops->{hpath} . "\n" if ! -d $vprops->{hpath};
		
		my $arc_file = "$view.zip";

		if (-e $arc_file)
		{
			print "file $arc_file exists.\n";
			return 0;
		}

		if ($nop)
		{
			print "Creating $arc_file\n";
		}
		else
		{
			my $zip = Archive::Zip->new();
			$zip->addTree($vprops->{hpath});
			$zip->writeToFileNamed($arc_file);
		}
	}
	
	if ($nop)
	{
		print "cleartool rmview -tag $view\n";
	}
	else
	{
		if (systema("cleartool rmview -tag $view")->failed)
		{
			print "Cannot remove view $view.\n";
			unregview($view) if $unreg;
			return 0;
		}

		print "Removed view $view.\n" if ! $quiet;
	}
	
	return 1;
}

sub unregview
{
	my ($view) = @_;

	if (systema("ct1 unregview --name $view")->ok)
	{
		print "Unregistered view $view.\n";
	}
	else
	{
		print "Failed to unregister view $view.\n";
	}
}

sub view_properties
{
	my ($view) = @_;

	my $lsview = systema("cleartool lsview -long $view");
	return {} if $lsview->failed;
	
	if ($keep_rec)
	{	
		write_to_file("${view}.viewrec", $lsview->outText);
		my $catcs = systema("cleartool catcs -tag $view");
		write_to_file("${view}.cspec", $catcs->outText);
	}

	my ($tag, $host, $owner, $snap, $gpath, $hpath, $uuid);
	for my $x ($lsview->out)
	{
		if ($x =~ /^Tag: ([^ ]+)/)
		{
			$tag = $1;
			next;
		}
		
		if ($x =~ /^View on host: (.*)/)
		{
			$host = lc($1);
			next;
		}

		if ($x =~ /^View attributes: (.*)/)
		{
			my $attr = $1;
			$snap = 1 if $attr =~ /snapshot/;
			next;
		}
		
		if ($x =~ /^View owner: (.*)/)
		{
			$owner = $1;
			next;
		}
		
		if ($x =~ /Global path: (.*)/)
		{
			$gpath = $1;
			next;
		}	

		if ($x =~ /^View server access path: (.*)/)
		{
			$hpath = $1;
			next;
		}
		
		if ($x =~ /^View uuid: (.*)/)
		{
			$uuid = $1;
			next;
		}
	}
	return { host => $host, owner => $owner, snap => $snap, gpath => $gpath, hpath => $hpath, uuid => $uuid };
}

__END__

=head1 NAME

rmview - remove views

=head1 SYNOPSIS

ct1 rmview [options] view-names

=head1 OPTIONS

=over 12

=item B<--name NAME>

Remove view named NAME.

=item B<--file FILE>

Read view names from FILE (view per line).

=item B<-q> / B<--quiet>

Don't print messages.

=item B<--ci|--no-ci>

Check-in checked-out elements in view (default).

=item B<--unco|--no-unco>

Unconditionally undo checked-out elements in view.

=item B<--[no-]unreg>

Unregister dead views (one that cannot be started).

=item B<--keep-rec>

Keep view record in file VIEW.viewrec and configspec in file VIEW.cspec.

=item B<--arc>

Create archive file named VIEWNAME.zip.

=item B<-n>

Print commands instead of executing them.

=cut

:end
