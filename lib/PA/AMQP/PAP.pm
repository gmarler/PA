package PA::AMQP::PAP;

use strict;
use warnings;

# VERSION
#
# ABSTRACT: AMQP Performance Analytics Protocol

use Moose;
use namespace::autoclean;
use PA;

with 'MooseX::Log::Log4perl';

#############################################################################
# Attributes
#############################################################################

has [ 'amqp_prefix' ] => (
  is       => 'rw',
  isa      => 'Str',
  builder  => '_build_amqp_prefix',
);

=head1 SYNOPSIS

=cut

#############################################################################
# Builders
#############################################################################
sub _build_amqp_prefix {
  my ($self) = @_;

  if (exists $ENV{CA_AMQP_PREFIX}) {
    return $ENV{CA_AMQP_PREFIX};
  } else {
    return '';
  }
}


#############################################################################
# Methods
#############################################################################
