use warnings;
use v5.18.1;
use feature qw(say);

use Test::Most;
use Data::Dumper;

use_ok( 'PA::Vis::Heatmap' );

my $conf = { nbuckets => 10, };

my $hm = PA::Vis::Heatmap->new( conf => $conf );

isa_ok($hm, 'PA::Vis::Heatmap', 'proper object created');

my $rval = $hm->bucketize(
  [ [
      [ [ 0, 19 ], 10 ],
      [ [ 20, 29 ], 20 ],
      [ [ 30, 99 ], 60 ],
  ] ], $conf);

cmp_ok( $conf->{max}, '==', 120,
        'returned max in conf updated' );

cmp_ok( $hm->conf->{max}, '==', 120,
        'object conf reflects updated max' );

# diag Dumper( $rval );

cmp_deeply( $rval, [ [ 6,
    12,
    17.142857142857146,
    10.285714285714285,
    10.285714285714285,
    10.285714285714285,
    10.285714285714285,
    10.285714285714285,
    3.428571428571434,
    0 ] ],
'auto-scale max' );

$rval = $hm->bucketize(
  [ [ 
      [ [ 0, 9 ], 10 ],
      [ [ 10, 19 ], 20 ],
      [ [ 20, 29 ], 60 ]
  ] ],
  { nbuckets => 10,
    max      => 1000,
  });

cmp_deeply( $rval, [ [ 90, 0, 0, 0, 0, 0, 0, 0, 0, 0 ] ],
            'max == 1000 with 10 buckets' );

$rval = $hm->bucketize(
[ [ 
    [ [ 0, 9 ], 10 ],
    [ [ 10, 19 ], 20 ],
    [ [ 20, 29 ], 60 ]
] ],
  { nbuckets => 10,
    min      =>  0,
    max      => 35,
    nbuckets =>  7,
  });

cmp_deeply( $rval, [ [ 5, 5, 10, 10, 30, 30, 0 ] ],
            '10 => 7 buckets' );


$rval = $hm->bucketize(
[ [ 
    [ [ 0, 9 ], 10 ],
    [ [ 10, 19 ], 20 ],
    [ [ 20, 29 ], 60 ]
] ], { nbuckets => 10, 
       min      => 15,
       max      => 25,
       nbuckets =>  2,
     });


cmp_deeply( $rval, [ [ 10, 30 ] ],
 '10 => 2 buckets');


$rval = $hm->bucketize(
[ [ 
    [ [ 0, 0 ], 1 ],
    [ [ 1, 1 ], 1 ],
    [ [ 2, 2 ], 1 ]
] ], { nbuckets => 3,
       min      => 0,
       max      => 3,
     });


cmp_deeply( $rval, [ [ 1, 1, 1 ] ],
 'nbuckets == max');

done_testing();
