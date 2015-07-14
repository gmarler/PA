use strict;
use warnings;

package PA::Vis::Heatmap;

use Moose;
use Posix    qw(log floor);



=head1 METHODS

=method autoscale

Autoscale a maximum value by:

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

1;
