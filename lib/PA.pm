use strict;
use warnings;

package PA;

# VERSION
# ABSTRACT: Performance Analytics Suite

use Moose;
use namespace::autoclean;
use Solaris::uname;
use Clone                          qw(clone);
use Data::Compare                  qw();
use Scalar::Util                   qw( reftype );
use List::Util                     qw( any );
use DateTime                       qw();
use DateTime::Duration             qw();
use DateTime::Format::Duration     qw();
use Carp;

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
  my ($self, $agentname, $agentversion) = @_;

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

sub deep_equal {
  my ($self, $lhs, $rhs) = @_;

  my $c = Data::Compare->new($lhs, $rhs);

  return $c->Cmp;
}

sub deep_copy {
  my ($self, $obj) = @_;
 
  my $clone = clone($obj);
  return $clone;
}

sub deep_copy_into {
  confess "Not implemented";
}

# Raise exception with a reasonable message if the specified key does not
# exist in the object.  If 'prototype' is specified, raise exception
# if the type of $href->{key} doesn't match the TYPE of 'prototype'.
#
#   Returns $href->{key}
#
sub field_exists {
  my ($self, $href, $key, $prototype) = @_;

  if ( not any { $_ =~ m/^$key$/ } keys %$href ) {
    die "missing required field: $key";
  }
  if ($prototype &&
      (reftype($href->{key}) ne reftype($prototype))) {
    die "Field has wrong type: $key";
  }

  return $href->{key};
}

#
# Returns true IFF the given href is empty.
#
sub is_empty {
  my ($self, $href) = @_;

  foreach my $key (keys %$href) {
    return 0;
  }
  return 1;
}

#
# Returns the number of keys in a given href.
#
sub num_props {
  my ($self, $href) = @_;

  return scalar (keys %$href);
}

sub do_pad {
  my ($self, $chr, $width, $left, $str) = @_;
  my $ret = $str;

  while (length($ret) < $width) {
    if ($left) {
      $ret .= $chr;
    } else {
      $ret = $chr . $ret;
    }
  }

  return $ret;
}

# Given a time duration in millisecs, format it appropriately for output
sub format_duration {
  my ($self, $time_in_ms) = @_;

  my $df =
    DateTime::Format::Duration->new(
      pattern => '%Y years, %m months, %e days, ' .
                 '%H hours, %M minutes, %S seconds'
    );

  my $s = $d->format_duration(
    DateTime::Duration->new(
      nanoseconds => $time_in_ms * 1000000,
    )
  );

}

1;
