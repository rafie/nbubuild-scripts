#!/bin/perl

use strict;
use Cwd;
use Scaffolds::System;
use Scaffolds::Util qw(wchomp);

sub terminate
{
	exit(1);
}

$SIG{INT} = 'terminate';
$SIG{QUIT} = 'terminate';
$SIG{ABRT} = 'terminate';
$SIG{TERM} = 'terminate';
#$SIG{__DIE__} = 'terminate';

# make.exe location
my $broot = $ENV{NBU_BUILD_ROOT};

my $pwv = new Scaffolds::System("cleartool pwv -root -sh");
my $from_view = ! $pwv->retcode;
my $vroot;
$vroot = $pwv->out(0) if $from_view;

my $mkpath = $from_view ? "$vroot\\freemasonBuild\\freemason\\4\\bin\\windows" : "$broot\\sys\\util\\bin";
my $make = "$mkpath\\make.exe";

if (! -x $make)
{
	$mkpath = $from_view ? "$vroot\\NBU_BUILD\\freemason\\4\\bin\\windows" : "$broot\\sys\\util\\bin";
	$make = "$mkpath\\make.exe";
}

if (! -x $make)
{
	die "Cannot find make. Check NBU_BUILD_ROOT environment variable.\n" if ! $from_view;
	die "Cannot find make. Check if NBU_BUILD/freemasonBuild VOB is in the current view.\n" if $from_view;
}

exit system("$make --no-print-directory --no-builtin-rules @ARGV");
