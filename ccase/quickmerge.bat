@rem ='
@echo off
ccperl %0 %*
exit /b %errorlevel%
@rem ';

# quickmerge.pl args new-file old-file

my $base;
my $out;
my $src;
my $dest;
my $common = 0;
my $f1 = 0;
my $f2 = 0;
my $filter = "-+ ";
my $diff = 0;

while (@ARGV)
{
	my $a = $ARGV[0];
	if ($a eq '-base')
	{
		shift;
		$base = shift;
	}
	elsif ($a eq '-out')
	{
		shift;
		$out = shift;
	}
	elsif ($a eq '-diff')
	{
		shift;
		$diff = 1;
	}
	elsif ($a eq '-common')
	{
		shift;
		$common = 1;
	}
	elsif ($a eq '-1')
	{
		shift;
		$f1 = 1;
	}
	elsif ($a eq '-2')
	{
		shift;
		$f2 = 1;
	}
	else
	{
		last;
	}
}

$src = shift;
$dest = shift;

if ($common || $f1 || $f2)
{
	$filter = "";
	$filter .= " " if $common;
	$filter .= "+" if $f1; # 1st file is considered "new"
	$filter .= "-" if $f2; # 2nd find is considered "old"
}

my $OUT;
if ($out)
{
	open OFILE, ">$out" if $out or die "invalid file: '$out'";
 	$OUT = \*OFILE;
}
else
{
	$OUT = \*STDOUT;
}

my @x = `diff -U 1000 $dest $src`;

if ($diff)
{
	print join("", @x);
	exit(0);
}

my $head = 1;
foreach (@x)
{
	if ($head)
	{
		$head = 0 if $_ =~ /^@@/;
	}
	else
	{
		my $h = substr($_, 0, 1);
		my $x = substr($_, 1);
		print $OUT $x if index($filter, $h) != -1;
	}
}

close OFILE if $out;
exit 0;
