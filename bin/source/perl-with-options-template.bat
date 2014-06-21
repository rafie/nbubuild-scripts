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

use Scaffolds;

my $help;

my $opt = GetOptions (
	'help|?|h' => \$help,
	) or pod2usage(-exitstatus => 1, -verbose => 99, -sections => "SYNOPSIS|OPTIONS");
pod2usage(-exitstatus => 0, -verbose => 2) if $help;

exit 0;

__END__

=head1 NAME

NAME - DESCRIPTION

=head1 SYNOPSIS

name [options] ...

=head1 OPTIONS

=over 12

=item B<-h|--help>

Print a brief help message and exits.

=cut
