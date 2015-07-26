# NOTE: TF stands for TestsFor::...
package TF::PA::MetadataManager;

use Time::Moment        qw();
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

sub test_normal {
  my ($test) = shift;

  
}

