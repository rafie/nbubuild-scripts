
use strict;
use Scaffolds::Command;

our $VERSION = "1.0.0";

while (@ARGV)
{
	my $a = $ARGV[0];
	last if ! other_options($a);
}

$ENV{COMSPEC} = $ENV{WINDIR} . "\\system32\\cmd.exe";
exit system("start /b cleardescribe @ARGV");

sub print_help
{
	print <<END;
Dispaly ClearCASE properties applet.

ct1 prop <general-options> <element>
ct1 prop [-h | -help | -v | -version]

options:
  (none)

general options:
  -h   print this message
  -v   print version

END
}
