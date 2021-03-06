# NOTE: TF stands for TestsFor::...
package TF::PA::Predicate;

use File::Temp          qw();
use Data::Dumper        qw();
use Assert::Conditional qw();
use JSON::MaybeXS       qw();
use boolean;
# Possible alternative assertion methodology
# use Devel::Assert     qw();

use Test::Class::Moose;
with 'Test::Class::Moose::Role::AutoUse';

my $print_test_cases =
[
  [ {}, '1' ],
  [ {
      eq  => [ 'execname', 'mplayer' ],
    }, 'execname == "mplayer"' ],
  [ {
      ne  => [ 'execname', 'vlc' ],
    }, 'execname != "vlc"' ],
  [ {
      lt  => [ 'latency', 42 ],
    }, 'latency < 42' ],
  [ {
      gt  => [ 'latency', 23 ],
    }, 'latency > 23' ],
  [ {
      le  => [ 'latency', 42 ],
    }, 'latency <= 42' ],
  [ {
      ge  => [ 'latency', 23 ],
    }, 'latency >= 23' ],
  [ {
      and => [ {}, { eq => [ 'latency', 23 ] } ],
    }, '(1) && (latency == 23)' ],
  [ {
      or  => [ { eq => [ 'latency', 23 ] }, {} ],
    }, '(latency == 23) || (1)' ],
];

my $eval_test_cases =
[ {
    pred   => {},                               # trivial case
    values => {},
    result => true,
  }, {
    pred   => { eq => ['hostname', 'legs'] },   # eq: strings, !=
    values => { 'hostname' => 'louie' },
    result => false,
  }, {
    pred   => { eq => ['hostname', 'legs'] },   # eq: strings, ==
    values => { 'hostname' => 'legs' },
    result => true,
  }, {
    pred   => { eq    => ['pid', 12] },         # eq: numbers, !=
    values => { 'pid' => 15 },
    result => false,
  }, {
    pred   => { eq    => ['pid', 12] },         # eq: numbers, ==
    values => { 'pid' => 12 },
    result => true,
  }, {
    pred => { ne => ['hostname', 'legs'] },     # ne: strings, !=
    values => { 'hostname' => 'louie' },
    result => true
  }, {
    pred => { ne => ['hostname', 'legs'] },     # ne: strings, ==
    values => { 'hostname' => 'legs' },
    result => false
  }, {
    pred  => { ne => ['pid', 12] },             # ne: numbers, !=
    values => { 'pid' => 15 },
    result => true
  }, {
    pred => { ne  => ['pid', 12] },             # ne: numbers, ==
    values => { 'pid' => 12 },
    result => false
  }, {
    pred => { le => ['pid', 10] },              # le: <, =, >
    values => { 'pid' => 5 },
    result => true
  }, {
    pred  => { le => ['pid', 10] },
    values => { 'pid' => 10 },
    result => true
  }, {
    pred   => { le => ['pid', 10] },
    values => { 'pid' => 15 },
    result => false
  }, {
    pred   => { lt => ['pid', 10] },            # lt: <, =, >
    values => { 'pid' => 5 },
    result => true
  }, {
    pred   => { lt => ['pid', 10] },
    values => { 'pid' => 10 },
    result => false
  }, {
    pred   => { lt => ['pid', 10] },
    values => { 'pid' => 15 },
    result => false
  }, {
    pred   => { ge => ['pid', 10] },            # ge: <, =, >
    values => { 'pid' => 5 },
    result => false
  }, {
    pred   => { ge => ['pid', 10] },
    values => { 'pid' => 10 },
    result => true
  }, {
    pred =>  { ge =>  ['pid', 10] },
    values =>  { 'pid' =>  15 },
    result =>  true
  }, {
    pred =>  { gt =>  ['pid', 10] },            # gt =>  <, =, >
    values =>  { 'pid' =>  5 },
    result =>  false
  }, {
    pred =>  { gt =>  ['pid', 10] },
    values =>  { 'pid' =>  10 },
    result =>  false
  }, {
    pred =>  { gt =>  ['pid', 10] },
    values =>  { 'pid' =>  15 },
    result =>  true
  }, {
    pred =>  {
        and =>  [
        { eq =>  [ 'hostname', 'johnny tightlips' ] },
        { eq =>  [ 'pid', 15 ] },
        { eq =>  [ 'execname', 'sid the squealer' ] }
      ]
    },
    values =>  {
      hostname =>  'johnny tightlips',
      pid =>  15,
      execname =>  'sid the squealer'
    },
    result =>  true
  }, {
    pred =>  {
        and =>  [
        { eq =>  [ 'hostname', 'johnny tightlips' ] },
        { eq =>  [ 'pid', 15 ] },
        { eq =>  [ 'execname', 'sid the squealer' ] }
      ]
    },
    values =>  {
      hostname =>  'johnny tightlips',
      pid =>  10,
      execname =>  'sid the squealer'
    },
    result =>  false
  }, {
    pred =>  {
        or =>  [
        { eq =>  [ 'hostname', 'johnny tightlips' ] },
        { eq =>  [ 'pid', 15 ] },
        { eq =>  [ 'execname', 'sid the squealer' ] }
      ]
    },
    values =>  {
      hostname =>  'johnny tightlips',
      pid =>  10,
      execname =>  'sid the squealer'
    },
    result =>  true
  }, {
    pred =>  {
        or =>  [ {
            and =>  [
            { eq =>  [ 'hostname', 'johnny tightlips' ] },
            { eq =>  [ 'pid', 15 ] },
            { eq =>  [ 'execname', 'sid the squealer' ] }
          ]
        }, {
          eq =>  [ 'trump', 'true' ]
        } ]
    },
    values =>  {
      hostname =>  'johnny tightlips',
      pid =>  10,
      execname =>  'sid the squealer',
      trump =>  'true'
    },
    result =>  true
  }, {
    pred =>  {
        or =>  [ {
            and =>  [
            { eq =>  [ 'hostname', 'johnny tightlips' ] },
            { eq =>  [ 'pid', 15 ] },
            { eq =>  [ 'execname', 'sid the squealer' ] }
          ]
        }, {
          eq =>  [ 'trump', 'true' ]
        } ]
    },
    values =>  {
      hostname =>  'johnny tightlips',
      pid =>  10,
      execname =>  'sid the squealer',
      trump =>  'false',
    },
    result =>  false,
  }
];

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

  PA::Predicate->pred_replace_fields($obj, $pred);

  my $printed_pred = PA::Predicate->pred_print( $pred );
  cmp_ok( $printed_pred, 'eq', '(zonename == "foo") && ' .
          '(timestamp - now->ts > 200)',
          'printed predicate with replaced fields looks as expected' );

  $pred = { and => [ { eq => [ 'zonename', 'foo' ] },
                     { gt => [ 'latency', 200    ] },
                   ],
          };

  my $fields = PA::Predicate->pred_fields( $pred );

  cmp_deeply( $fields, [ 'zonename', 'latency' ],
              'fields from pred_fields are generated correctly' );
}

