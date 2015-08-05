package PA::Predicate;

use strict;
use warnings;

use Moose;
use Assert::Conditional qw(:all -if 1);
use PA                  qw(:constants );
use namespace::autoclean;
use Carp;
use Scalar::Util  qw(reftype);
use Params::Util  qw(_STRING _NUMBER _HASH0 _HASH _ARRAY0 _ARRAY);

#
# A mapping from a predicate key to the type specific parsing routine.  Any
# change to the set of possible initial keys must bupdate these data structures
# as well as pred_evaluate();
#
my $parse_funcs =
{
  lt  => \&pred_validate_rel,
  le  => \&pred_validate_rel,
  gt  => \&pred_validate_rel,
  ge  => \&pred_validate_rel,
  eq  => \&pred_validate_rel,
  ne  => \&pred_validate_rel,
  and => \&pred_validate_log,
  or  => \&pred_validate_log,
};

# A mapping that determines which specific instrumentation fields are supported
# by which predicate relational and logical operators.
# TODO: populate using keys defined in PA
my $key_fields =
{
  lt  => {},
  le  => {},
  gt  => {},
  ge  => {},
  eq  => {},
  ne  => {},
};

#
# A mapping to the operator specific printing routines.
#
my $print_funcs =
{
  lt    => \&pred_print_rel,
  le    => \&pred_print_rel,
  gt    => \&pred_print_rel,
  ge    => \&pred_print_rel,
  eq    => \&pred_print_rel,
  ne    => \&pred_print_rel,
  and   => \&pred_print_log,
  or    => \&pred_print_log,
};

#
# the operator specific string to use while printing
#
my $print_strings =
{
  lt    => '<',
  le    => '<=',
  gt    => '>',
  ge    => '>=',
  eq    => '==',
  ne    => '!=',
  and   => '&&',
  or    => '||',
};


my $pred_eval_helpers =
{
  lt => sub { my ($a, $b) = @_; return ($a <  $b); },
  le => sub { my ($a, $b) = @_; return ($a <= $b); },
  gt => sub { my ($a, $b) = @_; return ($a >  $b); },
  ge => sub { my ($a, $b) = @_; return ($a >= $b); },
  eq => sub { my ($a, $b) = @_; return ($a == $b); },
  ne => sub { my ($a, $b) = @_; return ($a != $b); },
};

#
# Gets the key for the given predicate
#
# Input:
# - pred: The predicate to get the key for
# Output
# = Returns the key for the specified predicate object
#
sub pred_get_key {
  my ($self, $pred) = @_;
  my ($keys_found,$key);

  foreach my $val (keys %$pred) {
    $keys_found++;
    $key = $val;
  }

  if ($keys_found > 1) {
    my $msg =
    sprintf("predicate $pred found too many keys: %d. Expected one.",
            $keys_found);
    die $msg;
  }
  if ($keys_found < 1) {
    my $msg =
    sprintf("predicate $pred predicate is missing a key");
    die $msg;
  }

  return $key;
}

#
# Validates that the predicate has a valid format for relational predicates.
# This means that it fits the format:
# { key => [ field, constant ] }
#
# Input:
# - pred: The predicate hashref
# - key: The key that we're interested in
#
# On return the following points have been validated:
# - That the key points to a two element array ref
# - That the first field of the array ref is a valid type
#
sub pred_validate_rel {
  my ($self, $pred, $key) = @_;

  my ($field, $constant, $msg);

  if (not exists($pred->{$key})) {
    $msg = sprintf("predicate is missing key %s", $key);
    confess($msg);
  }

  if (not defined($pred->{$key}) &&
      not reftype($pred->{$key}) eq "ARRAY") {
    $msg = "predicate key does not point to an arrayref";
    confess($msg);
  }

  if (not ((my $elem_count = scalar(@{$pred->{$key}})) == 2)) {
    $msg =
      sprintf("predicate key does not point to an arrayref of two" .
              " elements: found %d elements instead", $elem_count);
    confess($msg);
  }

  $field = $pred->{$key}->[0];
  $constant = $pred->{$key}->[1];

  if (not _STRING( $field ) ) {
    $msg = sprintf("predicate field is not a string: got %s",$field);
    confess($msg);
  }

  if (not _NUMBER( $constant ) &&
      not _STRING( $constant ) ) {
    $msg = sprintf("predicate constant is not a constant: got %s",
                   $constant);
    confess($msg);
  }
}

