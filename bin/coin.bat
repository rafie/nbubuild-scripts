@rem ='
@echo off
setlocal
call set-nbu-build-env.bat
%NBU_BUILD_PERL%\bin\perl.exe -S %0 %*
exit /b %errorlevel%
@rem ';
#line 9

use strict;
use Archive::Extract;
use File::Basename;
use File::Copy;
use File::Copy::Recursive qw(rcopy);
use File::Path;
use File::Spec;
use Getopt::Long;
use Pod::Usage;
use UUID::Tiny;

use Scaffolds::System;
use Scaffolds::Util;

# line format:
# x/y = x1/y1
# ${x1}/y = ${x2}/y
# x/y = x/y :nox
# /x/y = x1/y1
# d:/x/y = x1/y1
# x/y =* x1/y1
# x/y.zip =* x1/y1
# # comment

our $help = 0;

our $simple;
our $project_name;
our $spec_file = "spec";

# paths
our $from_path;
our $to_path;
our $no_view;
our $root;

# variables
our $print_vars;
our $print_used_vars;
our $no_env;
our $strict;
our %more_vars;

our $view_as_root;
our $view;
our $vroot;

# archive files
our %arc_types = (zip => 1, '7z' => 0, rar => 0, gz => 1, tar => 1, tgz => 1, bz2 => 1, Z => 1);

# diagnostics
our $nop = 0;
our @log = ();
our $context_file;
our $context_line;
our $trap_file = "";
our $trap_line = 0;

my $opt = GetOptions (
	'help|?|h' => \$help,
	'name=s' => \$project_name,
	'simple' => \$simple,
	'spec' => \$spec_file,
	'from|template=s' => \$from_path,
	'to=s' => \$to_path,
	'd=s' => \%more_vars,
	'no-view' => \$no_view,
	'print-vars' => \$print_vars,
	'root=s' => \$root,
	'view-as-root' => \$view_as_root,
	'view=s' => \$view,
	'no-env' => \$no_env,
	'strict' => \$strict,
	'print-used-vars' => \$print_used_vars,
	'n' => \$nop
	) or pod2usage(-exitstatus => 1, -verbose => 99, -sections => "SYNOPSIS|OPTIONS");
pod2usage(-exitstatus => 0, -verbose => 2) if $help;

establish_view();

our %vars = define_system_vars();
@vars{map {lc} keys %more_vars} = values %more_vars;

if ($print_vars)
{
	foreach my $k (keys %vars)
	{
		print "$k\t$vars{$k}\n";
	}
	exit(0);
}

# die "Error: unspecified project name\n" if ! $project_name;

# spec details
our %files = ();
our %flags = ();
our %recursive = ();

if ($simple)
{
	translate_file($from_path, $from_path, $to_path);
}
else
{
	my $spec = "$from_path/$spec_file";
	die "No spec file found. Aborting.\n" if ! -f $spec;
	read_spec($spec);
	process_files();
}

