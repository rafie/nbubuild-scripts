
package Scaffolds::XML;

#use strict;
use XML::DOM;
use XML::XPath;
use Attribute::Overload;

use base XML::XPath;

$Scaffolds::XML::xml_dom_parser = new XML::DOM::Parser;

#----------------------------------------------------------------------------------------------

sub save
{
	my ($self) = @_;
	my $fname = $self->get_filename;
	my $text = $self->as_string;
	open XML, ">$fname";
	print XML $text;
	close XML;
}

#----------------------------------------------------------------------------------------------

sub as_string : Overload("")
{
	my ($self) = @_;
	my $decl = $self->xmlDecl;
	my $root = $self->getNodeAsXML("/");
	return "$decl\n$root\n";
}

#----------------------------------------------------------------------------------------------

sub xmlDecl
{
	my ($self) = @_;
	my $xml = $Scaffolds::XML::xml_dom_parser->parsefile($self->get_filename);
	my $p2s = new PrintToString;
	$xml->getXMLDecl->print($p2s);
	scalar $p2s;
}

#----------------------------------------------------------------------------------------------

1;

###############################################################################################

package PrintToString;

use strict;
use Attribute::Overload;

#----------------------------------------------------------------------------------------------

sub new
{
	bless { text => "" }, shift;	
}

#----------------------------------------------------------------------------------------------

sub print
{
	shift->{text} .= join(" ", @_);
}

#----------------------------------------------------------------------------------------------

sub as_string : Overload("")
{
	shift->{text};
}

#----------------------------------------------------------------------------------------------

1;

