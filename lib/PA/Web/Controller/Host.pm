package PA::Web::Controller::Host;
use v5.20;
use Moose;
use namespace::autoclean;
use Data::Dumper;

# VERSION

BEGIN { extends 'Catalyst::Controller::REST'; }

use JSON::MaybeXS;

=head1 NAME

PA::Web::Controller::Host - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut

# Make sure we always avoid this message by setting a default type:
# [info] Could not find a serializer for an empty content-type
__PACKAGE__->config(default => 'application/json');

=method host_list

First step in chain that extracts a list of hosts as a REST entity

=cut

sub host_list : Path('/host') :Args(0) : ActionClass('REST') {
  my ( $self, $c ) = @_;

  $c->response->headers->header(
    'Access-Control-Allow-Origin' => '*',
  );
}

=method host_list_GET

Implement GET verb for host_list REST query

=cut

sub host_list_GET {
  my ($self, $c) = @_;

  my %host_list;
  my $host_rs = $c->model('DB::Host')->search;
  while ( my $host_row = $host_rs->next ) {
    $host_list{ $host_row->name } =
      { id => $host_row->host_id,
        time_zone => $host_row->time_zone,
      };
  }
  # $c->stash->{'host_list'} = \%host_list;
  $self->status_ok( $c, entity => \%host_list );
}

=method hosts

First step in chain that extracts a list of hosts as a REST entity in the
preferred format.

=cut

sub hosts : Path('/hosts') :Args(0) : ActionClass('REST') {
  my ( $self, $c ) = @_;

  $c->response->headers->header(
    'Access-Control-Allow-Origin' => '*',
  );
}

=method hosts_GET

Implement GET verb for hosts REST query

=cut

sub hosts_GET {
  my ($self, $c) = @_;

  my @host_list;

  my $host_rs = $c->model('DB::Host')->search;
  while ( my $host_row = $host_rs->next ) {
    push @host_list,
      { name      => $host_row->name,
        id        => $host_row->host_id,
        time_zone => $host_row->time_zone,
      };
  }

  $self->status_ok( $c, entity => \@host_list );
}



=method host_memstat

First step in chain that extracts the memstat of a host as a REST entity

=cut

sub host_memstat : Path('/host/memstat') :Args(0) : ActionClass('REST') {
  my ( $self, $c ) = @_;

  $c->response->headers->header(
    'Access-Control-Allow-Origin' => '*',
  );
}

=method host_memstat_GET

Implement GET verb for host_memstat REST query

=cut

sub host_memstat_GET {
  my ($self, $c) = @_;

  my @memstat_rows;
  my $memstat_rs = $c->model('DB::Memstat')->search_by_host_sorted(10);
  while (my $memstat_row = $memstat_rs->next) {
    my %cols = $memstat_row->get_columns;
    push @memstat_rows, \%cols;
  }
  $self->status_ok( $c, entity => \@memstat_rows );
}

=method host

Get the host portion of the /host/<host>/... URL

=cut


# This is the beginning of our chain
sub host : PathPart('host') Chained('/') CaptureArgs(1) {
  my ( $self, $c, $hostname ) = @_;

  # Allow CORS (Cross-Origin Resource Sharing)
  $c->response->headers->header(
    'Access-Control-Allow-Origin' => '*',
  );

  my $host = $c->model('DB::Host')->find_by_name($hostname);

  say "HOSTNAME:  " . $host->name;
  say "HOSTID:    " . $host->host_id;
  say "TIME_ZONE: " . $host->time_zone;

  $c->stash->{ hostname }  = $host->name;
  $c->stash->{ hostid }    = $host->host_id;
  $c->stash->{ time_zone } = $host->time_zone;
}

=method date

Get the date portion of the /host/<host>/date/<date>/... URL

=cut

sub date : PathPart('date') Chained('host') CaptureArgs(1) {
  my ( $self, $c, $date ) = @_;

  $c->stash->{ date } = $date;

  say "DATE:      $date";
}


=method subsystem

Get the subsystem portion of the /host/<host>/date/<date>/subsystem/<subsystem>/... URL

=cut

sub subsystem : PathPart('subsystem') Chained('date') CaptureArgs(1) {
  my ( $self, $c, $subsystem ) = @_;

  $c->stash->{ subsystem } = $subsystem;

  say "SUBSYSTEM: $subsystem";
}

=method metric

Get the metric portion of the
/host/<host>/date/<date>/subsystem/<subsystem>/metric/<metric> URL

=cut

sub metric : PathPart('metric') Chained('subsystem') Args(1) {
  my ( $self, $c, $metric ) = @_;

  my @rows;
  my ($metrics) = {
    memstat => 'Memstat',
  };

  say "METRIC:    $metric";

  $c->stash->{ resultset } = $metrics->{$metric};

  my $resultset = $c->stash->{ resultset };
  my $hostid    = $c->stash->{ hostid };
  my $date      = $c->stash->{ date };
  my $time_zone = $c->stash->{ time_zone };
  my $subsystem = $c->stash->{ subsystem };

  say "RESULTSET: DB::$resultset";

  my $metric_rs = $c->model('DB::' . $resultset)
                    ->search_by_host_on_date($hostid, $date, $time_zone);

  while (my $row = $metric_rs->next) {
    my %cols = $row->get_columns;
    push @rows, \%cols;
  }

  $self->status_ok( $c, entity => \@rows );
}


=encoding utf8

=head1 AUTHOR

Gordon Marler

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
