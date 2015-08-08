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
  is       => 'ro',
  isa      => 'Str',
  builder  => '_build_amqp_prefix',
);

# If configured, we may ping ourselves at the specified interval to detect
# rabbitmq broker disconnection.
has [ 'amqp_ping_interval' ] => (
  is       => 'ro',
  isa      => 'Str',
  default  => sub {
    my $self = shift;
    return 30 * 1000;  # 30 secs
  },
);

# The Performance Analytics Protocol API is versioned with a major and minor
# number.
# Software components should ignore messages received with a newer major
# version number.
has [ 'amqp_vers_major' ] => (
  is       => 'ro',
  isa      => 'Num',
  default  => 2,
);

has [ 'amqp_vers_minor' ] => (
  is       => 'ro',
  isa      => 'Num',
  default  => 5,
);

# We only use one global exchange of type 'direct'
has [ 'amqp_exchange' ] => (
  is       => 'ro',
  isa      => 'Str',
  default  => 'amq.direct',
);

has [ 'amqp_exchange_opts' ] => (
  is       => 'ro',
  isa      => 'HashRef',
  default  => sub {
    return { type => 'direct', };
  }
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
