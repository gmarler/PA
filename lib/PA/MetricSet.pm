use strict;
use warnings;

package PA::MetricSet;

# VERSION
#
# ABSTRACT: Encapsulates a set of PA::Metric's

use namespace::autoclean;
use Moose;

# metrics indexed by module name
has 'modules' =>
  ( is       => 'ro',
    isa      => 'HashRef',
  );

# metrics indexed by host name
has 'byhost' =>
  ( is       => 'ro',
    isa      => 'HashRef',
  );


__PACKAGE__->meta->make_immutable;

1;
