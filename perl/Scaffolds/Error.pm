
package Scaffolds::Error;

use Error qw(:try);

use base Error::Simple;

sub new
{
	my $invocant = shift;
	my $class = ref($invocant) || $invocant;
    my ($text, $error) = @_;

    local $Error::Depth = $Error::Depth + 1;

    my @stack;
	@stack = @{ $error->{ErrorStack} } if exists $error->{ErrorStack};

	my $self = Error::Simple::new($class, @_);

	push @stack, $error if ref($error) eq "Error::Simple";
	push @stack, $self;
	$self->{ErrorStack} = [ @stack ];

	return $self;
}

sub errorsStack
{
	my ($self) = @_;
	my @errors;
	my @stack = @{ $self->{ErrorStack} };
	foreach my $x (@stack)
	{
		push @errors, $x->file . ":" . $x->line . "\t" . ref($x) . ": " . $x->text;
	}
	return @errors;
}

sub printErrorsStack
{
	my ($self) = @_;
	print join("\n", $self->errorsStack()) . "\n";
}

1;
