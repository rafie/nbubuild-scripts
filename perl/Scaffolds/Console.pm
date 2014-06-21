package Scaffolds::Console;

use strict;
use base 'Exporter';

use Term::ReadKey;

our @EXPORT = qw(read_password ask_Yn ask_yN);

#---------------------------------------------------------------------------------------------- 

sub read_password
{
	my ($prompt) = @_;
	
    my $pwd;
    my $key;
    local $| = 1;  # Turn off STDOUT buffering for immediate response
	print "$prompt: " if $prompt;
#	ReadMode(4); # Change to Raw Mode, disable Ctrl-C
    while (1) 
    {
        while (!defined ($key = ReadKey(-1))) {}
        if (ord($key) == 13 || ord($key) == 10) # if Enter was pressed
        {
            print "\n";
            last;
        }
        print '*';
        $pwd .= $key;
    }
    ReadMode 0; # Reset tty mode before exiting. <==IMPORTANT
    return $pwd; 
}

#---------------------------------------------------------------------------------------------- 

sub ask_Yn
{
	my ($prompt) = @_;
	return _ask("$prompt [Y|n]", "y");
}

sub ask_yN
{
	my ($prompt) = @_;
	return _ask("$prompt [y|N]", "n");
}

sub _ask
{
	my ($prompt, $default) = @_;
	local $| = 1;
	my $answer;
	while (1)
	{
		print "$prompt ";
		chomp($answer = <STDIN>);
		next if !$answer && !$default;
		$answer = $default if !$answer;
		last;
	}
	$answer = lc($answer);
	return substr($answer, 0, 1) eq $default;
}

#---------------------------------------------------------------------------------------------- 

1;
