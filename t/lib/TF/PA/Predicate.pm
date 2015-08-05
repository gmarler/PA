# NOTE: TF stands for TestsFor::...
package TF::PA::Predicate;

use File::Temp          qw();
use Data::Dumper        qw();
use Assert::Conditional qw();
# Possible alternative assertion methodology
# use Devel::Assert     qw();

use Test::Class::Moose;
with 'Test::Class::Moose::Role::AutoUse';

# Set up for schema
# BEGIN { use PA::MetadataManager::Schema; }

sub test_startup {
  my ($test, $report) = @_;
  $test->next::method;

  # ... Anything you need to do...
}

sub test_validate {
  my ($test) = shift;

  dies_ok( sub { PA::Predicate->pred_validate_rel( undef, 23 ) },
           'null predicate with numeric scalar should die' );
  dies_ok( sub { PA::Predicate->pred_validate_rel( undef, '23' ) },
           'null predicate with string scalar should die' );
  dies_ok( sub { PA::Predicate->pred_validate_rel( undef, ['foo'] ) },
           'null predicate with arrayref scalar should die' );

  PA::Predicate->pred_non_trivial( { } );
  ok( not PA::Predicate->pred_non_trivial( { } ),
      'an empty predicate SHOULD BE trivial' );
  ok( PA::Predicate->pred_non_trivial( { eq => [ 'zonename', 'bar' ] } ),
      'a predicate with an expression should be non-trivial' );

}

