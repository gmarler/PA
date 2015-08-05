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

  ok( not(PA::Predicate->pred_non_trivial( { } )),
      'an empty predicate SHOULD BE trivial' );
  ok( PA::Predicate->pred_non_trivial( { eq => [ 'zonename', 'bar' ] } ),
      'a predicate with an expression should be non-trivial' );
}

sub test_pred_contains_field {
  my ($test) = shift;

  my $pred = { eq => [ 'zonename', 'foo' ] };

  ok( PA::Predicate->pred_contains_field('zonename', $pred),
      'predicate should contain field "zonename"' );

  ok( not(PA::Predicate->pred_contains_field('hostname', $pred)),
      'predicate should NOT contain field "hostname"' );

  $pred = { and => [ { eq => [ 'zonename', 'foo' ] },
                     { gt => [ 'latency',  200 ]   },
                   ]
           };

  ok( PA::Predicate->pred_contains_field('zonename', $pred),
      'predicate should contain field "zonename"' );
  ok( PA::Predicate->pred_contains_field('latency', $pred),
      'predicate should contain field "latency"' );
  ok( not(PA::Predicate->pred_contains_field('hostname', $pred)),
      'predicate should NOT contain field "hostname"' );

  my $obj = {
    zonename => 'zonename',
    latency  => 'timestamp - now->ts',
  };

  diag Data::Dumper::Dumper( $pred );
  PA::Predicate->pred_replace_fields($obj, $pred);
  diag Data::Dumper::Dumper( $pred );

  my $printed_pred = PA::Predicate->pred_print( $pred );
  cmp_ok( $printed_pred, 'eq', '(zonename == "foo") && ' .
          '(timestamp - now->ts > 200)',
          'printed predicate with replaced fields looks as expected' );
}
