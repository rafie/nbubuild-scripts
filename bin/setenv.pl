
use strict;
use Win32::Console;
use File::Basename;
use File::Find::Rule;
use Log::Log4perl qw(:easy);

sub terminate
{
	exit(1);
}

$SIG{INT} = 'terminate';
$SIG{QUIT} = 'terminate';
$SIG{ABRT} = 'terminate';
$SIG{TERM} = 'terminate';

our $root = $ENV{NBU_BUILD_ROOT} . "/sys/scripts/env";

Log::Log4perl::init($ENV{NBU_BUILD_ROOT} . "/sys/scripts/bin/setenv.log.conf");
Log::Log4perl::MDC->put("user", $ENV{username});
my $logger = get_logger("setenv");
$logger->info("$0 @ARGV");

my $env = shift;
if ($env eq "")
{
	help();
	exit();
}

my $args = join(' ', @ARGV);
my $envpath = "$root/$env";
open (TITLE, "<$envpath/title") or die "$env: invalid environment.\n";
my @title = <TITLE>;
close TITLE;

my $title = $title[0];
my $c = Win32::Console->new(STD_OUTPUT_HANDLE);
my $t = $ENV{ENVSTR};
if ($t eq "")
{
	$t = $title;
}
else
{
	$t .= " : $title";
}
$c->Title($t);
$ENV{ENVSTR} = $t;
if ($ENV{NBU_BUILD_USE_4NT})
{
	exit system("R:\\Mcu_Ngp\\Utilities\\4NT\\8.0\\4nt.exe \@R:\\Build\\usr\\$ENV{USErNAME}\\cfg\\4nt\\8.0\\4nt.ini /k $envpath\\start.bat $args");
}
else
{
	my $cmd = "cmd /k \"" . winpath("$envpath/start.bat");
	$cmd .= " $args" if $args ne "";
	$cmd .=  "\"";
	exit system($cmd);
}

sub help
{
	my %all;
	my $maxlen = 0;
	my @dirs = File::Find::Rule->directory()->mindepth(1)->maxdepth(1)->in($root);
	foreach (sort @dirs)
	{
		if (-d $_)
		{
			my $env = basename($_);
			$all{$env} = title($env);
			my $n = length($env);
			$maxlen = $n if $n > $maxlen;
#			print $env . "\t" . title($env) . "\n";
		}
	}

	print <<END;
Start a new shell session with the selected environment

Usage: se <environment> <args>

Available environments:

END

	foreach my $env (sort keys %all)
	{
		my $n = length($env);
		print $env . " " x ($maxlen - $n + 2) . $all{$env} . "\n";
	}
}

sub title
{
	my $env = shift;
	my $envpath = "$root/$env";
	open (TITLE, "<$envpath/title") or die "$env: invalid environment.\n";
	my @title = <TITLE>;
	close TITLE;
	return $title[0];
}

sub winpath
{
	my $p = shift;
	$p =~ s/\//\\/g;
	return $p;
}

sub uxpath
{
	my $p = shift;
	$p =~ s/\\/\//g;
	return $p;
}
