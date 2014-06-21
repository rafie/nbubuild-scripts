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

my @args;

my $xpath = $ENV{NBU_BUILD_ROOT} . "/sys/libs/perl/bin/xpath";

my $help;

my $opt = GetOptions (
	'help|?' => \$help,
	'<>' => sub { push @args, shift; }) or exit(1);
# or pod2usage(-exitstatus => 1, -verbose => 99, -sections => "SYNOPSIS|OPTIONS");
pod2usage(-exitstatus => 0, -verbose => 2) if $help;

my $xmlfile = shift(@args);
my $query = shift(@args);

exit system("perl $xpath $xmlfile $query");

__END__

=head1 NAME

xpath - Query xml content

=head1 SYNOPSIS

xpath [options] xml-file xpath-query

=head1 OPTIONS

=over 8

=item B<-help>
Print a brief help message and exits.

=back

=head1 DESCRIPTION

B<This program> will read the given input file(s) and do something useful with the contents thereof.

=cut
