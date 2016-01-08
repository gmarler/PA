package PA::Web::Controller::REST;
use Moose;
use namespace::autoclean;

# VERSION

BEGIN { extends 'Catalyst::Controller::REST'; }

use Net::AMQP::RabbitMQ;
use JSON::MaybeXS;
use Protocol::WebSocket::Handshake::Server;

=head1 NAME

PA::Web::Controller::REST - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=method index

Start of REST query

=cut

sub index :Path :Args(0) ActionClass('REST') {
    my ( $self, $c ) = @_;
}

=method index_GET

Implement GET verb on REST request

=cut

sub index_GET {
  my ($self, $c) = @_;

  $self->status_ok($c,
    entity => { test_data => 'bar' }
  );
}


=method vcpu

REST action for vcpu

=cut

sub vcpu :Path('/vcpu') :Args(1) ActionClass('REST') {
  my ($self, $c, $hostname) = @_;

  $c->stash->{'hostname'} = $hostname;
  $c->response->headers->header(
    'Access-Control-Allow-Origin' => '*',
  );
}

=method vcpu_GET

Implement GET verb on vcpu REST action

=cut

sub vcpu_GET {
  my ($self, $c) = @_;

  my $mq = Net::AMQP::RabbitMQ->new();

  $mq->connect(
    "localhost",
    {
      user     => "guest",
      password => "guest",
    }
  );

  $mq->channel_open(1);

  $mq->exchange_declare(1, "amq.direct",
    { exchange_type => 'direct',
      durable       => 1
    });

  $mq->queue_declare(1, 'sundev51');

  $mq->consume(1, 'sundev51');

  my $dhref = $mq->recv(1000);

  $self->status_ok($c,
    entity => { body =>   decode_json($dhref->{body}),
                hostname  => $c->stash->{hostname},
              }
            );
}

=method VCPU WebSocket TEST

Test of the VCPU WebSocket interface

=cut

#
# NOTE:
# Commented out below because it was redefining 'index' above - clear this up
# later
#
#
# sub start : ChainedParent
#  PathPart('echo') CaptureArgs(0) { }
# 
# sub index :Chained('start') PathPart('') Args(0)
# {
#   my ($self, $c) = @_;
#   my $url = $c->uri_for_action($self->action_for('ws'));
# 
#   $url->scheme('ws');
#   $c->stash(websocket_url => $url);
#   $c->forward($c->view('HTML'));
# }


=encoding utf8

=head1 AUTHOR

Gordon Marler

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
