package PA::Parser;

use strict;
use warnings;

# VERSION
# ABSTRACT: Object to represent basic Parser capabilities

use v5.20;

use FindBin qw($Bin);

use lib "$Bin/../lib";

use Moose::Role;
use namespace::autoclean;
use IO::File                     qw();
use DateTime::Format::Strptime   qw();
use DateTime::Set                qw();
use DateTime::Span               qw();
use Fcntl                        qw(SEEK_SET);
use Moose::Util::TypeConstraints;
use Data::Dumper;

#
# These are the methods objects which use this role must implement
#
requires '_build_dt_regex';
requires '_build_datetime_parser';
requires '_build_strptime_pattern';
requires '_parse_interval';


# Define these, so we can use them in type unions below as needed
class_type 'IO::Handle';
class_type 'IO::File';
class_type 'IO::All::File';
class_type 'IO::Uncompress::Bunzip2';

# If we're parsing from a continuous datastream or file, rather than reading
# interval by interval
has 'datastream' => ( is       => 'rw',
                      isa      => 'IO::Handle | IO::File | IO::All::File | IO::Uncompress::Bunzip2',
                      required => 0,
                    );

# The Date/Time regex, should be universal across all *stat and other
# data gathering applications
has 'dt_regex' => (
  is      => 'ro',
  isa     => 'RegexpRef',
  lazy    => 1,
  builder => '_build_dt_regex',
);

# And this actually parses the datetime into a DateTime object
has 'datetime_parser' => (
  is      => 'ro',
  isa     => 'CodeRef',
  lazy    => 1,
  builder => '_build_datetime_parser',
);

has 'strptime_pattern' => (
  is      => 'ro',
  isa     => 'Str',
  lazy    => 1,
  builder => '_build_strptime_pattern',
);

# Regex used to pull individual records from the input, breaking them up into
# a datetime stamp, and the raw data (as $1 and $2)
has 'regex'    => ( is => 'rw', isa => 'RegexpRef',
                    lazy => 1, # Must be lazy because it depends on dt_regex
                    default => sub {
                                 my $self = shift;
                                 my $dt_regex = $self->dt_regex;
                               qr{(
                                    $dt_regex   # date-timestamp
                                    (?:.+?)     # all data after date-timestamp
                                  )
                                  # Up to, but not including, the next date/timestamp
                                  # (?= (?: $self->dt_regex | \z ) )
                                  (?= (?: $dt_regex ) )
                                 }smx;
                               },
                  );

# regex to use at EOF
# NOTE It's not clear we even need this anymore - will re-evaluate during a
#      later refactoring session
has 'regex_eof' => ( is => 'rw', isa => 'RegexpRef',
                     lazy => 1, # Must be lazy because it depends on dt_regex
                     default => sub {
                                  my $self = shift;
                                  my $dt_regex = $self->dt_regex;
                                qr{(
                                     $dt_regex   # date-timestamp
                                     (?:.+?)     # all data after date-timestamp
                                   )
                                   # Up to, but not including, the next date/timestamp
                                   (?= (?: $dt_regex | \z ) )
                                  }smx;
                                },
                   );


=method parse_interval($interval_output)

Parse the data out of a single interval of time

=cut

sub parse_interval {
  my ($self, $interval_output) = @_;

  my ($dt_stamp, $interval_data);

  my ($dt_regex) = $self->dt_regex;
  my ($regex)    = $self->regex;

  # Find and extract timestamp via timestamp regex
  ($dt_stamp) = $interval_output =~ m/ ($dt_regex) /smx;
  chomp($dt_stamp);

  ($interval_data = $interval_output) =~ s/ $dt_regex //smx;

  #
  # Then parse the timestamp
  # Well, not really - we don't need to do that actually
  # TODO Remove references to parsing timestamps into epoch secs
  #
  # Then parse the interval data
  my $dhref = $self->_parse_interval($interval_data);

  #
  # Add the timestamp to the gathered data and return it
  #
  $dhref->{timestamp} = $dt_stamp;
  return $dhref;
}





1;
