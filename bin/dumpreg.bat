@rem ='
@echo off
setlocal
call set-nbu-build-env.bat
%NBU_BUILD_PERL%\bin\perl.exe -S %0 %*
exit /b %errorlevel%
@rem ';
#line 9

use strict;
use warnings;

binmode(STDOUT, ":utf8");

use Parse::Win32Registry;
use Getopt::Long;

Getopt::Long::Configure('bundling');

my $debug;
my $quiet;
my $recurse;
my $indent = 0;
GetOptions('debug|d'   => \$debug,
           'quiet|q'   => \$quiet,
           'recurse|r' => \$recurse,
           'indent|i'  => \$indent);

my $filename = shift or die usage();
my $initial_key_name = shift;

my $registry = Parse::Win32Registry->new($filename);
my $root_key = $registry->get_root_key;

if (defined($initial_key_name)) {
    $root_key = $root_key->get_subkey($initial_key_name);
    if (!defined($root_key)) {
        die "Could not locate the key '$initial_key_name' in '$filename'\n";
    }
}

traverse($root_key);

sub traverse {
    my $key = shift;
    my $depth = shift || 0;

    if ($indent) {
        print "  " x ($depth * $indent);
    }
    else {
        print "\n" if !$quiet;
        print $key->get_path, "\n";
    }
	$debug ? $key->print_debug : $key->print_summary;
    
    if (!$recurse) {
        foreach my $subkey ($key->get_list_of_subkeys) {
            print "  " x ($depth * $indent);
            print "= ", $subkey->get_name, " (key)\n";
        }
    }
    
    if (!$quiet) {
        foreach my $value ($key->get_list_of_values) {
            print "  " x ($depth * $indent);
            print "- ";
            $debug ? $value->print_debug : $value->print_summary;
        }
    }
    
    if ($recurse) {
        foreach my $subkey ($key->get_list_of_subkeys) {
            traverse($subkey, $depth + 1);
        }
    }
}

sub usage {
    return <<USAGE;
dumpreg for Parse::Win32Registry $Parse::Win32Registry::VERSION

dumpreg <filename> [subkey] [-r] [-q] [-i] [-d]
    -r or --recurse     traverse all child keys from the root key
                        or the subkey specified
    -q or --quiet       do not display values
    -i or --indent      indent subkeys and values to reflect their
                        level in the registry tree
    -d or --debug       display debugging information about
                        subkeys and values
USAGE
}
