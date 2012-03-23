package MooseX::Constructor::AllErrors::Role::Object;

use Moose::Role;
use Try::Tiny;

my $new_error = sub { 
  my $class = shift;
  return "MooseX::Constructor::AllErrors::Error::$class"->new(@_);
};

around BUILDARGS => sub {
  my ($orig, $self, @args) = @_;

  my $args = $self->$orig(@args);

  my $error = $new_error->(Constructor => {
    caller => [ caller(3) ],
  });

  my $meta = Moose::Util::find_meta($self);
  for my $attr (sort { $a->insertion_order <=> $b->insertion_order } $meta->get_all_attributes) {
    next unless defined( my $init_arg = $attr->init_arg );

    if ($attr->is_required and 
      ! $attr->is_lazy and
      ! $attr->has_default and
      ! $attr->has_builder and
      ! exists $args->{$init_arg}) {
      $error->add_error($new_error->(Required => { attribute => $attr }));
      next;
    }

    next unless exists $args->{$init_arg} && $attr->has_type_constraint;

    my $tc = $attr->type_constraint;
    my $value = $tc->has_coercion && $attr->should_coerce
        ? $tc->coerce($args->{$init_arg})
        : $args->{$init_arg};

    # use the attributes verify_against_type_constraint as that can be wrapped
    # by other roles, namely MooseX::UndefTolerant
    try {
      $attr->verify_against_type_constraint($value);
    }
    catch {
      $error->add_error($new_error->(TypeConstraint => {
        attribute => $attr,
        data      => $value,
      }));
    };
  }

  if ($error->has_errors) {
    $meta->throw_error($error, params => $args);
  }

  return $args;
};

1;