# This function assumes that we have a syntactically valid object and the
# caller has already established that the only fields present are fields which
# are "valid". We now go through and do checks to validate that fields are used
# appropriately given their arities (as specified in "fieldarities").
# 
#  Input:
#   - fieldarities: valid fields for the metric and their arities
#   - pred: The relational predicate to validate
#   - key: The key that we are interested in validating
# 
sub pred_validate_field {
  my ($self, $fieldarities, $pred, $key) = @_;

  my ($field, $constant, $arity, $msg);

  $field    = $pred->{$key}->[0];
  $constant = $pred->{$key}->[1];

  assert_in_list( $field, @$fieldarities );
  $arity = $fieldarities->{$field};
  assert_in_list( $arity, @{$key_fields->{$key}} );

  if ($arity eq $PA::field_arity_numeric &&
      not _NUMBER( $constant )) {
    $msg = sprintf("predicate field is of type numeric, but the constant " .
                   "is not a number: got type %s", reftype( $constant ));
    confess( $msg );
  }

  if ($arity ne $PA::field_arity_numeric &&
      not _STRING( $constant )) {
    $msg = sprintf("predicate field is of type discrete, but the " .
                   "constant is not a string: got type %s",
                   reftype( $constant ));
    confess( $msg );
  }
}

# This function assumes that we have a syntactically valid object and the
# caller has already established that the only fields present are fields which
# are "valid". We now go through and do checks to validate that fields are used
# appropriately given their arities (as specified in "fieldarities").
# 
#  Input:
#   - fieldarities: valid fields for the metric and their arities
#   - pred: The relational predicate to validate
#   - key: The key that we are interested in validating

sub pred_validate_log {
  my ($self, $pred, $key) = @_;

  my ($msg);

  if (not exists($pred->{$key})) {
    $msg = sprintf("logical expression is missing key %s", $key);
    confess($msg);
  }

  if (not defined($pred->{$key}) &&
      not reftype($pred->{$key}) eq "ARRAY") {
    $msg = "logical expression key does not point to an arrayref";
    confess($msg);
  }

  if (not ((my $elem_count = scalar(@{$pred->{$key}})) == 2)) {
    $msg =
      sprintf("logical expression key does not contain enough " .
              "elements: found %d elements instead", $elem_count);
    confess($msg);
  }

  foreach my $ii (@{$pred->{$key}}) {
    # will simply die if validation fails, silently proceeds otherwise
    $self->pred_validate_syntax($pred->{$key}->[$ii]);
  }
}

#
# This is the entry point for validating and parsing any given predicate. This
# will be called when beginning to parse any specific predicate.
# 
# Input:
#  - pred: The predicate that we want to validate
# 
# Output: None on success, an exception is thrown on error.
#

sub pred_validate_syntax {
  my ($self, $pred) = @_;

  my ($key, $msg);

  if (not _HASH( $pred ) ) {
    $msg = sprintf("predicate must be a hashref");
    confess( $msg );
  }

  if (not $self->pred_non_trivial( $pred ) ) {
    return;  # undef
  }

  $key = $self->pred_get_key( $pred );

  if (not any { $_ eq $key } keys %$parse_funcs) {
    $msg = sprintf("invalid key: %s", $key);
    confess( $msg );
  }

  $parse_funcs->{$key}->($self, $pred, $key);
}

# We want to walk every leaf predicate and apply a function to it
# Input:
#  - func: A function of the signature void (*func)(predicate, key)
#  - pred: A predicate that has previously been validated
# 

