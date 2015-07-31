use strict;
use warnings;

package PA;

# VERSION
# ABSTRACT: Performance Analytics Suite

use Moose;
use namespace::autoclean;
use Solaris::uname;

# Constants
#
# Default HTTP Ports, shared by the services themselves and the tests.
has http_port_config => (
  is      => 'ro',
  isa     => 'Int',
  default => 23181,
);

has http_port_agg_base => (
  is      => 'ro',
  isa     => 'Int',
  default => 23184,
);

# PA Field Arities
# TODO: Should these be types?
has field_arity_discrete => (
  is      => 'ro',
  isa     => 'Str',
  default => 'discrete',
);

has field_arity_numeric => (
  is      => 'ro',
  isa     => 'Str',
  default => 'numeric',
);

# PA Instrumentation Arities
has arity_scalar => (
  is      => 'ro',
  isa     => 'Str',
  default => 'scalar',
);

has arity_discrete => (
  is      => 'ro',
  isa     => 'Str',
  default => 'discrete-decomposition',
);

has arity_numeric => (
  is      => 'ro',
  isa     => 'Str',
  default => 'numeric-decomposition',
);

# Minimum value for "granularity" > 1. Instrumenters report data at least this
# frequently, and all values for "granularity" must be a multiple of this.
has granularity_min => (
  is      => 'ro',
  isa     => 'Num',
  default =>     5,
);

sub sdc_config {
  return;  # We don't do this, so undefined
}

sub sys_info {
  my ($agentname, $agentversion) = @_;

  my $uname = uname();
  my $hostname;

  if ( exists $ENV{'HOST'} and length($ENV{'HOST'}) ) {
    $hostname = $ENV{'HOST'};
  } else {
    $hostname = $uname->{nodename};
  }

  return {
    agent_name => $agentname,
    agent_version => $agentversion,
    os_name       => $uname->{sysname},
    os_release    => $uname->{release},
    os_revision   => $uname->{version},
    os_machine    => $uname->{machine},
    hostname      => $hostname,
    major         => PA::AMQP->vers_major,
    minor         => PA::AMQP->vers_minor,
  };
}

1;
