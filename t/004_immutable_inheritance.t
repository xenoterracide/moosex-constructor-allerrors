
use strict;
use warnings;

{
    package Parent;

    use Moose;
    use MooseX::Constructor::AllErrors;

    our $BUILD = 0;
    sub BUILD
    {
        $BUILD = 1;
    }
}

{
    package Child;

    use Moose;
    extends 'Parent';

    our $BUILD = 0;
    sub BUILD
    {
        $BUILD = 1;
    }
}

use Test::More;
use Test::Moose qw(with_immutable);

with_immutable
{
    $Parent::BUILD = 0;
    $Child::BUILD = 0;

    my $obj = Child->new;

    is($Child::BUILD, 1, "Child's BUILD was run");
    is($Parent::BUILD, 1, "Parent's BUILD was run");
}
qw(Child);

done_testing;