sub pred_walk {
  my ($self, $func, $pred) = @_;

  my ($key);

  if (not $self->pred_non_trivial($pred)) {
    return;  #undef
  }

  $key = $self->pred_get_key( $pred );

  if ( ($key eq "and") or ($key eq "or") ) {
    foreach my $ii ( @{$pred->{$key}} ) {
      $self->pred_walk( $func, $pred->{$key}->[$ii] );
    }
  } else {
    $func->($self, $pred, $key);
  }
}

# Validates the semantic properties of the predicate. This includes making sure
# that every field is valid for the predicate and the values present match the
# expected arity.
#
sub pred_validate_semantics {
  my ($self, $fieldarities, $pred) = @_;

  my $func =
    sub { my ($ent, $key) = @_;
          return pred_validate_field($self, $fieldarities, $ent, $key);
        };

  $self->pred_walk($func, $pred);
}

# Prints out the value of a relational predicate.
# This should print as:
# <field> <operator> <constant>
# 
# Input:
#  - pred: The predicate to print
#  - key: The key for the predicate
# 
# Output:
#  - Returns the string representation of the specified predicate.
#

sub pred_print_rel {
  my ($self, $pred, $key) = @_;

  my ($out) = $pred->{$key}->[0] . ' ';

  $out .= $print_strings->{$key} . ' ';

  if (_STRING( $pred->{$key}->[1] )) {
    $out .= '"';
  }
  $out .= $pred->{$key}->[1];
  if (_STRING( $pred->{$key}->[1] )) {
    $out .= '"';
  }
  return $out;
}

# Prints out the value of a logical expression.
# This should print as:
# (<predicate>) <operator> (<predicate>)...
# 
# The parens may seem unnecessary in most cases, but it is designed to
# distinguish between nested logical expressions.
# 
# Inputs:
#  - pred: The logical expression to print
#  - key: The key for the object in the logical expression
# 
# Output:
#  - Returns the string representation of the specified predicate.
#
sub pred_print_log {
  my ($self, $pred, $key) = @_;

  my @elts = map { my $elt = '(' . $self->pred_print_gen( $_ ) . ')';
                   $elt;
                 } @{$pred->{$key}};

  my $ret = join(' ' . $self->print_strings->{$key} . ' ', @elts);

  say "pred_print_log: $ret";
  return $ret;
}

# This is the generic entry point to begin parsing an individual predicate.
# This is responsible for determining the key and dispatching to the correct
# function.
# 
# Inputs:
#  - pred: The predicate to be printed
# 
# Output:
#  - Returns the string representation of the specified predicate.
# 
sub pred_print_gen {
  my ($self, $pred) = @_;

  my ($key, $keys_found, $msg);

  foreach $key (keys %$pred) {
    # NOTE: $key will be left as one and only key in hashref as a side effect of
    #       this
    $keys_found++;
  }

  if ($keys_found == 0) {
    return '1';
  }

  if ($keys_found != 1) {
    $msg = sprintf("Expected only one key for the specified predicate. " .
                   "Found %d. Looking at predicate %s", $keys_found, $pred);
    confess( $msg );
  }

  if (not exists($print_funcs->{$key})) {
    $msg = sprintf("Missing print function for key %s. Looking at " .
                   "predicate %s", $key, $pred);
    confess( $msg );
  }

  return $print_funcs->{$key}->($self, $pred, $key);
}

# Prints out a human readable form of a predicate. This is the general entry
# point.
# 
# Input:
#  - pred: A predicate that has already been validated by caPredValidate
# 
# Output:
#  - Returns the string representation of the specified predicate.

sub pred_print {
  my ($self, $pred) = @_;

  return $self->pred_print_gen($pred);
}

