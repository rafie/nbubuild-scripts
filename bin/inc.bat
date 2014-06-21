@rem ='
@echo off
setlocal
call set-nbu-build-env.bat
%NBU_BUILD_PERL%\bin\perl.exe -S %0 %*
exit /b %errorlevel%
@rem ';
#line 9

use strict;
use Getopt::Long;
use Pod::Usage;

use Scaffolds::System;

our $help = 0;
our $branch = "";
our $no_ci;
our @args;
our $nop;

my $opt = GetOptions (
	'help|?|h' => \$help,
	'b|branch=s' => \$branch,
	'no-ci' => \$no_ci,
	'n' => \$nop,
	'<>' => sub { push @args, shift; }
	) or pod2usage(-exitstatus => 1, -verbose => 99, -sections => "SYNOPSIS|OPTIONS");
pod2usage(-exitstatus => 0, -verbose => 2) if $help;

foreach my $file (@args)
{
	inc($file) or die "Could not inc $file. Aborting.\n";
}

exit(0);

sub inc
{
	my ($file) = @_;
	if (! -f $file)
	{
		warn "$file not found.\n";
		return 0;
	}

	my $need_ci = 0;
	if (! -w $file)
	{
		if (is_ccase_element($file))
		{
			return 0 if ! checkout_on_branch($file, $branch);
			$need_ci = 1;
		}
		else
		{
			warn "$file is read-only.\n";
			return 0;
		}
	}
	
	my ($s,$n,$d) = read_num($file);
	if ($s < 0)
	{
		warn "Cannot read file $file\n";
		uncheckout($file);
		return 0;
	}

 	$s = sprintf('%.*d', $n, $d);

	if (! $nop)
	{
		open F, ">$file";
		if (! fileno(F))
		{
			warn "Cannot write file $file\n";
			uncheckout($file);
			return 0;
		}
		
		print F $s;
		close F;
	}
	else
	{
		print "$s\n";
	}

	my $rc = 1;
	$rc = checkin($file) if $need_ci && !$no_ci;
	return $rc;
}

sub read_num
{
	my ($file) = @_;

	my $s;
	my $d = 0;
	my $n = 1;

	open F, "<$file";
	return -1 if ! fileno(F);
	
	my $line = <F>;
	if ($line =~ /(\d+)/)
	{
		$s = $1;
		$d = $s + 0;
		$n = length($s);
		++$d;
		my $n1 = length("$d");
		$n = $n1 if $n1 > $n;
	}
	close F;
	return ($s, $n, $d);
}

sub is_ccase_element
{
	my ($file) = @_;
	my $ls = new Scaffolds::System("cleartool ls -vob_only \"$file\"");
	return ! $ls->retcode && scalar($ls->out);
}

sub checkout_on_branch
{
	my ($file, $branch) = @_;
	my $version;
	if (! $branch)
	{
		$version = $file;
	}
	else
	{
		$version = $branch eq "main" ? "$file\@\@/main/LATEST" : "$file\@\@/main/$branch/LATEST";
	}

	my $co = new Scaffolds::System("cleartool co -nc -ptime -version $version");
	warn "Cannot checkout $file\n" if $co->retcode;
	return ! $co->retcode;
}

sub uncheckout
{
	my ($file) = @_;
	return 1 if $nop;
	my $unco = new Scaffolds::System("cleartool unco -rm $file");
	warn "Cannot uncheckout $file\n" if $unco->retcode;
	return ! $unco->retcode;
}

sub checkin
{
	my ($file) = @_;
	return 1 if $nop;
	my $ci = new Scaffolds::System("cleartool ci -nc -ptime -identical $file");
	warn "Cannot check-in $file\n" if $ci->retcode;
	return ! $ci->retcode;
}
