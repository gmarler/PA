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


__PACKAGE__->meta->make_immutable;

1;
