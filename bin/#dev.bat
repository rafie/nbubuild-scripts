@rem ='
@echo off
call set-nbu-build-env.bat
%NBU_BUILD_PERL%\bin\perl.exe -S %0 %*
exit /b %errorlevel%
@rem ';

use strict;
use Getopt::Long;
use Pod::Usage;
use UUID::Tiny;
use File::Basename;
use Cwd;

use Scaffolds::System;

my $broot = $ENV{NBU_BUILD_ROOT};
my $template = "$broot/sys/scripts/#dev";

# my $sharpdev_ver = "4.2.2";
my $sharpdev_ver = "4.3";
my $sharpdev = "$broot/dev/ide/sharp-develop/$sharpdev_ver/bin/SharpDevelop.exe";

our $help = 0;
our $new_project;
our $project_name;
our @args;

my $opt = GetOptions (
	'help|?|h' => \$help,
	'new' => \$new_project,
	'name=s' => \$project_name,
	'<>' => sub { push @args, shift; })
	or pod2usage(-exitstatus => 1, -verbose => 99, -sections => "SYNOPSIS|OPTIONS");
pod2usage(-exitstatus => 0, -verbose => 2) if $help;

my $sol;
if (! $new_project)
{
	my @here = glob("*.sln");
	$sol = shift(@here);
	exit run_sharpdev($sol);
}

my @here = glob("*");
die "Please invoke #dev --new from an empty directory.\n" if $#here != -1;
$project_name = basename(getcwd()) if ! $project_name;

my $new_sln_uuid = new_uuid();
my $new_vcproj_uuid = new_uuid();
my $coin = new Scaffolds::System("coin --name $project_name --template $template --to . -d new_sln_uuid=$new_sln_uuid -d new_vcproj_uuid=$new_vcproj_uuid");
die "Error: cannot create project $project_name.\n" if $coin->retcode;
$sol = "$project_name.sln";

exit run_sharpdev($sol);

sub run_sharpdev
{
	my ($sol) = @_;
	system("start $sharpdev $sol");
	die "error: cannot exeute $sharpdev\n" if $? == -1;
	return $? >> 8; 
}

sub new_uuid
{
	return "{" . create_UUID_as_string() . "}";
}

__END__

=head1 NAME

#dev - Invoke #develop

=head1 SYNOPSIS

#dev [options]

=head1 OPTIONS

=over 12

=item B<--new>

Create a new solution: run from an empty directory.

=item B<--name NAME>

Use/create solution named NAME.

=item B<-h>, B<--help>

Print a brief help message and exits.

=back

=cut
