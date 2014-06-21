
use strict;
use File::Temp qw/ :POSIX /;
use File::Basename;

my $lib = shift;
my $appmap = shift;

my $libname = fileparse($lib, ".lib");

my @ign_syms_ = qw/__purecall/;
my %ign_syms;
foreach (@ign_syms_) { $ign_syms{$_} = 1; }

my $start = 0;
my %symbols;
open F, "<$appmap";
while (<F>)
{
	chomp;

	if (! $start)
	{
		next if ! /Publics by Value/;
		$start = 1;
		next;
	}

	next if ! /\s+(\S+)\s+(\S+)\s+(\S+)(.*)\s+(\S+)/;

	my $addr = $1;
	my $sym = $2;
	my $flags = $4;
	my $loc = $5;

	next if ! ($addr =~ /(\S+)\:(\S+)/);
	next if $ign_syms{$sym};
	next if $flags =~ /i/; # inline symbol

	$symbols{$sym} = $loc;
}
close F;

my $dumpbin = $ENV{NBU_BUILD_ROOT} . "\\dev\\tools\\msc\\15.00.30729.01\\bin\\dumpbin.exe";
my $libsyms = tmpnam();
system("$dumpbin /symbols $lib > x1");
system("$dumpbin /symbols $lib | grep \" UNDEF \" | cut -f2 -d\"|\" | cut -f2 -d\" \" | sort -u > $libsyms");

my @ign_libs_ = qw/iphlpapi libcmtd kernel32 libcpmtd ws2_32/;
my %ign_libs;
foreach (@ign_libs_) { $ign_libs{$_} = 1; }
$ign_libs{lc($libname)} = 1;

open F, "<$libsyms";
my %deplibs;
while (<F>)
{
	chomp;
	my $sym = $_;
	my $loc = $symbols{$sym};
	next if $loc eq "";
	$loc =~ /(.*)\:(.*)/;
#	my $lib = $1;
#	my $obj = $2;
	my $lib = $loc;
	next if $ign_libs{lc($lib)};
	$deplibs{$lib} = 1;
}
close F;
unlink $libsyms;

foreach (sort keys %deplibs) { print "$_\n"; }
