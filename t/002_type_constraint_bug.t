#!/usr/bin/env perl
use strict;
use warnings;
use Test::More tests => 3;
use Test::Exception;

{
    use Moose::Util::TypeConstraints;

    subtype 'ShortStr', as 'Str', where { length($_) < 3 };

    no Moose::Util::TypeConstraints;
}

{
    package Foo;
    use Moose;
    use MooseX::Constructor::AllErrors;
    has short_str => (
        is  => 'ro',
        isa => 'ShortStr',
    );
    Foo->meta->make_immutable;
}

{
    package Bar;
    use Moose;
    has short_str => (
        is  => 'ro',
        isa => 'ShortStr',
    );
    Bar->meta->make_immutable;
}

lives_ok{
    Bar->new( short_str => 'a')
} 'Instance of Test Class without MooseX::Constructor::AllErrors lives';

dies_ok{
    Bar->new( short_str => 'aaaaaaaa' );
} '... and dies with incorrect input ( Type Constraint is effective )';

lives_ok{
    Foo->new( short_str => 'a')
} 'Instance of Test Class WITH MooseX::Constructor::AllErrors lives';
