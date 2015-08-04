package PA::Predicate;

use strict;
use warnings;

use Moose;
use Assert::Conditional;
use PA;
use namespace::autoclean;
use Carp;
use Scalar::Util  qw(reftype);
use Params::Util  qw(_STRING _NUMBER);

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
    confess("predicate is missing key %s", $key);
  }

  if (not defined($pred->{$key}) &&
      not reftype($pred->{$key}) eq "ARRAY") {
    confess("predicate key does not point to an arrayref");
  }

  if (not ((my $elem_count = scalar(@{$pred->{$key}})) == 2)) {
    confess("predicate key does not point to an arrayref of two" .
            " elements: found %d elements instead", $elem_count);
  }

  $field = $pred->{$key}->[0];
  $constant = $pred->{$key}->[1];

  if (not _STRING( $field ) ) {
    confess("predicate field is not a string: got %s",$field);
  }

  if (not _NUMBER( $constant ) &&
      not _STRING( $constant ) ) {
      confess("predicate constant is not a constant: got %s", $constant);
  }
}

1;
