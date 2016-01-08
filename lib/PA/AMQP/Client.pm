package PA::AMQP::Client;

use strict;
use warnings;
use v5.20;

# VERSION

use Moose;
use MooseX::Types::Moose qw(Str Int Undef HashRef);
use Moose::Util::TypeConstraints;
use namespace::autoclean;
use IO::Async::Loop             qw();
use DateTime::TimeZone          qw();
use Net::Async::AMQP            qw();
use JSON::MaybeXS               qw();

with 'MooseX::Log::Log4perl';

class_type 'Net::Async::AMQP', { class => 'Net::Async::AMQP' };
class_type 'Net::Async::AMQP::Channel';
class_type 'IO::Async::Loop';

#############################################################################
# Attributes
#############################################################################

has [ 'loop' ] => (
  is       => 'ro',
  isa      => 'IO::Async::Loop',
  default  => sub {
                say "BUILDING PA::AMQP::Client loop";
                return IO::Async::Loop->new;
              },
);

#
# The sequence # of the data sent for each particular routing_key
#
has [ 'sent_sequence' ] => (
  is       => 'rw',
  isa      => HashRef,
  default  => sub {
                return {};
              },
);

has [ 'mq' ] => (
  is       => 'ro',
  isa      => 'Net::Async::AMQP',
  lazy     => 1,
  builder  => '_build_mq',
);

has [ 'amqp_channel' ] => (
  is       => 'rw',
  isa      => Undef | 'Net::Async::AMQP::Channel',
  default  => undef,
);


has [ 'local_tz' ] => (
  is       => 'ro',
  isa      => 'DateTime::TimeZone',
  default  => sub {
                DateTime::TimeZone->new( name => 'local' );
              },
);

has [ 'amqp_server' ] => (
  is       => 'ro',
  isa      => 'Str',
  default  => sub {
                return "localhost";
              },
);

has [ 'mq_user' ] => (
  is       => 'ro',
  isa      => 'Str',
  default  => sub {
                return "solperf";
              },
);

has [ 'mq_password' ] => (
  is       => 'ro',
  isa      => 'Str',
  default  => sub {
                return "solperf";
              },
);

has [ 'exchange_name' ] => (
  is       => 'ro',
  isa      => 'Str',
  default  => sub {
                return "topic_stat";
              },
);

has [ 'client_hostname' ] => (
  is       => 'ro',
  isa      => 'Str',
  default  => sub {
                my $hostname = qx{/bin/uname -n};
                chomp($hostname);
                return $hostname;
              },
);

has [ 'json_encoder' ] => (
  is       => 'ro',
  isa      => 'Object',
  default  => sub {
                return JSON::MaybeXS->new->ascii;
              },
);


sub _build_mq {
  my ($self) = @_;

  my $loop = $self->loop;
  $loop->add(
    my $mq = Net::Async::AMQP->new()
  );
  $mq->connect(
    host    => $self->amqp_server,
    user    => $self->mq_user,
    pass    => $self->mq_password,
    vhost   => '/',
  )->then(
    sub {
      say "CONNECT SUCCEEDED";
      shift->open_channel;
    },
    sub { say "CONNECT FAILED!" }
  )->then(
    sub {
      my ($channel) = shift;
      say "OPENED CHANNEL " . $channel->id;
      # Store channel for later use
      $self->amqp_channel($channel);
      Future->needs_all(
        $channel->exchange_declare(
          type     => 'topic',
          exchange => $self->exchange_name,
        )
      );
    },
    sub { say "FAILED TO OPEN CHANNEL"; }
  )->get;

  return $mq;
}

=method BUILD

Use BUILD to specify the order in which attributes are initialized

=cut

sub BUILD {
  my ($self) = @_;

  say "Building loop";
  $self->loop;
  say "Building amqp_server";
  $self->amqp_server;
  say "Building mq_user";
  $self->mq_user;
  say "Building mq_password";
  $self->mq_password;
  say "Building exchange_name";
  $self->exchange_name;
  say "Building mq";
  $self->mq;
  say "Registering host";
  $self->register_host;
}

=method send( $routing_key, $d_href )

Given a routing key and the data to be sent over the queuing service, turn the
data into JSON and send it.

Also provide a sequencing number so we can determine if the sequence is being
broken or data is being lost.

=cut

sub send {
  my ($self, $routing_key, $d_href) = @_;

  my ($ch) = $self->amqp_channel;
  my ($coder) = $self->json_encoder;
  my ($exchange_name) = $self->exchange_name;

  # Increment Sequence for this routing_key
  if (not exists($self->sent_sequence->{$routing_key})) {
    $self->sent_sequence->{$routing_key} = 0;
  }
  $d_href->{sequence} = ++$self->sent_sequence->{$routing_key};

  my ($future) =
  $ch->publish(exchange      => $exchange_name,
               routing_key   => $routing_key,
               type          => "text/plain",
               expiration    => 60000,
               delivery_mode => 1,           # delivery_mode => 2 is persistent
               payload       => $coder->encode( $d_href ),
             );
  return $future;
}


=head2 register_host

When the PA client first starts up, it needs to notify the server of it's
existence.  If the host has never been registered before, the server registers
it.  If it has been registered before, all is well.

=cut

sub register_host {
  my ($self) = @_;
  my (@publish_futures);
  my ($routing_key) = $self->client_hostname . ".register_host";

  my ($data_href) = {
    time_zone => $self->local_tz->name,
  };
  say "REGISTERING: " . $self->client_hostname;

  push @publish_futures, $self->send($routing_key, $data_href);

  # Wait for all (one) of the publishing futures to complete
  my $publishing_future = Future->wait_all( @publish_futures );
  $publishing_future->get;
}



1;
