package PA::Web::Controller::Stats;
use Moose;
use namespace::autoclean;

# VERSION

BEGIN { extends 'Catalyst::Controller'; }

=head1 NAME

PA::Web::Controller::Stats - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index

=cut

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;

    $c->response->body('Matched PA::Web::Controller::Stats in Stats.');
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
