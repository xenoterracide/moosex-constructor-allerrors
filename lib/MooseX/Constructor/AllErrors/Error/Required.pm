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
__END__

=head1 NAME

MooseX::Constructor::AllErrors::Error::Required - represents a missing argument error

=head1 DESCRIPTION

This class represents a required constructor argument not being passed in.

=head1 METHODS

=head2 message

Returns a human-readable error message for this error.

=head2 attribute

The L<Moose::Meta::Attribute> object that this error relates to.

=head1 SEE ALSO

L<Moose>

=head1 AUTHOR

  Hans Dieter Pearcey <hdp@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2009 by Hans Dieter Pearcey. This is free
software; you can redistribute it and/or modify it under the same terms as perl
itself. 

=cut
