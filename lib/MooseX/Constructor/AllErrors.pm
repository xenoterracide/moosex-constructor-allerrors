package MooseX::Constructor::AllErrors;

use Moose ();
use Moose::Exporter;

use MooseX::Constructor::AllErrors::Error;
use MooseX::Constructor::AllErrors::Error::Constructor;
use MooseX::Constructor::AllErrors::Error::Required;
use MooseX::Constructor::AllErrors::Error::TypeConstraint;

Moose::Exporter->setup_import_methods(
    base_class_roles => [ 'MooseX::Constructor::AllErrors::Role::Object' ],
    class_metaroles => {
        ($Moose::VERSION < 1.9900
            ? (constructor => ['MooseX::Constructor::AllErrors::Role::Meta::Method::Constructor'])
            : (class       => ['MooseX::Constructor::AllErrors::Role::Meta::Class'])),
    },
);

1;

__END__

=head1 NAME

MooseX::Constructor::AllErrors - capture all constructor errors

=head1 SYNOPSIS

  package MyClass;
  use MooseX::Constructor::AllErrors;

  has foo => (is => 'ro', required => 1);
  has bar => (is => 'ro', isa => 'Int');

  ...

  eval { MyClass->new(bar => "hello") };
  # $@->errors has two errors, not just the missing required attribute

=head1 DESCRIPTION

MooseX::Constructor::AllErrors tries to capture every error generated during
the construction of your objects, rather than halting after the first.

If there are errors, C<$@> will contain a
L<MooseX::Constructor::AllErrors::Error::Constructor> object.  See its
documentation for possible error types.

=head1 SEE ALSO

L<Moose>

=head1 AUTHOR

  Hans Dieter Pearcey <hdp@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2009 by Hans Dieter Pearcey. This is free
software; you can redistribute it and/or modify it under the same terms as perl
itself. 

=cut
