package PA::Capture::kstat;

use strict;
use warnings;

# VERSION
#
# ABSTRACT: To capture output from kstat data

use v5.20;

use Moose;
use MooseX::Types::Moose qw(Str Int Undef HashRef ArrayRef);
use Moose::Util::TypeConstraints;
use namespace::autoclean;
use Solaris::kstat;
use IO::Async::Loop;
use IO::Async::Timer::Periodic;
use Future;
use Data::Dumper;
use PA::AMQP::Client;

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

has [ 'kstat' ] => (
  is       => 'ro',
  isa      => 'Solaris::kstat',
  default  => sub {
                say "BUILDING kstat";
                return Solaris::kstat->new;
              },
);

has [ 'kstats_to_collect' ] => (
  is       => 'ro',
  isa      => ArrayRef[ ArrayRef ],
  default  => sub {
                [
                  [ "unix", 0, "system_pages" ],
                ];
              },
);


has [ 'timer' ] => (
  is       => 'ro',
  isa      => 'IO::Async::Timer::Periodic',
  builder  => '_build_timer',
  lazy     => 1,
);


sub _build_timer {
  my ($self) = @_;

  say "BUILDING TIMER";
  my ($k)                 = $self->kstat;
  my ($loop)              = $self->loop;
  my ($client)            = $self->client;
  my (@kstats_to_collect) = @{$self->kstats_to_collect};

  my $timer = IO::Async::Timer::Periodic->new(
    interval => 1,
    on_tick  => sub {
      $k->update;
      my $latest_k = $k->copy;
      my @futures;

      foreach my $kstat_def (@kstats_to_collect) {
        my ($module, $instance, $name) = @$kstat_def;
        push @futures,
          Future->wrap(
              { name =>  $name,
                stats => capture_kstat($latest_k, $module, $instance, $name)
              }
          );
      }

      my $kstat_future =
        Future->wait_all(
          @futures
        );
      $kstat_future->on_done(
        sub {
          my (@done_futures) = @_;
          my (@publish_futures);
          foreach my $done_future (@done_futures) {
            my ($stat_name)  = $done_future->get->{name};
            my ($stat_stats) = $done_future->get->{stats};
            #say Dumper( $done_future->get );
            my ($routing_key) = $client->client_hostname . ".$stat_name";
            push @publish_futures, $client->send($routing_key, $stat_stats);
          }
          # Wait for all of the publishing futures to complete
          my $publishing_future = Future->wait_all( @publish_futures );
          $publishing_future->get;
        }
      );
    },
  );

  $timer->start;
  $loop->add($timer);

  return $timer;
}

sub BUILD {
  my ($self) = @_;

  say "Building client";
  $self->client;
  say "Building loop";
  $self->loop;
  say "Building kstat";
  my ($k) = $self->kstat;
  say "Initializing kstats to collect";
  my (@kstats_to_collect) = @{$self->kstats_to_collect};
  foreach my $kstat_def (@kstats_to_collect) {
    my ($module,$instance,$name) = @$kstat_def;
    () = each %{$k->{$module}->{$instance}->{$name}};
  }
  say "Building timer";
  $self->timer;
}

sub capture_kstat {
  my ($k, $module, $instance, $name) = @_;

  my ($outdata);
  # Filter out the non-numeric values (class => misc, for instance)
  my %keep = map{ $_ => $k->{$module}{$instance}{$name}{$_}  }
             grep { $k->{$module}{$instance}{$name}{$_} !~ m/\D/; }
             keys %{$k->{$module}{$instance}{$name}};

  $outdata = \%keep;
  $outdata->{timestamp} = DateTime->now( time_zone => 'UTC' )->epoch;

  return $outdata;
}





1;
