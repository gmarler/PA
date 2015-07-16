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
    [ [ 0, 9 ], 10 ],
    [ [ 10, 19 ], 20 ],
    [ [ 20, 29 ], 60 ]
] ], { nbuckets => 10 });

#diag Dumper( $rval );
#diag Dumper( $conf );

$hm->normalize($rval);

#diag Dumper( $rval );
#diag Dumper( $conf );

cmp_deeply( $rval, [ [ 0.3, 0.3, 0.3, 0.4, 0.6, 0.6, 0.8, 1, 1, 0.7 ] ],
 'normalization correct');

done_testing();
