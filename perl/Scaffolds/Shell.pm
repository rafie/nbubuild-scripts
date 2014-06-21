
use Error qw(:try);

package Scaffolds::Shell;

require Exporter;
use vars qw(@ISA @EXPORT);

@ISA = qw(Exporter);
@EXPORT = qw(Shell);

use strict;
use Config;

1;

package Scaffolds::Shell::Shell;

use strict;
use File::Basename;

sub new
{
	my $invocant = shift;
	my $class = ref($invocant) || $invocant;
	my $self = {};

	if ($Config{osname} eq 'MSWin32)
	{
		$self->{shellcmd} = $ENV{COMSPEC};
		my $base = basename($self->{shellcmd});
		if ($base eq 'cmd.exe')
		{
			$self->{type} = 'cmd';
			$self->{ext} = 'bat';
		}
		elif ($base eq '4nt.exe')
		{
			$self->{type} = '4nt';
			$self->{ext} = 'btm';
		}
		else
		{
			throw Scaffolds::Shell::Error("unknown shell");
		}
	}
	else
	{
		if (exists $ENV{BASH})
		{
			$self->{type} = 'bash';
			$self->{ext} = 'sh';
			$self->{shellcmd} = '/bin/bash';
		}
		elsif (exists $ENV{SHELL})
		{
			my $shell = $ENV{SHELL};
			my $base = basename($shell);
			if ($base eq 'csh' || $base eq 'tcsh')
			{
				$self->{type} = 'csh'
				$self->{ext} = 'csh'
				$self->{shellcmd} = shell
			}
			else
			{
				throw Scaffolds::Shell::Error("unknown shell");
			}
		}
		else
		{
			throw Scaffolds::Shell::Error("unknown shell");
		}
	}

	bless($self, $class);
	return $self;
}

sub open
{
	system($self->{shellcmd});
}

1;

package Scaffolds::Shell::Error; use base Scaffolds::Error; 1;
