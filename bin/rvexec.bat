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
use Scaffolds::Command;
use Scaffolds::Console;
use Scaffolds::Util;
use Scaffolds::KnownHost;

use Getopt::Long qw(:config require_order);
use Pod::Usage;
use Sys::Hostname;
use File::Basename;
use XML::Simple;

my $root = $ENV{NBU_BUILD_ROOT};
my $putty_root = "$root/sys/scripts/bin/rvputty";
my $linux_pgen = "/users/nbubuild/putty/pgen";
my $plink = "$putty_root/plink.exe";
my $pageant = "$putty_root/pageant.exe";

my $nis_host;

my $help;
my $verbose;
my $telnet;
my $ssh;
my $ask = 0;
my $user;
my $host;
my $port;
my $password;
my $default_target;
my $test_connection = 0;
my $run_pagent;
my $run_putty;
my $nop;
my @args;

my $opt = GetOptions (
	'telnet' => \$telnet,
	'ssh' => \$ssh,
	'tty' => \$run_putty,
	'l|user=s' => \$user,
	'target' => \$default_target,
	'ask!' => \$ask, # accepts --no-ask too
	'P|password=s' => \$password,
	'try!' => \$test_connection, # accepts --no-try too
	'run-agent' => \$run_pagent,
	'verbose' => \$verbose,
	'n|nop' => \$nop,
	'help|?|h' => \$help,
	) or pod2usage(-exitstatus => 1, -verbose => 99, -sections => "SYNOPSIS|OPTIONS");
pod2usage(-exitstatus => 0, -verbose => 2) if $help;

my $user_host_spec = shift;
if ($user_host_spec =~ /^([\w-\.]+)\@([\w-]+)$/)
{
	$user = $1;
	$host = $2;
}
elsif ($user_host_spec =~ /^([\w-]+)$/)
{
	$host = $1;
}
else
{
	die "host not specified.\n";
}

our $cmd = "\"" . join(' ', @ARGV) . "\"";

if ($default_target)
{
	die "Error: host $host is specified. Conflicting with --target.\n" if $host;
	$host = $ENV{RV_TARGET};
}

our $known_host = new Scaffolds::KnownHost($host);
if ($known_host)
{
	$host = $known_host->hostname;
	$user = $known_host->username if ! $user;
	$password = $known_host->password if ! $password;
	$nis_host = 1 if $known_host->NIS;
}

$user = $ENV{username} if ! $user;

our $pageant_cfg_dir = "$root/usr/$user/cfg/pageant";
our $pageant_key_file = "$pageant_cfg_dir/putty.ppk";
our $default_password = "Hello";

# only try connecting to host and executing a simple command
if ($cmd eq '""' && $test_connection)
{
	exit(0) if test_connection($password);
		
	if ($nis_host && $ask)
	{
		generate_pageant_keys();
		exit(0);
	}

	exit(1);
}

my $rc;

if ($password)
{
	$rc = rexecute($cmd);
}
elsif ($nis_host)
{
	$rc = exec_with_pageant();
}
elsif ($ask)
{
	$rc = rexecute($cmd);
}
else
{
	die "Error: don't know how to authenticate.\n";
}

exit($rc);

#----------------------------------------------------------------------------------------------

sub exec_with_pageant
{
	if (-f $pageant_key_file)
	{
		# key file found. check if possible to authenticate with agent.
		#@@ it's possible to check if pageant is running using an named event
		if ($test_connection && !test_connection())
		{
			# possibly, pageant is not running.
			# run agent and try again.
			run_pageant();
		}
	}
	else
	{
		# no key file. will try to craete one.
		generate_pageant_keys();
	}
	
	return execute("$plink -batch -l $user $host $cmd");
}

#----------------------------------------------------------------------------------------------

sub test_connection
{
	my ($password) = @_;
	
	my $pwd_spec;
	$pwd_spec = "-pw $password" if $password;
	my $cmd = new Scaffolds::System("$plink -batch -l $user $pwd_spec $host echo test", { log => ! $password });
	return !($cmd->retcode || $cmd->out0 ne "test");
}

#----------------------------------------------------------------------------------------------

sub generate_pageant_keys
{
	mkdir($pageant_cfg_dir) if ! -d $pageant_cfg_dir;

	# check whether pageant is already running and we have a connection to the linux/nis host
	#@@ this logic is flawed:
	# (1) if pageant is running we should use it to connect and later terminate it
	# (2) if pageant is running and the connection is good, we should connect without password spec
	if (!test_connection())
	{
		# try connecting with the default password
		if (! test_connection($default_password))
		{
			# ask the user for password
			$password = read_password("Enter password for $user: ");
			die "Error: cannot authenticate.\n" if ! test_connection($password);
		}
		else
		{
			$password = $default_password;
		}
	}

	# generate keys: write private key on server and send public key to client
	my $pgen_cmd = new Scaffolds::System("$plink -batch -l $user -pw $password $host $linux_pgen", { log => 0 });
	die "Error: failed to generate keys.\n" if $pgen_cmd->retcode;
	
	open KEY, ">$pageant_key_file" or die "Error: cannot create key file.\n";
	print KEY $pgen_cmd->outText;
	close KEY;
	
	print "key file created.\n";

	run_pageant();
}

#----------------------------------------------------------------------------------------------

sub run_pageant
{
	execute("start $pageant $pageant_key_file");
	sleep(1);
	if (! test_connection())
	{
		sleep(1);
		die "Something is wrong with pageant.\n" if ! test_connection();
	}
}

#----------------------------------------------------------------------------------------------

sub rexecute
{
	my ($cmd) = @_;
	my ($int_spec, $pwd_spec);
	$int_spec = $ask ? "-nobatch" : "-batch";
	$pwd_spec = "-pw $password" if $password;
	return execute("$plink $int_spec -l $user $pwd_spec $host $cmd");
}

#----------------------------------------------------------------------------------------------

sub execute
{
	my ($cmd) = @_;
	if ($nop)
	{
		print "$cmd\n";
		return 0;
	}
	my $rc;
	system($cmd);
	$rc = $? == -1 ? -1 : ($? >> 8);
	return $rc;
}

#----------------------------------------------------------------------------------------------

sub try_execute
{
	my ($cmd) = @_;
	if ($nop)
	{
		print "$cmd\n";
		return 0;
	}
	my $rc;
	system($cmd);
	$rc = $? == -1 ? -1 : ($? >> 8);
	return $rc;
}

#----------------------------------------------------------------------------------------------

__END__

=head1 NAME

rvexec - Remotely execute command

=head1 SYNOPSIS

rvexec [options] [user@]host command

=head1 OPTIONS

=over 12

=item B<--name NAME>

=cut
