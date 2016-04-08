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
use IO::Async::Timer::Periodic;
use Future;
use Solaris::mdb                  qw();
use PA::Parser::mdb::memstat      qw();
use DateTime                      qw();
use DateTime::TimeZone            qw();
use Data::Dumper;

# with 'PA::Capture::LogToFile';
#
with 'MooseX::Log::Log4perl';

#############################################################################
# Attributes
#############################################################################

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
                my $mdb = Solaris::mdb->new( timeout => 300 );
                return $mdb;
              },
);

has [ 'timer' ] => (
  is       => 'ro',
  isa      => 'IO::Async::Timer::Periodic',
  builder  => '_build_timer',
  lazy     => 1,
);

has [ 'logger' ] => (
  is       => 'ro',
  isa      => 'Log::Log4perl::Logger',
  builder  => '_build_logger',
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

sub _build_logger {
  my ($self) = @_;

  # Ensure we're in the right logging category, so the right data goes to the
  # file
  return $self->log(__PACKAGE__);
}

sub _build_timer {
  my ($self) = @_;

  $self->log->debug( "BUILDING TIMER" );
  my ($loop)              = $self->loop;
  my ($client)            = $self->client;
  my ($mdb)               = $self->mdb;
  my ($logger)            = $self->logger;

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
      my $logging_output = $self->_format_for_logging($dhref);
      $logger->info( $logging_output );
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

  my $logger = $self->logger;

  $logger->debug( "Building client" );
  $self->client;
  $logger->debug( "Building loop" );
  $self->loop;
  $logger->debug( "Building mdb" );
  $self->mdb;
  $logger->debug( "Building timer" );

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

=method _format_for_logging

Format the extracted data for logging to a file

=cut

sub _format_for_logging {
  my ($self, $dhref) = @_;

  my $total_output;
  my $header = "# SUBSYSTEM:RAM SIZE IN BYTES:% OF TOTAL RAM";
  my (@fields) = qw( kernel zfs_metadata zfs_file_data anon exec_and_libs
                     page_cache free_cachelist free_freelist );

  # NOTE: We can use the timestamp here, and convert it into a datetime in the
  # local time zone because we're gathering from the data from this host, not
  # some remote host.
  my ($timestamp) = $dhref->{timestamp};
  my ($timestamp_text) = "EPOCH:" . $timestamp . "\n" .
    "LOCAL_DATETIME:" .
    DateTime->from_epoch( epoch     => $timestamp,
                          time_zone =>
                            DateTime::TimeZone->new( name => "local"),
                        )->strftime("%F %H:%M:%S");

  $total_output .= $timestamp_text . "\n";
  $total_output .= $header . "\n";

  foreach my $field (@fields) {
    my $href = $dhref->{$field};
    my $field_name = uc($field);
    my $line = "$field_name:" . $href->{bytes} . ":" . $href->{pct_of_total};
    $total_output .= $line . "\n";
  }

  return $total_output;
}

1;
