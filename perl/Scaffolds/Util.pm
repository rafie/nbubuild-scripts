
package Scaffolds::Util;

use strict;
use File::Temp qw(tmpnam);

require Exporter;
use vars qw(@ISA @EXPORT);

@ISA = qw(Exporter);
@EXPORT = qw(wchomp argshash read_list oneliner read_file write_to_file append_to_file append_file_to_file is_dir_empty w2u u2w is_xp is_x64);

#----------------------------------------------------------------------------------------------

sub wchomp
{
	chomp;
	chop if (substr($_, -1, 1) eq "\r");
	return $_;
}

#----------------------------------------------------------------------------------------------

sub argshash
{
	my ($in, $name) = @_;
	if ($#{$in} == 0)
	{
		return %{$in->[0]} if ref($in->[0]) eq "HASH";
		return ( $name => $in->[0] );
    }
	else
	{
        return @{$in};
    }
}

#----------------------------------------------------------------------------------------------

sub read_list
{
	my ($fname) = @_;
	my @list;
	open F, "$fname" or die "Cannot open file $fname.\n";
	foreach (<F>)
	{
		wchomp;
		next if /^#/;
		push @list, $_;
	}
	close F;
	return @list;
}

#----------------------------------------------------------------------------------------------

sub oneliner
{
	my ($file) = @_;
	open F, "<$file"; 
	my $s = <F>; 
	close $file;
	return $s;
}

#----------------------------------------------------------------------------------------------

sub read_file
{
	my ($file) = @_;
	open F, "<$file" or die "Cannot open file $file.\n";
	my $s = do { local $/; <F> };
	close F;
	return $s;
}

#----------------------------------------------------------------------------------------------

sub write_to_file
{
	my ($file, $text) = @_;
	
	open F, ">$file" or die "Cannot open file $file.\n";
	print F $text;
	close F;
} 

#----------------------------------------------------------------------------------------------

sub append_to_file
{
	my ($file, $text) = @_;
	
	open F, ">>$file" or die "Cannot open file $file.\n";
	print F $text;
	close F;
} 

#----------------------------------------------------------------------------------------------

sub append_file_to_file
{
	my ($to, $from) = @_;
	
	open T, ">>$to"  or die "Cannot open file $to.\n";
	open F, "<$from" or die "Cannot open file $from.\n";
	while (<F>)
	{
		print T $_;
	}
	close F;
	close T;
} 

#----------------------------------------------------------------------------------------------

sub is_dir_empty
{
    my ($dir) = @_;
    opendir(my $dh, $dir) or return 0;
    return scalar(grep { $_ ne "." && $_ ne ".." } readdir($dh)) == 0;
}

#----------------------------------------------------------------------------------------------

sub w2u
{
	my ($f) = @_;
	$f =~ s/\\/\//g;
	return $f;
}

sub u2w
{
	my ($f) = @_;
	$f =~ s/\//\\/g;
	return $f;
}

#----------------------------------------------------------------------------------------------

sub is_xp
{
	my $ver = `ver`;
	return !!($ver =~ /Version 5/);
}

#----------------------------------------------------------------------------------------------

sub is_x64
{
	return !! $ENV{"ProgramFiles(x86)"};
}

#----------------------------------------------------------------------------------------------

1;