exit($#log > -1 ? 1 : 0);

#----------------------------------------------------------------------------------------------

sub new_uuid
{
	return "{" . create_UUID_as_string() . "}";
}

#----------------------------------------------------------------------------------------------

sub establish_view
{
	die "Error: conflicting --view and --no-view options.\n" if $view && $no_view;
	
	return if $no_view;

	if ($view)
	{
		$vroot = "m:/$view";
	}
	else
	{	
		my $pwv = new Scaffolds::System("cleartool pwv -root -sh", { log => 0 });
		if (! $pwv->retcode)
		{
			$vroot = $pwv->out(0);
			$vroot =~ /.:\\(.*)/;
			$view = $1;
			$vroot =~ s/\\/\//g;
		}
	}

	if ($view_as_root)
	{
		die "Error: conflicting --root and --view-as-root options.\n" if $root;
		$root = $vroot;
	}
}

#----------------------------------------------------------------------------------------------

sub define_system_vars
{
	return ( 
		name => $project_name,
		view => $view,
		vroot => $vroot
		);
}

#----------------------------------------------------------------------------------------------

sub read_spec
{
	my ($spec) = @_;

	open SPEC, "<$spec" or die "Cannot open spec $spec\n";
	$context_file = $spec;
	$context_line = 0;

	while (<SPEC>)
	{
		++$context_line;
		wchomp();
		next if $_ =~ "#.*";
		next if trim($_) eq "";
		
		my $f;
		my $to_f;
		my $flags_s;
		my $recurse = 0;

		if ($_ =~ /\s*("[^"]+")\s*=\*\s*"([^"]+)"\s*(.*)/) # "from" =* "to" [flags]
		{
			$f = expand_vars($1);
			$to_f = expand_vars($2);
			$flags_s = $3;
			$recursive{$f} = 1;
		}
		elsif ($_ =~ /\s*([^=\s]+)\s*=\*\s*(\S+)\s*(.*)/) # from =* to [flags]
		{
			$f = expand_vars($1);
			$to_f = expand_vars($2);
			$flags_s = $3;
			$recursive{$f} = 1;
		}
		elsif ($_ =~ /\s*"([^"]+)"\s*=\s*"([^"]+)"\s*(.*)/) # "from" = "to" [flags]
		{
			$f = expand_vars($1);
			$to_f = expand_vars($2);
			$flags_s = $3;
		}
		elsif ($_ =~ /\s*([^=\s]+)\s*=\s*(\S+)\s*(.*)/) # from = to [flags]
		{
			$f = expand_vars($1);
			$to_f = expand_vars($2);
			$flags_s = $3;
		}
		else
		{
			$_ =~ /\s*(\S+)\s*(.*)/; # from [flags]
			$f = expand_vars($1);
			$to_f = 1;
			$flags_s = $2;
		}

#		if (is_abs_path($to_f))
#		{
#			report("Error: destination path cannot be absolute.");
#			next;
#		}

		$files{$f} = $to_f;
		$flags{$f} = flaghash($flags_s);
	}
	
	close SPEC;
}

#----------------------------------------------------------------------------------------------

sub trim
{
	my ($s) = @_;
	$s =~ s/^\s+|\s+$//g;
	return $s;
}

#----------------------------------------------------------------------------------------------

sub flaghash
{
	my ($s) = @_;
	my @flags = split(/\s/, $s);
	my %h = ();
	for my $x (@flags)
	{
		$h{$x} = 1 if $x;
	}
	return [%h];
}

#----------------------------------------------------------------------------------------------

sub has_flag
{
	my ($file, $flag) = @_;
	my %h = exists $flags{$file} ? @{$flags{$file}} : ();
	return $h{$flag};
}

#----------------------------------------------------------------------------------------------

sub is_abs_path
{
	my ($path) = @_;
	return File::Spec->file_name_is_absolute($path);
}

#----------------------------------------------------------------------------------------------

sub process_files
{
	for my $file (keys %files)
	{
		my $x = $files{$file};
		my $to_file = $x eq 1 ? $file : expand_vars($x);
		process_file($file, $from_path, $to_file, $to_path);
	}
}

#----------------------------------------------------------------------------------------------

sub process_file
{
	my ($file, $from_path, $to_file, $to_path) = @_;

	my $source_path;
	if (is_abs_path($file))
	{
		if (substr($file, 0, 1) eq '/')
		{
			return report("Error: root not specified.") if ! $root;
			$source_path = "$root$file";
		}
		else
		{
			$source_path = $file;
		}
	}
	else
	{
		$source_path = "$from_path/$file";
	}

	my $dest_path;
	if (is_abs_path($to_file))
	{
		$dest_path = $to_file;
	}
	else
	{
		$dest_path = "$to_path/$to_file";
	}

	return report("File $source_path does not exist.") if ! -e $source_path;
	
	if ($recursive{$file})
	{
		$source_path =~ /\.(\w+$)/;
		my $arc_ext = $1;
		my $arc_type = $arc_types{$arc_ext};
		return report("Archive type '$arc_ext' not supported: file $file not extracted.") if $arc_type eq 0;
		if ($arc_type)
		{
			my $type = $arc_type eq 1 ? $arc_ext : $arc_type;
			my $arc = Archive::Extract->new(archive => $source_path, type => $type);
			if (! $arc->extract(to => $dest_path))
			{
				return report("Error extracting '$source_path'");
			}
		}
		else
		{
			if ($nop)
			{
				print "recursively copying $source_path to $dest_path\n";
			}
			else
			{
				if (! rcopy($source_path, $dest_path))
				{
					return report("Deep copy of $file encountered problems.");
				}
				runlock($dest_path);
			}
		}
		return 1;
	}

	my $dest_dir = dirname($dest_path);
	if (! -d $dest_dir)
	{
		$dest_dir = u2w($dest_dir);
		if ($nop)
		{
			print "creating directory " . $dest_dir . "\n";
		}
		else
		{
			mkpath($dest_dir);
		}
	}

	if (! -T $source_path || has_flag($file, ":nox"))
	{
		if ($nop)
		{
			print "copying $source_path to $dest_path\n";
		}
		else
		{
			if (! copy($source_path, $dest_path))
			{
				return report("Copying $file failed.");
			}
			chmod(0666, $dest_path);
		}
		return 1;
	}

	if ($nop)
	{
		print "translating $source_path to $dest_path\n";
		return 1;
	}
	else
	{
		return translate_file($file, $source_path, $dest_path);
	}
}

#----------------------------------------------------------------------------------------------

sub translate_file
{
	my ($file, $source_path, $dest_path) = @_;
	
	if (! open(SOURCE, "<$source_path"))
	{
		return report("Cannot open file $source_path.");
	}
	if (! open(DEST, ">$dest_path"))
	{
		close SOURCE;
	 	return report("Cannot create file $dest_path.");
	}
	
	$context_line = 0;
	$context_file = $file;
	while (<SOURCE>)
	{
		++$context_line;
		if ($file eq $trap_file && $context_line == $trap_line)
		{
			$DB::single = 1;
		}
		print DEST expand_vars($_);
	}
	
	close DEST;
	close SOURCE;
	
	return 1;
}

#----------------------------------------------------------------------------------------------

sub expand_vars
{
	my ($x) = @_;
	# (.*?)        lazy match for anything until ${
	# (?<!\$)\${   match ${ unless preceeded by $
	# (.*?)}       match var}
	# (.*\n?)      match rest of line including optional EOL
	while ($x =~ /(.*?)(?<!\$)\${(.*?)}(.*\n?)/)
	{
		my $var = lc($2);
		if (!exists($vars{$var}) && !exists($ENV{$var}))
		{
			report("Variable '$var' if undefined on $context_file:$context_line.");
		}
		my $y = $vars{$var};
		$y = $ENV{$var} if $y eq "";
		$x = "$1$y$3";
	}
	return $x;
}

#----------------------------------------------------------------------------------------------

sub wchomp
{
	chomp;
	chop if (substr($_, -1, 1) eq "\r");
	return $_;
}

#----------------------------------------------------------------------------------------------

sub report
{
	my ($msg) = @_;
	push @log, $msg;
	die $msg . "\n" if $strict;
	warn $msg . "\n";
	return 0;
}

#----------------------------------------------------------------------------------------------

sub runlock_wanted
{
    chmod 0666, $File::Find::name if ! -d $File::Find::name ;
}

#----------------------------------------------------------------------------------------------

sub runlock
{
	my ($dir) = @_;
	find(\&runlock_wanted, $dir);
}

#----------------------------------------------------------------------------------------------

__END__

=head1 NAME

coin - Generate set of files from a template

=head1 SYNOPSIS

coin [options]

=head1 OPTIONS

=over 12

=item B<--name NAME>

Create file set named NAME.

=item B<--simple>

Translate a single file specified by --from into file specified by --to.

=item B<--spec PATH>

Spec file, containing the list of template files (one per line),
or expressions of the form:
source-path=dest-path
where dest-path can contain variables.
Paths are relative to template root path.
Subdirectories are allowed.

=item B<--from PATH, --template PATH>

Copy template files from PATH.

=item B<--to PATH>

Copy file into destinaton PATH.

=item B<--view VIEW>

Operate on view VIEW.

=item B<--view-as-root>

Consider the root directory to be the view root directory.

=item B<-d VAR=VALUE>

Define variable VAR to VALUE.

=item B<--print-vars>

Print internaly defined variables and exit.

=item B<-h>, B<--help>

Print a brief help message and exits.

=back

=head1 DESCRIPTION

B<This program> will copy a set of files (a template) based on a text 
file (a spec).

=head2 B<Variables>

Variables can be specified using the ${var} syntax, in the spec file as well 
as in the template files.

Environment variables can be used.

Variables are not case sensitive.

Use $${ to get ${ verbatim.

=head2 B<Predefined variables include:>

=over 20

=item B<NAME>

Instance name

=item B<VIEW>

view name

=item B<VROOT>

view root directory (e.g., M:/view)

=cut
