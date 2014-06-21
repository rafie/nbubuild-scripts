
use strict;
use File::Temp qw/ :POSIX /;
use File::Slurp;

use Scaffolds::System;
use Scaffolds::Command;

our $VERSION = "1.0.0";

my $name;
my $raw_flag = 0;
my $dyn_flag = 1;
my $nop_flag = 0;
my $on_server_flag = 0;
my $spec_flag = 0;
my $ext_spec_fname;
my $user = $ENV{USERNAME};

while (@ARGV)
{
	my $a = $ARGV[0];
	if ($a eq '-name')
	{
		shift;
		$name = shift;
	}
	elsif ($a eq '-raw')
	{
		shift;
		$raw_flag = 1;
	}
	elsif ($a eq '-dyn' || $a eq '-dynamic')
	{
		shift;
		$dyn_flag = 1;
	}
	elsif ($a eq '-snap' || $a eq '-snapshot')
	{
		shift;
		$dyn_flag = 0;
		die "Snapshot views are not supported.\n";
	}
	elsif ($a eq '-server')
	{
		shift;
		$on_server_flag = 1;
	}
	elsif ($a eq '-spec')
	{
		shift;
		$ext_spec_fname = shift;
		$spec_flag = 1;
	}
	elsif ($a eq '-n')
	{
		shift;
		$nop_flag = 1;
	}
	else
	{
		last if ! other_options($a);
	}
}

die "error: activity name not specified.\n" if ! $name;
my $tag = ($raw_flag ? "" : $user . "_") . $name;

die "error: invalid configspec.\n" if $spec_flag && ! -f $ext_spec_fname;
my $ext_spec;
if ($spec_flag)
{
	$ext_spec = read_file($ext_spec_fname) or die "cannot read configspec.\n";
}

my $mkbranch_cmd = "ct1 mkbranch -name $name -short " . 
	($raw_flag ? "-raw " : "") .
	($nop_flag ? "-n " : "");
my $mkbranch = new Scaffolds::System($mkbranch_cmd);
die "cannot create branch.\n" if $mkbranch->retcode;
my $branch = $mkbranch->out(0);
print "Created branch $branch.\n";

my $spec = 	<<END;
element * CHECKEDOUT

element * .../$branch/LATEST
mkbranch $branch
$ext_spec

element * /main/0
end mkbranch

END

my $spec_filename = tmpnam();
write_file($spec_filename, $spec);

my $mkview_cmd = "ct1 mkview -name $name -spec $spec_filename " . 
	($raw_flag ? "-raw " : "") .
	($on_server_flag ? "-server " : "") .
	($nop_flag ? "-n " : "");
my $mkview = new Scaffolds::System($mkview_cmd);
die "cannot create view.\n" if $mkview->retcode;
unlink $spec_filename;
print "Created view $tag.\n";

print "Created activity $tag.\n";

#----------------------------------------------------------------------------------------------

sub print_help
{
	print <<END;
Create an activity (branch+view).

usage:
ct1 mkact [-name <name>] [-raw] [-spec <file>] [-dynamic | -snapshot] [-server] [-n]
ct1 mkact [-h | -help | -v | -version]

options:
  -name <name>  view name
  -raw          don't add username prefix to view name
  -spec <file>  configspec file
  -dynamic      create dynamic view (default)
  -snapshot     create snapshot view
  -server       create view on server (rvil-ccview) [*]
  -n            do nothing, just print commands
  -h            print this message
  -v            print version

[*] Creating a view on the server requires one to enter their password.
    It is possible to automate the process and aviod the password prompt.
    For more information, search http://nbuwiki for ct1 mkview.
END
}