sub test_pred_eval {
  my ($test) = shift;

  foreach my $entry (@$eval_test_cases) {
    cmp_ok(PA::Predicate->pred_eval( $entry->{pred}, $entry->{values} ), '==',
           $entry->{result},
           'Predicate evaluation produced ' . $entry->{result});
  }
}

sub test_pred_invalid {
  my ($test) = shift;

  my $fields = { numeric => 5, string => 'hello' };

  dies_ok(sub { PA::Predicate->pred_eval({ eq => [] }, $fields) },
          'Invalid predicate form (array too small)');

  dies_ok(sub { PA::Predicate->pred_eval({ eq => {} }, $fields) },
          'Invalid predicate form (wrong type)');

  dies_ok(sub { PA::Predicate->pred_eval({ inval => [1, 2] }, $fields) },
          'Invalid predicate form (invalid key)');

  dies_ok(sub { PA::Predicate->pred_eval({ le => ['string', 3] }, $fields) },
          'Invalid types');

  dies_ok(sub { PA::Predicate->pred_eval({ le => ['junk', 3] }, $fields) },
          'Missing value');
}

sub test_print {
  my ($test) = shift;

  foreach my $entry ( @$print_test_cases ) {
    cmp_ok(PA::Predicate->pred_print( $entry->[0] ), 'eq',
           $entry->[1],
           "Predicate produces " . $entry->[1]);
  }
}