# Walk a predicate and check if any of the leaves are checking a specific
# field.
# Input:
#  - field: The name of the field to search for
#  - pred: The predicate to search in
# 
sub pred_contains_field {
  my ($self, $field, $pred) = @_;

  my $found = 0;

  $self->pred_walk(
    sub {
      my ($x, $key) = @_;
      if ($x->{$key}->[0] eq $field) {
        $found = 1;
      }
    }, $pred);

  return $found;
}

# Walks the predicate and replaces all of the field names with appropriate
# values from the specified object. The object is defined where each possible
# predicate field is a key in the object and we replace the predicate field
# with the value from the object. This allows us to replace simple consumer
# predicate names i.e. latency or optype with the correct D expressions.
# 
# Input:
#  - obj: An Object where keys match the fields in the predicate and the values
#    are what should be substituted in
#  - pred: The predicate to apply this transformation to
sub pred_replace_fields {
  my ($self, $obj, $pred) = @_;

  $self->pred_walk(
    sub {
      my ($x, $key) = @_;
      my $msg;
      my $field = $x->{$key}->[0];
      if (not exists($obj->{$field})) {
        $msg = sprintf("Cannot find replacement for key %s in specified " .
                       "obj %s for predicate %s", $field, $obj, $x);
        confess( $msg );
      }
      $x->{$key}->[0] = $obj->{$field};
    }, $pred);
}

# Determines whether a predicate has expressions that need to evaluated.
# 
# Input:
#  - The predicate to evaluate
# Output:
#  - True if this predicate is not trivial, false otherwise
#
sub pred_non_trivial {
  my ($self, $pred) = @_;

  return (not PA::is_empty($pred));
}


# Iterates over the predicates and returns the list of fields that are at the
# leaves in the predicate. The list will not contain duplicates.
# 
# Input:
#  - pred: The predicate to extract the fields from.
# 
# Return:
#  - The list of fields used in the predicate without duplicates.
#
sub pred_fields {
  my ($self, $pred) = @_;

  my $ret = [];

  pred_walk(
    sub {
      my ($x, $key) = @_;
      my $field = $x->{$key}->[0];
      my $found;

      foreach my $ii (@$ret) {
        if ($field eq $ii) {
          $found++;
          last;
        }
      }
      if (not $found) {
        push @$ret, $field;
      }
    }, $pred);

  return $ret;
}

# Given a predicate and an object mapping key names to values, return whether
# the predicate is satisfied by the specified fields.
#
sub pred_eval {
  my ($self, $pred, $values) = @_;

  my ($expr);

  if (not $self->pred_non_trivial( $pred )) {
    return 1;
  }
  assert_defined( $pred );
  assert_hashref_nonempty( $pred );

  $expr = PA::deep_copy( $pred );
  $self->pred_replace_fields( $values, $expr );
  return $self->pred_eval_expr( $expr );
}

sub pred_eval_expr {
  my ($self, $expr) = @_;

  my ($key);

  $key = $self->pred_get_key( $expr );

  if ( $key eq "and" ) {
    foreach my $aval ( @{$expr->{and}} ) {
      if (not $self->pred_eval_expr( $aval ) ) {
        return 0;
      }
    }
    return 1;
  } elsif ( $key eq "or" ) {
    foreach my $aval ( @{$expr->{or}} ) {
      if ( $self->pred_eval_expr( $aval ) ) {
        return 1;
      }
    }
    return 0;
  } elsif ( ( $key eq "lt" ) or ( $key eq "le" ) or
            ( $key eq "gt" ) or ( $key eq "ge" ) ) {
    assert_happy_code { _NUMBER( $expr->{$key}->[0] ) };
    assert_happy_code { _NUMBER( $expr->{$key}->[1] ) };
    assert_hashref_keys_required( %$pred_eval_helpers, $key );
    assert_array_length( @{$expr->{$key}}, 2 );
  } else {
    assert_hashref_keys_required( %$pred_eval_helpers, $key );
    assert_array_length( @{$expr->{$key}}, 2 );
  }

  return $pred_eval_helpers->{$key}->( $expr->{$key}->[0],
                                       $expr->{$key}->[1] );

}



1;
