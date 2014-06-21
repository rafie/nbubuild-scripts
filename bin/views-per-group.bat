@rem ='
@echo off
setlocal
call set-nbu-build-env.bat
%NBU_BUILD_PERL%\bin\perl.exe -S %0 %*
exit /b %errorlevel%
@rem ';
#line 9

use strict;

use Scaffolds::System;
use Scaffolds::Util;
use Scaffolds::Command;

my @app = qw(
	amib
	amirlev
	anna
	diklak
	erezm
	gidons
	giladl
	moshen
	natanb
	noa
	odeds
	oli
	viktor
	dmytro
	
	orenw
	orubin
	rafie
	rani
	ronnys
	shecht
	tamarg
	tamarma
	vladimir
	yaelp
	
	mcu
	intamcu
	);

my @media = qw(
	avish
	eyals
	eyalsr
	galk
	gury
	itzik
	kathyn
	linora
	maiag
	orenb
	rant
	sashat
	
	mvp
	mpteam
	mp
	);

my @dsp = qw(
	agrinblat
	amis
	anatmi
	ehazan
	emaidman
	eyall
	gilc
	guygar
	iland
	moranad
	ofirb
	stveria
	yaelm
	yoelp
	yossid
	
	dsp-ics-int
	dsp-audio-int
	dsp-video-int
	dspinfra-int
	dspintelinfra
	dspnetrainfra
	dspnetravideo
	);
	
my @cs = qw(
	angelak
	elena
	gregoryl
	markap
	shlomia
	shlomih
	tanir
	yafit
	yuvals
	
	mcucs
	gwint
	gw320int
	);

my @qa = qw(
	avitals
	mosheg
	yaelr
	hernant
	akaras
	qa
	);

my %groups = (
		application => [@app],
		cs => [@cs],
		dsp => [@dsp],
		media => [@media],
		qa => [@qa]
	);

our $show_users;
our $show_user_views;

while (@ARGV)
{
	my $a = $ARGV[0];
	if ($a eq '-users')
	{
		shift;
		$show_users = 1;
	}
	elsif ($a eq '-user-views')
	{
		shift;
		$show_users = 1;
		$show_user_views = 1;
	}
	else
	{
		last if ! other_options($a);
	}
}

my $ct_view = systema("cleartool lsview -sh");
our @views = $ct_view->out;

foreach my $g (sort keys %groups)
{
	count_views($g, $groups{$g});
}

exit(0);

sub count_views
{
	my ($name, $group) = @_;
	
	my $n = 0;
	my %users = ();
	
	foreach my $user (@$group)
	{
		my $pat = qr/^${user}_/i;
		my $c = grep(/$pat/, @views);
		next if !$c;
		$n += $c;
		$users{$user} = $c;
	}
	print "$name: $n\n";
	return if !$show_users;
	
	for my $user (sort keys %users)
	{
		print "\t$user: " . $users{$user} . "\n";
		if ($show_user_views)
		{
			my $pat = qr/^${user}_/i;
			my @user_views = grep(/$pat/, @views);
			foreach (@user_views)
			{
				print "\t\t$_\n";
			}
		}
	}
	print "\n";
}

sub print_help
{
	print <<END;
Show views per group.

usage:
views-per-group [-users] [-h]

options:
  -users     show views per user
  -h         print this message
END
}