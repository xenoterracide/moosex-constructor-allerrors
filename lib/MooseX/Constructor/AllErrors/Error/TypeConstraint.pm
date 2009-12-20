package MooseX::Constructor::AllErrors::Error::TypeConstraint;

use Moose;
extends 'MooseX::Constructor::AllErrors::Error';

has attribute => (
    is => 'ro',
    isa => 'Moose::Meta::Attribute',
    required => 1,
);

has data => (
    is => 'ro',
    required => 1,
);

sub message {
    my $self = shift;
    return sprintf
        'Attribute (%s) does not pass the type constraint because: %s',
        $self->attribute->name,
        $self->attribute->type_constraint->get_message($self->data);
}

1;
