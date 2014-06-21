
package Scaffolds::Command;

use strict;
use base 'Exporter';

our @EXPORT = qw(other_options);

sub other_options
{
	my ($a) = @_;
	
	if ($a eq '-h' || $a eq '-help')
	{
		::print_help();
		exit(1);
	}
	elsif ($a eq '-v' || $a eq '-version')
	{
		print_version();
		exit(1);
	}
	elsif ($a eq '--')
	{
		shift @::ARGV;
		return 0;
	}
	elsif ($a =~ '^-')
	{
		die "$a: invalid argument\n";
	}
	else
	{
		return 0;
	}
	
	return 1;
}

sub print_version
{
	print "$::VERSION\n";
}

1;
