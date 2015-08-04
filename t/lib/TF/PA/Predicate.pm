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

  throws_ok( sub { PA::Predicate->pred_validate( undef, 23 ) },
             'null predicate with numeric scalar should die' );
}

