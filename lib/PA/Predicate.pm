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

  foreach my $i_key (keys %$pred) {
    # will simply die if validation fails, silently proceeds otherwise
    $self->pred_validate_syntax($pred->{$key}->{$i_key});
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




1;
