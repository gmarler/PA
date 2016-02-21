package PA::Capture::mdb::memstat;

use strict;
use warnings;
use v5.20;

# VERSION

use Moose;
use MooseX::Types::Moose qw(Str Int Undef HashRef ArrayRef);
use Moose::Util::TypeConstraints;
use namespace::autoclean;
use IO::Async::Loop;
use Future;
use Solaris::mdb;
use PA::Parser::mdb::memstat;

with 'MooseX::Log::Log4perl';

#############################################################################
# Attributes
#############################################################################
#
has [ 'parser' ] => (
  is      => 'ro',
  isa     => 'PA::Parser::mdb::memstat',
  default => sub {
    return PA::Parser::mdb::memstat->new;
  },
);

has [ 'client' ] => (
  is       => 'ro',
  isa      => 'PA::AMQP::Client',
  required => 1,
);

has [ 'loop' ] => (
  is       => 'ro',
  isa      => 'IO::Async::Loop',
  default  => sub {
                say "BUILDING " . __PACKAGE__ . " loop";
                return IO::Async::Loop->new;
              },
);

has [ 'mdb' ] => (
  is       => 'ro',
  isa      => 'Solaris::mdb',
  lazy     => 1,
  default  => sub {
                # ::memstat can take a while on the largest machines, so give a nice timeout
                my $mdb = Solaris::mdb->new( timeout => 30 );
                return $mdb;
              },
);

has [ 'timer' ] => (
  is       => 'ro',
  isa      => 'IO::Async::Timer::Periodic',
  builder  => '_build_timer',
  lazy     => 1,
);

#
# This is the statistic name to send with the MQ routing key, so we can identify
# what kind of DTrace capture data this is; as in, for what metric.  May need to
# refine this going forward, or redo in other terms.
#
has [ 'stat_name' ] => (
  is       => 'ro',
  isa      => 'Str',
  required => 1,
);

sub _build_timer {
  my ($self) = @_;

  say "BUILDING TIMER";
  my ($loop)              = $self->loop;
  my ($client)            = $self->client;
  my ($mdb)               = $self->mdb;

  my $timer = IO::Async::Timer::Periodic->new(
    interval   => 30,
    reschedule => "drift",
    on_tick    => sub {
      my $out = $mdb->capture_dcmd("time::print -d ! sed -e 's/^0t//' ; ::memstat");

      my $dhref = $self->extract($out);

      my @publish_futures;
      my ($routing_key) = $client->client_hostname . "." . $self->stat_name;
      push @publish_futures, $client->send($routing_key, $dhref);

      # Wait for all of the publishing futures to complete
      my $publishing_future = Future->wait_all( @publish_futures );
      $publishing_future->get;
    },
  );

  $timer->start;
  $loop->add($timer);

  return $timer;
}

=method BUILD

Build our object in the proper sequence

=cut

sub BUILD {
  my ($self) = @_;

  say "Building client";
  $self->client;
  say "Building loop";
  $self->loop;
  say "Building mdb";
  $self->mdb;
  say "Building timer";
  $self->timer;
}


=method extract

Given output from mdb's ::memstat dcmd, return a hashref datas tructure
containing the salient info

=cut

sub extract {
  my ($self,$interval) = @_;

  return $self->parser->parse_interval($interval);
}



1;
