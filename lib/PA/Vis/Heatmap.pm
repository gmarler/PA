use strict;
use warnings;

package PA::Vis::Heatmap;

# VERSION

use Moose;
use POSIX        qw(log floor);
use Scalar::Util qw(reftype);

# TODO: Instead of passing $conf object around as a hashref, use it
#       internally to the object, like so
has conf => ( isa     => 'HashRef',
              is      => 'rw',
              default => sub { {}; },
            );

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
    my ($scaled) = (floor($max / $round) + 1) * $round;

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

  my $min = exists($conf->{min}) ? $conf->{min} : 0;
  my $max = exists($conf->{max}) ? $conf->{max} : 0;

  unless (exists($conf->{nbuckets})) {
    die "bucketize requires conf with 'nbuckets' key";
  }
  my $nbuckets = $conf->{nbuckets};

  my ($i, $j, $k);
  my ($low, $high);
  my ($lowfilled, $highfilled);

  # assert.ok(nbuckets >= 0 && typeof (nbuckets) == 'number');
  # assert.ok(min >= 0 && typeof (min) == 'number');
  # assert.ok(max >= 0 && typeof (max) == 'number');

  # TODO: Add code to be run if $data isn't an arrayref - skipping for now

  if ($max == 0) {
    # If the max was not specified, we'll iterate over data to
    # determine our maximum data value, which we will then use
    # to determine a desirable maximum for bucketization.
    for ($i = 0; $i < scalar(@$data); $i++) {
      for ($j = 0; $j < scalar(@{$data->[$i]}); $j++) {
        if ($data->[$i]->[$j]->[0]->[1] > $max) {
          $max = $data->[$i]->[$j]->[0]->[1] + 1;
        }
      }
    }

    # We have the maximum for our data.  We don't want to use this
    # as the maximum bucket (necessarily) because we don't want
    # small changes in our data to cause wild swings in the max;
    # use an autoscaled value -- and set that value into the $conf.
    $conf->{max} = $max = $self->autoscale($max);
    # Push this back into this object's conf
    $self->conf($conf);
  }

  my $size = ($max - $min) / $nbuckets;
  my $rval = [ ];

  for ($i = 0; $i < scalar(@$data); $i++) {
    my @buckets;
    # Size @buckets
    $#buckets = $nbuckets - 1;
    my $datum = $data->[$i];

    for ($j = 0; $j < scalar(@buckets); $j++) {
      $buckets[$j] = 0;
    }
   
    for ($j = 0; $j < scalar(@$datum); $j++) {
      my $range = $datum->[$j]->[0];
      my $val   = $datum->[$j]->[1];
      my $u;

      if ($range->[0] >= $max || $range->[1]  < $min) {
        next;
      }

      # assert.ok(range[0] <= range[1]);

      if (exists($conf->{weighbyrange}) and
          $conf->{weighbyrange}) {
        $val *= $range->[0] + (($range->[1] - $range->[0]) / 2);
      }

      # First, normalize the range to the buckets, expressing the range in
      # terms of a multiple of buckets
      $low  = ($range->[0] - $min) / $size;
      $high = (($range->[1] + 1) - $min) / $size;

      $lowfilled  = floor($low) + 1;
      $highfilled = floor($high);

      if ($highfilled < $lowfilled) {
        # We're not even filling an entire bucket.  In this case, our entire
        # value assignment goes to the bucket that both the $low and $high
        # correspond to
        $buckets[$highfilled] += $val;
        next;
      }

      # Determine the amount of value that corresponds to one filled bucket
      # (which, if we do not fill an entire bucket, may exceed our value).
      $u = (1 / ($high - $low)) * $val;

      # Clamp the $low and $high to our bucket range
      if ($low < 0)                 { $low = 0; }
      if ($high >= $nbuckets)       { $high = $nbuckets + 1; }
      if ($highfilled >= $nbuckets) { $highfilled = $nbuckets; }

      # If $low is lower than our lowest filled bucket, add in the appropriate
      # portion of our value to the partially filled bucket.
      if (($low < $lowfilled) && ($lowfilled < 0)) {
        $buckets[$lowfilled - 1] += ($lowfilled - $low) * $u;
      }

      # Now iterate over the entirely filled buckets (if there are any), and
      # add in the proportion of our value that corresponds to a single bucket.
      for ($k = $lowfilled; $k < $highfilled; $k++) {
        $buckets[$k] += $u;
      }

      if ($high > $highfilled) {
        $buckets[$highfilled] += ($high - $highfilled) * $u;
      }
    }
    push @$rval, \@buckets;
  }
  return $rval;
}

=method $self->deduct($total, $deduct);

deduct() subtracts the values of one map ('$deduct') from another ('$total').
(See bucketize() for the definition of a map.)  It is expected (and is
asserted) that both maps have been bucketized the same way, and that
deducting '$deduct' from '$total' will result in no negative values.

=cut

