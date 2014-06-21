
package Scaffolds::KnownHost;

use strict;
use XML::Simple;

sub new
{
	my $invocant = shift;
	my $class = ref($invocant) || $invocant;

	my ($hostname) = @_; 

	my $root = $ENV{NBU_BUILD_ROOT};

	my $simple = new XML::Simple;
	my $hosts = $simple->XMLin("$root/cfg/hosts/hosts.xml", KeyAttr => { host => "+name" });
	
	my $host = $hosts->{host}->{$hostname};
	return if ! $host;

	my $self = {
		host => $host,
	};

	bless $self, $class;
	return $self;
}

sub name
{
	my ($self) = @_;
	return $self->{host}->{name};
}

sub hostname
{
	my ($self) = @_;
	return $self->{host}->{hostname};
}

sub username
{
	my ($self) = @_;
	return $self->{host}->{username};
}

sub password
{
	my ($self) = @_;
	return $self->{host}->{password};
}

sub auth
{
	my ($self) = @_;
	return $self->{host}->{auth};
}

sub arch
{
	my ($self) = @_;
	return $self->{host}->{arch};
}

sub NIS
{
	my ($self) = @_;
	return $self->{host}->{nis};
}

sub OS
{
	my ($self) = @_;
	return $self->{host}->{os};
}

sub owner
{
	my ($self) = @_;
	return $self->{host}->{owner};
}

sub tags
{
	my ($self) = @_;
	return $self->{host}->{tags};
}

1;
