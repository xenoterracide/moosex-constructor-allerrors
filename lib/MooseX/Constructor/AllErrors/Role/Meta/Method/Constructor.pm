package MooseX::Constructor::AllErrors::Role::Meta::Method::Constructor;

use Moose::Role;

around _generate_BUILDALL => sub {
  my ($orig, $self, @args) = @_;
  my $source = $self->$orig(@args);

  $source .= ";\n" if $source;

  my @attrs = grep { defined $_->init_arg } @{$self->_attributes};
  my @required = map { "'" . $_->init_arg . "' => 1," }
    grep {
      $_->is_required 
      && ! $_->has_default
      && ! $_->has_builder
    } @attrs
  ;
    
  my @tc = map {
    q{'} . $_->init_arg . q{' => '} . $_->type_constraint->name . q{',}
  } grep {  $_->has_type_constraint } @attrs;

  my @coerce = map { "'" . $_->init_arg . "' => 1," }
    grep { $_->should_coerce } @attrs ;


  $source .= <<"EOF";
my \$all_errors = MooseX::Constructor::AllErrors::Error::Constructor->new(
  caller => [caller(1)],
);
my \%required_attrs = (@required);
for my \$required_attr (keys \%required_attrs) {
  next if exists \$params->{\$required_attr};
  \$all_errors->add_error(
    MooseX::Constructor::AllErrors::Error::Required->new(
      attribute =>
        Moose::Util::find_meta(\$instance)->get_attribute(\$required_attr)
    )
  );
}
my \%tc_attrs = (@tc);
my \%should_coerce = (@coerce);
for my \$tc_attr (keys \%tc_attrs) {
  next unless exists \$params->{\$tc_attr};
  my \$tc = Moose::Util::TypeConstraints::find_type_constraint(\$tc_attrs{\$tc_attr});
  my \$value = \$tc->has_coercion && \$should_coerce{\$tc_attr}
    ? \$tc->coerce(\$params->{\$tc_attr})
    : \$params->{\$tc_attr};
  next if \$tc->check(\$value);
  \$all_errors->add_error(
    MooseX::Constructor::AllErrors::Error::TypeConstraint->new(
      attribute =>
        Moose::Util::find_meta(\$instance)->get_attribute(\$tc_attr),
      data => \$value,
    )
  );
}
if (\$all_errors->has_errors) {
  Moose::Util::find_meta(\$instance)->throw_error(
    \$all_errors,
    params => \$params,
  );
}
EOF

  return $source;
};

no Moose::Role;

1;
