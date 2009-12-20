package MooseX::Constructor::AllErrors::Error::Required;

use Moose;
extends 'MooseX::Constructor::AllErrors::Error';

has attribute => (
    is => 'ro',
    isa => 'Moose::Meta::Attribute',
    required => 1,
);

sub message {
    my $self = shift;
    return sprintf 'Attribute (%s) is required',
        $self->attribute->name;
}

1;
