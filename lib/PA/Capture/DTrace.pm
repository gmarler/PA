package PA::Capture::DTrace;

use strict;
use warnings;

# VERSION
#
# ABSTRACT: To capture output from DTrace scripts

use v5.20;

use Moose;
use MooseX::Types::Moose qw(Str Int Undef HashRef ArrayRef);
use Moose::Util::TypeConstraints;
use namespace::autoclean;
use Solaris::kstat;
use DTrace::Consumer;
use IO::Async::Loop;
use Future;
use Data::Dumper;
use PA::AMQP::Client;
use JSON::MaybeXS;

with 'MooseX::Log::Log4perl';

#############################################################################
# Attributes
#############################################################################

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

has [ 'dtc' ] => (
  is       => 'ro',
  isa      => 'DTrace::Consumer',
  default  => sub {
                say "BUILDING DTrace::Consumer";
                my $dtc = DTrace::Consumer->new;
                return $dtc;
              },
);

has [ 'dtrace_options' ] => (
  is       => 'ro',
  isa      => 'ArrayRef',
  default  => sub {
                return [ ];
              },
);

has [ 'timer' ] => (
  is       => 'ro',
  isa      => 'IO::Async::Timer::Periodic',
  builder  => '_build_timer',
  lazy     => 1,
);

has [ 'dtrace_script' ] => (
  is       => 'ro',
  isa      => 'Str',
  required => 1,
);

has [ 'json_encoder' ] => (
  is       => 'ro',
  isa      => 'Cpanel::JSON::XS',
  default  => sub {
                return JSON::MaybeXS->new->ascii;
              },
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
  my ($dtc)               = $self->dtc;
  my ($loop)              = $self->loop;
  my ($client)            = $self->client;
  my ($prog)              = $self->dtrace_script;
  my ($coder)             = $self->json_encoder;

  $dtc->strcompile($prog);
  $dtc->go();

  my $timer = IO::Async::Timer::Periodic->new(
    interval => 1,
    on_tick  => sub {

      my $agg = {};

      $dtc->aggwalk(
        sub {
          my ($id, $key, $val) = @_;

          if (not exists( $agg->{$id} ) ) {
            $agg->{$id} = {};
          }

          my $merged_key = join ':', @$key;
          $agg->{$id}->{$merged_key} = $val;
        }
      );

      my %reduced_agg;
      $reduced_agg{timestamp} = DateTime->now( time_zone => 'UTC' )->epoch;
      $reduced_agg{interval_data}  = [ ];
      foreach my $aggid (keys %$agg) {
        push @{$reduced_agg{interval_data}}, $agg->{$aggid};
      }

      my @publish_futures;
      my ($routing_key) = $client->client_hostname . "." . $self->stat_name;
      push @publish_futures, $client->send($routing_key, \%reduced_agg);

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

Build order for our object

=cut

sub BUILD {
  my ($self) = @_;

  say "Building client";
  $self->client;
  say "Building loop";
  $self->loop;
  my ($dtc) = $self->dtc;
  say "Applying DTrace options (if any)";
  my (@dtrace_options) = @{$self->dtrace_options};
  if (@dtrace_options) {
    foreach my $option (@dtrace_options) {
      say "Setting option $option->[0] to $option->[1]";
      $dtc->setopt(@$option) or die "Unable to set $option";
    }
  } else {
    say "No DTrace options to set";
  }
  say "Building timer";
  $self->timer;
}


1;
