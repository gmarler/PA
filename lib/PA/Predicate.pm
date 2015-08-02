package PA::Predicate;

use strict;
use warnings;

use Moose;
use Assert::Conditional;
use PA;
use namespace::autoclean;

#
# A mapping from a predicate key to the type specific parsing routine.  Any
# change to the set of possible initial keys must bupdate these data structures
# as well as pred_evaluate();
#
has parse_funcs => (
  is         => 'ro',
  isa        => 'HashRef',
  default    => sub {
    return {
      lt  => \&pred_validate_rel,
      le  => \&pred_validate_rel,
      gt  => \&pred_validate_rel,
      ge  => \&pred_validate_rel,
      eq  => \&pred_validate_rel,
      ne  => \&pred_validate_rel,
      and => \&pred_validate_log,
      or  => \&pred_validate_log,
    };
  },
);

# A mapping that determines which specific instrumentation fields are supported
# by which predicate relational and logical operators.
# TODO: populate using keys defined in PA
has key_fields => (
  is         => 'ro',
  isa        => 'HashRef',
  default    => sub {
    return {
      lt  => {},
      le  => {},
      gt  => {},
      ge  => {},
      eq  => {},
      ne  => {},
    };
  },
);

#
# A mapping to the operator specific printing routines.
#
has print_funcs => (
  is         => 'ro',
  isa        => 'HashRef',
  default    => sub {
    return {
      lt    => \&pred_print_rel,
      le    => \&pred_print_rel,
      gt    => \&pred_print_rel,
      ge    => \&pred_print_rel,
      eq    => \&pred_print_rel,
      ne    => \&pred_print_rel,
      and   => \&pred_print_log,
      or    => \&pred_print_log,
    };
  },
);

#
# the operator specific string to use while printing
#
has print_strings => (
  is         => 'ro',
  isa        => 'HashRef',
  default    => sub {
    return {
      lt    => '<',
      le    => '<=',
      gt    => '>',
      ge    => '>=',
      eq    => '==',
      ne    => '!=',
      and   => '&&',
      or    => '||',
    };
  },
);


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
  my ($keysfound,$key);

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


1;
