package MooseX::Constructor::AllErrors::Error::Constructor;

use Moose;

has errors => (
    is => 'ro',
    isa => 'ArrayRef[MooseX::Constructor::AllErrors::Error]',
    auto_deref => 1,
    lazy => 1,
    default => sub { [] },
);

has caller => (
    is => 'ro',
    isa => 'ArrayRef',
    required => 1,
);

sub _errors_by_type {
    my ($self, $type) = @_;
    return [ grep { 
        $_->isa("MooseX::Constructor::AllErrors::Error::$type")
    } $self->errors ];
}

has missing => (
    is => 'ro',
    isa => 'ArrayRef[MooseX::Constructor::AllErrors::Error::Required]',
    auto_deref => 1,
    lazy => 1,
    default => sub { shift->_errors_by_type('Required') },
);

has invalid => (
    is => 'ro',
    isa => 'ArrayRef[MooseX::Constructor::AllErrors::Error::TypeConstraint]',
    auto_deref => 1,
    lazy => 1,
    default => sub { shift->_errors_by_type('TypeConstraint') },
);

sub has_errors {
    return scalar @{ $_[0]->errors };
}

sub add_error {
    my ($self, $error) = @_;
    push @{$self->errors}, $error;
}

sub message {
    my $self = shift;
    confess "$self->message called without any errors"
        unless $self->has_errors;
    return $self->errors->[0]->message;
}

sub stringify {
    my $self = shift;
    return '' unless $self->has_errors;
    return sprintf '%s at %s line %d',
        $self->message,
        $self->caller->[1], $self->caller->[2];
}

use overload (
    q{""} => 'stringify',
    fallback => 1,
);

1;
__END__

=head1 NAME

MooseX::Constructor::AllErrors::Error::Constructor - error class for MooseX::Constructor::AllErrors

=head1 DESCRIPTION

C<$@> will contain an instance of this class when
L<MooseX::Constructor::AllErrors> throws an exception during object
construction.

=head1 METHODS

=head2 has_errors

True if there are any errors.

=head2 add_error

Push a new error to the list (should be an
L<MooseX::Constructor::AllErrors::Error> object).

=head2 message

Returns the first error message found.

=head2 stringify

Returns the first error message found, along with caller information (filename
and line number).

=head2 errors

Returns a list of L<MooseX::Constructor::AllErrors::Error> objects representing
each error that was found.

=head2 missing

Returns a list of L<MooseX::Constructor::AllErrors::Error::Required> objects
representing each missing argument error that was found.

=head2 invalid

Returns a list of L<MooseX::Constructor::AllErrors::Error::TypeConstraint>
objects representing each type constraint error that was found.

=head1 SEE ALSO

L<Moose>

=head1 AUTHOR

  Hans Dieter Pearcey <hdp@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2009 by Hans Dieter Pearcey. This is free
software; you can redistribute it and/or modify it under the same terms as perl
itself. 

=cut