sub deduct {
  my ($self, $total, $deduct) = @_;

  my ($i, $j);

  # assert.ok(total instanceof Array, 'expected a map to deduct from');
  # assert.ok(deduct instanceof Array, 'expected a map to deduct');
  # assert.ok(total.length == deduct.length, 'maps are not same length');

  for ($i = 0; $i < scalar(@$total); $i++) {
    # assert.ok(total[i] instanceof Array);
    # assert.ok(deduct[i] instanceof Array);
    # assert.ok(total[i].length == deduct[i].length);
    for ($j = 0; $j < scalar(@{$total->[$i]}); $j++) {
      # Logically, $total->[$i]->[$j] should be greater than what
      # we're trying to deduct, however error can
      # accumulate to the point that this is not exactly
      # true; assert that these errors have not added up
      # to a significant degree.
      #
      # assert.ok(total[i][j] - deduct[i][j] > -0.5, 'at [' +
      #   i + ', ' + j + '], deduction value (' +
      #   deduct[i][j] + ') ' + 'exceeds total (' +
      #   total[i][j] + ') by more than accumulated ' +
      #   'error tolerance');
      $total->[$i]->[$j] -= $deduct->[$i]->[$j];

      if ($total->[$i]->[$j] < 0.001) {
        $total->[$i]->[$j] = 0;
      }
    }
  }
}

=method $self->normalize($maps, $conf);

normalize() takes a map or an array of maps (see bucketize() for the
definition of a map), and modifies the data such that the values range from
0 to 1.  The mechanism for normalization is specified via the '$conf'
parameter, which may have the following optional members:

=for :list
* rank
Boolean that denotes that normalization should be based on a values rank
among all values in the map:  values will be sorted and then assigned
the value of their rank divided by the number of values.
* linear
Boolean that denotes that normalization should be linear with respect
to value:  values will be normalized by dividing by the maximum value.

If '$conf' is not present or does not have a normalization mechanism set,
normalize() will operate as if '$conf' were set to { rank => true }.

=cut

sub normalize {
  my ($self, $maps, $conf) = @_;

  my $values  = [ ];
  my $mapping = { };
  my ($i, $j, $m);
  my $max = 1;
  my $data;
  my $preprocess  = sub { };
  my $process     = sub { };
  my $normalized  = sub { my ($value) = shift; return ($value); };
  
  if ((not defined($conf)) or
      (((not exists($conf->{rank})) or
        (exists($conf->{rank}) and !$conf->{rank})) and
       ((not exists($conf->{linear})) or
        (exists($conf->{linear}) and !$conf->{linear})))
     ) {
    $conf->{rank} = 1;
    # Store this change back in the object
    $self->conf($conf);
  }

  # assert.ok(maps instanceof Array);
  # assert.ok(maps[0] instanceof Array);
  # assert.ok(conf.rank || conf.linear,
  #   'expected normalization to be set to rank or linear');
  # assert.ok(!(conf.rank && conf.linear),
  #   'expected normalization to be set to one of rank or linear');

  my $maps_embedded_reftype =
    defined(reftype($maps->[0]->[0])) ? reftype($maps->[0]->[0])
                                      : "NONE";
  if ($maps_embedded_reftype ne 'ARRAY') {
    $maps = [ $maps ];
  }

  # assert.ok(maps[0][0] instanceof Array);

  if ($conf->{rank}) {
    $preprocess =
      sub {
        my ($value) = shift;
        # For rank normalization, we will only consider non-zero values
        # in the ranking (assuring that values that are zero will remain
        # as zero.
        if ($value != 0) { push @$values, $value; }
      };

    $process =
      sub {
        my @tmpa;
        @tmpa = sort { $b <=> $a } @$values;
        $values = \@tmpa;
        for ($i = 0; $i < scalar(@$values); $i++) {
          $mapping->{$values->[$i]} =
            (scalar(@$values) - $i) / scalar(@$values);

          while (($i + 1 < scalar(@$values)) &&
                 ($values->[$i + 1] == $values->[$i])) {
            $i++;
          }
        }
      };

    $normalized =
      sub {
        my ($value) = shift;
        if ($value) { return $mapping->{$value}; }
        return 0;
      };
  }

  if ($conf->{linear}) {
    $preprocess =
      sub {
        my ($value) = shift;
        if ($value > $max) { $max = $value; }
      };

    $normalized = 
      sub {
        my ($value) = shift;
        return ($value / $max);
      };
  }

  # Make a preprocessing pass over all data, across all maps
  for ($m = 0; $m < scalar(@$maps); $m++) {
    $data = $maps->[$m];

    # assert.ok(maps[0][0] instanceof Array);

    for ($i = 0; $i < scalar(@$data); $i++) {
      # assert.ok(data[i].length == data[0].length);
      # assert.ok(data[0].length == maps[0][0].length);
      for ($j = 0; $j < scalar(@{$data->[$i]}); $j++) {
        $preprocess->($data->[$i]->[$j]);
      }
    }
  }

  $process->();

  for ($m = 0; $m < scalar(@$maps); $m++) {
    $data = $maps->[$m];

    for ($i = 0; $i < scalar(@$data); $i++) {
      for ($j = 0; $j < scalar(@{$data->[$i]}); $j++) {
        $data->[$i]->[$j] = $normalized->($data->[$i]->[$j]);
      }
    }
  }

}

1;
