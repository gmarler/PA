# NOTE: TF stands for TestsFor::...
package TF::PA::Metric;

use Time::Moment      qw();
use File::Temp        qw();
use Data::Dumper      qw();

use Test::Class::Moose;
with 'Test::Class::Moose::Role::AutoUse';

# Set up for schema
# BEGIN { use PA::Schema; }

sub test_startup {
  my ($test, $report) = @_;
  $test->next::method;

  # ... Anything you need to do...
}

1;
