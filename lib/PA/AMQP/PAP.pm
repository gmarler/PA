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

# Services on the AMQP network (config service, aggregators, and instrumenters)
# each create their own key which encodes their type and a unique identifier
# (usually hostname).

has [ 'amqp_key_base_aggregator' ] => (
  is       => 'ro',
  isa      => 'Str',
  default  => sub {
    my ($self) = @_;
    return $self->amqp_prefix . 'ca.aggregator.';
  },
);

has [ 'amqp_key_base_config' ] => (
  is       => 'ro',
  isa      => 'Str',
  default  => sub {
    my ($self) = @_;
    return $self->amqp_prefix . 'ca.config.';
  },
);

has [ 'amqp_key_base_instrumenter' ] => (
  is       => 'ro',
  isa      => 'Str',
  default  => sub {
    my ($self) = @_;
    return $self->amqp_prefix . 'ca.instrumenter.';
  },
);

has [ 'amqp_key_base_tool' ] => (
  is       => 'ro',
  isa      => 'Str',
  default  => sub {
    my ($self) = @_;
    return $self->amqp_prefix . 'ca.tool.';
  },
);

has [ 'amqp_key_base_stash' ] => (
  is       => 'ro',
  isa      => 'Str',
  default  => sub {
    my ($self) = @_;
    return $self->amqp_prefix . 'ca.stash.';
  },
);

# To facilitate autoconfiguration, each component only needs to know about this
# global config key.  Upon startup, a component sends a message to this key.
# The configuration service receives these messages and responds with any
# additional configuration data needed for this component.

has [ 'amqp_key_config' ] => (
  is       => 'ro',
  isa      => 'Str',
  default  => sub {
    my ($self) = @_;
    return $self->amqp_prefix . 'ca.config';
  },
);

# Similarly, there is only one persistence service.
has [ 'amqp_key_stash' ] => (
  is       => 'ro',
  isa      => 'Str',
  default  => sub {
    my ($self) = @_;
    return $self->amqp_prefix . 'ca.stash';
  },
);

# On startup, the configuration service broadcasts to everyone to let them know
# that it has (re)started.
has [ 'amqp_key_all' ] => (
  is       => 'ro',
  isa      => 'Str',
  default  => sub {
    my ($self) = @_;
    return $self->amqp_prefix . 'ca.broadcast';
  },
);

# 
# Each instrumentation gets its own key, which exactly one aggregator
# subscribes to.  This facilitates distribution of instrumentation data
# processing across multiple aggregators.
# 
has [ 'amqp_key_base_instrumentation' ] => (
  is       => 'ro',
  isa      => 'Str',
  default  => sub {
    my ($self) = @_;
    return $self->amqp_prefix . 'ca.instrumentation.';
  },
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

=method $self->route_key_for_inst($id);

=cut

sub route_key_for_inst {
  my ($self, $id) = @_;

  return $self->amqp_key_base_instrumentation . $id;
}

=method $self->incompatible( $msg );

=cut

sub incompatible {
  my ($self, $msg) = @_;

  return $msg->major != $self->amqp_vers_major;
}





1;
