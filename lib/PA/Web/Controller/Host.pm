package PA::Web::Controller::Host;
use Moose;
use namespace::autoclean;

# VERSION

BEGIN { extends 'Catalyst::Controller::REST'; }

use JSON::MaybeXS;

=head1 NAME

PA::Web::Controller::Host - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 host_list

=cut

sub host_list : Path('/host') :Args(0) : ActionClass('REST') {
  my ( $self, $c ) = @_;

  $c->response->headers->header(
    'Access-Control-Allow-Origin' => '*',
  );
}

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


=encoding utf8

=head1 AUTHOR

Gordon Marler

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
