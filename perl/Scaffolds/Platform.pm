
package Scaffolds::Platform;

use strict;
use Config;
use User::pwent;
use Sys::Hostname;

sub new
{
	my $class = shift;
	
	my $os = $Config{osname};
	my $windows = $os eq 'MSWin32';
	my $sunos = $os eq 'solaris';
	my $linux = $os eq 'linux';
	my @cygwin = $os eq 'cygwin';
	
	my $self = {
		windows => $windows,
		sunos => $sunos,
		linux => $linux,
		cygwin => $cygwin,
		
		win32 => $windows || $cygwin,
		unix => $sunos || $linux,
		posix => $sunos || $linux || $cygwin
		
		$username => getlogin(),
		$hostname => hostname(),
	};

	bless $self, $class;
	return $self;
}
