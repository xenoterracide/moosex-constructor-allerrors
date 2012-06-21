package MooseX::Constructor::AllErrors::Error::Misc;

use Moose;
extends 'MooseX::Constructor::AllErrors::Error';

has message => (
    is => 'ro', isa => 'Str',
    required => 1,
);

1;
__END__

=head1 NAME

MooseX::Constructor::AllErrors::Error::Misc - represents a miscellaneous error

=head1 DESCRIPTION

This class represents an error occurring at construction time that cannot be
classified as one of the other error types.  The error message is an arbitrary
string, which describes the nature of the error.

Its creation is a little different than the other error types - it must be
explicitly created by the generating class, usually in either C<BUILDARGS> or
C<BUILD>:

    sub BUILD
    {
        my ($self, $args) = @_;

        my @errors;

        # either foo *or* bar is required
        push @errors, MooseX::Constructor::AllErrors::Misc->new(
            message => 'either \'foo\' or \'bar\' must be provided!',
        ) if not defined $args->{foo} and not defined $args->{bar};

        ...;

        if (@errors)
        {
            my $error = MooseX::Constructor::AllErrors::Error::Constructor->new(
                caller => [ caller(3) ],
            );
            $error->add_error(
                MooseX::Constructor::AllErrors::Error::Misc->new(
                    caller => [ caller(3) ],
                    message => $_,
                )
            ) foreach @errors;

            die $error;
        }
    }

This code is a little long and unwieldy; it is likely that a shortcut will soon
be added. (Stay tuned to upcoming releases!)

=head1 METHODS

=head2 message

Returns a human-readable error message for this error.

=head1 SEE ALSO

L<Moose>

=head1 AUTHOR

  Karen Etheridge <ether@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2009 by Karen Etheridge. This is free
software; you can redistribute it and/or modify it under the same terms as perl
itself.

=cut

