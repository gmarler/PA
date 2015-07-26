use strict;
use warnings;

package PA::MetricSet;

# VERSION
#
# ABSTRACT: Encapsulates a set of PA::Metric's

use List::Util qw( any );
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


=method add_metric

Add a metric from the form used by profile and metric metadata, which is
an object with just "module", "stat" and "fields".

=cut

sub add_metric {
  my ($self, $module, $stat, $fields) = @_;

  my ($statfields);

  if (not any { /^ $module $/x } keys %{$self->modules}) {
    $self->modules->{module} = {};
  }

  if (not any { /^ $stat $/x } keys %{$self->modules->{$module}}) {
    $self->modules->{$module}->{$stat} = {};
  }

  $statfields = $self->modules->{$module}->{$stat};

  for (my $i = 0; $i < scalar(@$fields); $i++) {
    $statfields->{$fields->[$i]} = 1;
  }
}

=method base_metric

Returns a metric instance for the metric identified by the specified
module and stat, if such a metric exists in this set.  Returns undef
otherwise.

=cut

sub base_metric {
  my ($self, $module, $stat) = @_;

  if (not any { /^ $module $/x } keys %{$self->modules}) {
    return;
  }

  if (not any { /^ $stat $/x } keys %{$self->modules->{$module}}) {
    return;
  }

  return Metric->new($module, $stat, $self->modules->{$module}->{$stat});
}

=method base_metrics

Returns an arrayref of all base metrics in this metric set.

=cut

sub base_metrics {
  my ($self) = shift;

  my @result;

  foreach my $module (keys %{$self->modules}) {
    foreach my $stat (keys %{$self->modules->{$module}}) {
      push @result, $self->base_metric($module, $stat);
    }
  }

  return \@result;
}

=method intersection

Returns the intersectoin of this metric set with the specified other
metric set.  The host information is not preserved in the new set.

=cut

sub intersection {
  my ($self, $rhs) = @_;

  my $res = MetricSet->new();

  $res->add_partial_intersection($self, $rhs);
  $res->add_partial_intersection($rhs,  $self);

  return $res;
}

=method add_partial_intersection

Private Method

Adds the metrics from "lhs" that also exist in "rhs" to "self"

=cut

sub add_partial_intersection {
  my ($self, $lhs, $rhs) = @_;

  my ($lstats, $rstats);

  foreach my $modname (keys %{$lhs->modules}) {
    if (not any { /^ $modname $/x } keys %{$rhs->modules}) {
      next;
    }

    $lstats = $lhs->modules->{$modname};
    $rstats = $rhs->modules->{$modname};

    # TODO: Finish this...
  }
}

__PACKAGE__->meta->make_immutable;

1;
