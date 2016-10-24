package PA::Web::Controller::Admin;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller'; }

=head1 NAME

PA::Web::Controller::Admin - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index

=cut

#sub index :Path :Args(0) {
#    my ( $self, $c ) = @_;
#
#    $c->response->body('Matched PA::Web::Controller::Admin in Admin.');
#}

sub admin : PathPart('admin') Chained('/') CaptureArgs(0) {
  my ($self, $c) = @_;
}

sub hosts : PathPart('hosts') Chained('admin') Args(0) {
  my ( $self, $c ) = @_;

  $c->stash->{'template'} = 'admin/hosts.tt';
  $c->stash->{'current_view'} = 'TT';
  $c->stash->{'hosts_rs'} = $c->model('DB::Host');
  #$c->response->body('Fetched list of hosts to administer.');
}

sub host : PathPart('host') Chained('admin') CaptureArgs(1) {
  my ($self, $c ) = @_;
}

sub delete :PathPart('delete') : Chained('host'): Args(0) {
  my ($self, $c ) = @_;
  # TODO: After deleting host, redirect back to host admin page
  return $c->res->redirect( $c->uri_for('/admin/hosts') );
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
