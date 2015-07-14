use strict;
use warnings;

package PA::Vis::Heatmap;

use Moose;
use Posix    qw(log floor);




=method autoscale

Autoscale a maximum value using the following procedure

* Start with a power of 10 that is greater than the maximum.

* Divide down (alternatively by 5 and 2) until a value is achieved such
  that the lowest multiple of that value that is greater than the max is
  no more than 25% greater.

This assures that the autoscaling is stable even as the maximum fluctuates,
but is close enough to the max to not have many empty buckets at the top of
the range.

=cut

sub autoscale {
  my ($self, $max) = @_;

  my $pow      = floor(log($max) / log(10)) + 1;
  my $round    = 1;
  my $ceiling  = 1.25 * $max;
  my $divisors = [];
  my $i;

  for ($i = 0; $i < $pow; $i++) {
    push(@$divisors, 5);
    push(@$divisors, 2);
    $round *= 10;
  }

  for ($i = 0; $i < scalar(@$divisors); $i++) {
    my $scaled = (floor($max / $round) + 1) * $round;

    if ($scaled < $ceiling) {
      return $scaled;
    }

    $round /= $divisors->[$i];
  }

  return $max;
}


=method bucketize

bucketize() processes data into buckets, and is the first stage in
generating a heatmap.

This method takes two arguments:

=for :list
* An arrayref (or hashref -- see below) representing the data ('$data')
* A hashref denoting the configuration parameters of the bucketization ('$conf').

The data is a series of ranges and values associated with those ranges.  These
ranges need not be uniform and may be sparse (or even overlapping); the
data will be bucketized across the specified number of (evenly distributed)
buckets.  Where ranges don't line up precisely with a bucket, the
corresponding value will be fractionally mapped to those buckets with which
the range overlaps, with a weight of overlap.  (That is, the bucketization
will effectively assume a linear distribution within the range.)  The
output of bucketize() is a map, which we define to be an array of bucket
arrays, where each element denotes a sample, and each bucket array denotes
the bucketized data for that sample.

'$data' is expected to be a series where each data point is an arrayref of
two-tuples where each consists of a two-tuple range aref and a value.  This
series may be expressed as an arrayref of arrayrefs, e.g.:

=begin text

     
    [
        [
            [ [ 0, 9 ], 20 ],
            [ [ 10, 19 ], 4 ],
            ...
        ], [
            [ [ 10, 19 ], 12 ],
            ...
        ]
    ]

=end text


Alternatively, the series may also be expressed as a hashref in which each
key is the number of samples:

=begin text

    
    {
        20 => [
            [ [ 0, 9 ], 20 ],
            [ [ 10, 19 ], 4 ],
            ...
        ],
        22 => [
            [ [ 10, 19 ], 12 ],
            ...
        ]
    }

=end text

In this representation, '$conf' must have 'base' and 'nsamples'
keys to denote the desired range, and may also have 'step' to denote the
size of each sample; see below.

The '$conf' hashref describes configuration information and must contain
the following keys

=for :list
* nbuckets
  The number of buckets for bucketization

If the hashref data representation is used (as opposed to the arrayref
representation), the '$conf' hashref must contain two additional keys

=for :list
* base
  The index of the lowest sample in 'data' to be processed.
* nsamples
  The number of samples to be processed.

'$conf' has the following optional keys:

=for :list
* min
  The minimum value to represent.
  If the minimum is not specified, it is assumed to be 0.
* max
  The maximum value to represent.

The buckets will span a range of [ min, max ).  If the max
is not specified, it will be dynamically determined -- and the result will
be set in '$conf'.

=for :list
* step
  The distance between consecutive samples
  (only applicable for the object data representation).
* weighbyrange
  A boolean.
  If true, denotes that values should be weighed by their range.

=cut


sub bucketize {
  my ($self, $data, $conf) = @_;

}



1;
