use strict;
use warnings;
use Test::More tests => 38;

{
    package Foo;
    
    use Moose;
    use MooseX::Constructor::AllErrors;

    has bar => (
        is => 'ro',
        required => 1,
    );

    has baz => (
        is => 'ro',
        isa => 'Int',
    );

    has quux => (
        is => 'ro',
        trigger => sub { my ($x, $y) = (1, 0); $x / $y; },
    );

    has bletch => (
        is => 'ro', isa => 'Int'
    );

    sub BUILD
    {
        my $this = shift;
        $this->bletch($this->baz) if $this->baz;
    }

    no Moose;
    no MooseX::Constructor::AllErrors;
}

sub tests {
    my $foo = eval { Foo->new(bar => 1) };
    is($@, '');
    isa_ok($foo, 'Foo');

    eval { Foo->new(baz => "hello") };
    my $e = $@;
    my $t;
    isa_ok($e, 'MooseX::Constructor::AllErrors::Error::Constructor');
    isa_ok($t = $e->errors->[0], 'MooseX::Constructor::AllErrors::Error::Required');
    is($t->attribute, Foo->meta->get_attribute('bar'));
    is($t->message, 'Attribute (bar) is required');
    isa_ok($t = $e->errors->[1], 'MooseX::Constructor::AllErrors::Error::TypeConstraint');
    is($t->attribute, Foo->meta->get_attribute('baz'));
    is($t->data, 'hello');
    like($t->message,
        qr/^\QAttribute (baz) does not pass the type constraint because: Validation failed for 'Int' with value \E.*hello.*/
    );

    TODO: {
        local $TODO = 'BUILD errors are not yet caught';
        isa_ok($t = $e->errors->[2], 'MooseX::Constructor::AllErrors::Error::TypeConstraint') or todo_skip 'doh', 3;
        is($t->attribute, Foo->meta->get_attribute('bletch'));
        is($t->data, 'hello');
        like($t->message,
            qr/\QAttribute (bletch) does not pass the type constraint because: Validation failed for 'Int' with value \E.*hello.*/
        );
    }

    is(
        $e->message,
        $e->errors->[0]->message,
        "message is first error's message",
    );

    is_deeply(
        [ map { $_->attribute->name } $e->missing ],
        [ 'bar' ],
        'correct missing',
    );

    is_deeply(
        [ map { $_->attribute->name } $e->invalid ],
        [ 'baz' ],
        'correct invalid',
    );

    my $pattern = "\QAttribute (bar) is required at \E" . __FILE__ . " line \\d{2}";
    like("$e", qr/$pattern/);

    eval { Foo->new(bar => 1, quux => 1) };
    like $@, qr/Illegal division by zero/, "unrecognized error rethrown";
};

tests();
Foo->meta->make_immutable;
tests();

