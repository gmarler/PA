use strict;
use warnings;

package PA::Metric;

# VERSION
#
# ABSTRACT: Represents a single base metric.

use namespace::autoclean;
use Moose;

has 'module' => ( is       => 'ro',
                  isa      => 'Str',
                  required => 1,
                );

has 'stat'   => ( is       => 'ro',
                  isa      => 'Str',
                  required => 1,
                );

has 'fields' => ( is       => 'ro',
                  isa      => 'ArrayRef',
                  required => 1,
                );


=method new


=cut

=method $metric->contains_field( $field );

Returns true if listed field is contained in this metric's field list,
false otherwise.

=cut

sub contains_field {
  my ($self,$field) = @_;

  if ( any { /^ $field $/x } @{$self->fields} ) {
    return 1;
  } else {
    return 0;
  }
}

__PACKAGE__->meta->make_immutable;

1;
