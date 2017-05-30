package PA::Parser::arcstat;

use strict;
use warnings;
use v5.20;

# VERSION
# ABSTRACT: Parser for arcstat output variants

use Moose;
use Data::Dumper;
use DateTime                    qw();
use List::Util                  qw(max);
use JSON::MaybeXS               qw(encode_json decode_json);
use PA::DateTime::Format::arcstat;
use Moose::Util::TypeConstraints;
use namespace::autoclean;

# with 'PA::Parser';

# Define these, so we can use them in type unions below as needed
class_type 'IO::Handle';
class_type 'IO::File';
class_type 'IO::All::File';
class_type 'IO::Uncompress::Bunzip2';

has 'datastream' => (
  is         => 'rw',
  isa        => 'IO::Handle | IO::File | IO::All::File | IO::Uncompress::Bunzip2',
  required   => 1,
);

# As we read the datastream, we will often end up with 'partial' intervals that
# are incomplete, so we retain those to append to so that they are complete and
# can therefore be parsed on the next read from the datastream.
has 'remaining_data' => (
  is         => 'rw',
  isa        => 'Str',
  default    => '',
);

# Since arcstat.pl only emits time of day, and leaves out *which* day, if we're
# parsing from a file from a different day, allow the constructor to specify the
# date (but not the time) as a DateTime object being passed in.
# Default to the current day.
has 'date' => (
  is         => 'ro',
  isa        => 'DateTime',
  default    => sub {
    DateTime->today(time_zone => 'local');
  },
);

# matches on interval boundary, but warning, will match incomplete intervals.
# This regex is only intended to be used when you know for certain that you've
# read the complete file/datastream containing the stat output.
has 'interval_regex' => (
  is         => 'ro',
  isa        => 'RegexpRef',
  lazy       => 1,
  builder    => '_build_interval_regex',
);

# guaranteed to match exactly on interval boundary, to be used most of the time,
# due to partial intervals at the end of each datastream read up to the point
# where the entire file has been read in
has 'interval_regex_no_eof' => (
  is         => 'ro',
  isa        => 'RegexpRef',
  lazy       => 1,
  builder    => '_build_interval_regex_no_eof',
);

# 14:58:03 (output from arcstat.pl)
# pattern => '%H:%M:%S',
has 'time_regex' => (
  is         => 'ro',
  isa        => 'RegexpRef',
  default    =>
  sub {
    qr{
       ( (?^:[0-9 ]?(?^:(?:[0-9]))))
       \:
       ( (?^:[0-9 ]?(?^:(?:[0-9]))))
       \:
       ( (?^:[0-9 ]?(?^:(?:[0-9]))))
    }smx;
  },
);

sub _build_interval_regex {
  my ($self) = @_;
  my ($time_regex) = $self->time_regex;

  return
  qr{^
     (?<datetime>
      $time_regex
     )
     \s+
     (?<interval_data> .+?)
     \s+
     (?=
       (?:
         $time_regex [^\n]+
         \n
         |
         \z
       )
     )
    }smx;
}

sub _build_interval_regex_no_eof {
  my ($self) = @_;
  my ($time_regex) = $self->time_regex;

  return
  qr{^
     (?<datetime>
      $time_regex
     )
     \s+
     (?<interval_data> .+?)
     (?=
       (?:
         $time_regex [^\n]+
         \n
       )
     )
    }smx;
}

=method BUILD

Build order for our object

=cut

sub BUILD {
  my ($self) = @_;

  $self->interval_regex();
  $self->interval_regex_no_eof();
}


=head2 _parse_interval

Parse data for a single time interval

=cut

sub _parse_interval {
  my ($self) = @_;
  my ($output);

  my $dtf_parser = PA::DateTime::Format::arcstat->new;
  my $datastream = $self->datastream;
  #$datastream->read($output, 1024 * 1024);
  my ($data) = do { local $/; <$datastream>; };

  my $interval_regex = $self->chosen_interval_regex();
  my $time_regex     = $self->chosen_time_regex();

  #
  #  Time  read  miss  miss%  dmis  dm%  pmis  pm%  mmis  mm%  arcsz     c
  #
  say "Time,Total ARC Accesses/sec,ARC Misses/sec,ARC Miss %," .
      "Demand Data Misses/sec,Demand Data Misses %,Prefetch Misses/sec," .
      "Prefetch Miss %,Metadata Misses/sec,Metadata Miss %,ARC Size," .
      "ARC Target Size";

  my (%arcstat_data, $intervals);

  my $iostat_dev_regex =
    qr{ ^ \s+ (?<rps>[\d\.]+) \s+ (?<wps>[\d\.]+) \s+ (?<rbw>[\d\.]+)  \s+
              (?<wbw>[\d\.]+) \s+ (?<wait>[\d\.]+) \s+ (?<actv>[\d\.]+) \s+
              (?<wsvc_t>[\d\.]+) \s+ (?<asvc_t>[\d\.]+) \s+ (?<pctw>\d+) \s+
              (?<pctb>\d+) \s+ (?<device>[^\n]+) \n
      }smx;

  # Iterate over each iostat interval, separated by timestamp of some form
  while ($data =~ m{ $interval_regex }gsmx ) {
    my ($line) = '';
    my ($interval_data) = $+{interval_data};
    # Tear individual intervals into their respective:
    # - Timestamp in Excel preferred format of yyyy-MM-dd HH:mm:ss
    my $dt = $dtf_parser->parse_datetime($+{datetime});
    #$line .= "$+{datetime},";
    #$line .= $dt->strftime("%Y-%m-%d %H:%M:%S") . ",";
    $line .= $dt->strftime("%H:%M:%S") . ",";
    $intervals++;
  }

  say STDERR "Found $intervals INTERVALS";

  return \%arcstat_data;
}

=head2 parse_intervals

Parse data for several time intervals

=cut

sub parse_intervals {
  my ($self) = @_;
  my ($new_data);
  my ($intervals_aref) = [];
  my (@captured_intervals);

  my $datastream = $self->datastream;
  # If we've previously exhausted the datastream, there's nothing left to do
  return if ($datastream->eof);   # undef

  my $dtf_parser     = PA::DateTime::Format::arcstat->new;
  my $specified_date = $self->date;
  my $remaining_data = $self->remaining_data;

  # Read data off 1 MB at a time, parsing and returning the
  # info as available in complete intervals
  $datastream->read($new_data, 1024 * 1024);
  # Append the data we just read to the previously remaining data, if any
  $remaining_data .= $new_data;

  my ($interval_regex);
  if ($datastream->eof) {
    $interval_regex = $self->interval_regex();
  } else {
    $interval_regex = $self->interval_regex_no_eof();
  }

  my (@arcstat_data, $intervals);

  #
  #  Time  read  miss  miss%  dmis  dm%  pmis  pm%  mmis  mm%  arcsz     c
  #

  my $arcstat_regex =
    qr{ ^ (?<read>\d+(?:K|M|G)?) \s+ (?<miss>\d+(?:K|M|G)?)  \s+
          (?<miss_pct>\d+)       \s+ (?<dmiss>\d+(?:K|M|G)?) \s+
          (?<dmiss_pct>\d+)      \s+ (?<pmiss>\d+(?:K|M|G)?) \s+
          (?<pmiss_pct>\d+)      \s+ (?<mmiss>\d+(?:K|M|G)?) \s+
          (?<mmiss_pct>\d+)      \s+ (?<arcsz>\d+(?:K|M|G)?) \s+
          (?<arctgt>\d+(?:K|M|G)?) # \s\s \n  # Lines end with 2 spaces
      }smx;

  # Iterate over each stat interval, each on it's own line in the case of
  # arcstat
  while ($remaining_data =~ m{ $interval_regex }gsmx ) {
    my ($interval_data) = $+{interval_data};
    #say "INTERVAL DATA: [$interval_data]";
    # Tear individual intervals into their respective:
    # - Timestamp in Excel preferred format of yyyy-MM-dd HH:mm:ss
    my $dt = $dtf_parser->parse_datetime($+{datetime});
    $dt->set( year => $specified_date->year, month => $specified_date->month,
              day  => $specified_date->day );
    #$dt->set_time_zone( 'local' );
    #$line .= "$+{datetime},";
    #$line .= $dt->strftime("%Y-%m-%d %H:%M:%S") . ",";
    my $formatted_dt = $dt->strftime("%Y-%m-%d %H:%M:%S");

    push @$intervals_aref, [ $dt ];
    my $interval_aref = $intervals_aref->[-1];

    # Remove the single interval we just matched
    $remaining_data =~ s{ $interval_regex }{}smx;

    while ($interval_data =~ m/$arcstat_regex/gsmx) {
      my $captured_stats =
        [ (@+{qw(read miss miss_pct dmiss dmiss_pct pmiss pmiss_pct mmiss
                 mmiss_pct arcsz arctgt)}) ] ;
      # Convert arcsz, arctgt to bytes
      my ($arcsz,$arctgt) = @{$captured_stats}[9,10];
      my ($unit,$multiplier);
      $arcsz =~ m/(?<unit>[KMG])$/;
      if    ($+{unit} eq 'K') { $multiplier = 1024; }
      elsif ($+{unit} eq 'M') { $multiplier = 1024 * 1024; }
      elsif ($+{unit} eq 'G') { $multiplier = 1024 * 1024 * 1024; }
      $arcsz =~ s/[KMG]$//;
      $captured_stats->[9] = $arcsz * $multiplier;
      $arctgt =~ m/(?<unit>[KMG])$/;
      if    ($+{unit} eq 'K') { $multiplier = 1024; }
      elsif ($+{unit} eq 'M') { $multiplier = 1024 * 1024; }
      elsif ($+{unit} eq 'G') { $multiplier = 1024 * 1024 * 1024; }
      $arctgt =~ s/[KMG]$//;
      $captured_stats->[10] = $arctgt * $multiplier;

      # Do something with the data
      push @$interval_aref, @$captured_stats;
    }
  }

  # Store away any partial interval for the next time through
  $self->remaining_data($remaining_data);

  # TODO: If the datastream has been exhausted, and we still have remaining
  #       data, make sure to call that fact out, and possibly output what that
  #       data was
  if ($remaining_data) {
    #say "incomplete interval left over of length " . length($remaining_data) .
    #    ":\n$remaining_data";
  }

  return $intervals_aref;
}

=head2 parse_to_csv

Parse intervals and output as CSV

=cut

sub parse_to_csv {
  my ($self) = @_;
  my (@intervals);

  my $header = "DateTime,ARC Miss %,Demand Data Miss %,Prefetch Miss %," .
               "Metadata Miss %,ARC Size,ARC Target";
  say $header;
  while( my $aref = $self->parse_intervals()) {
    foreach my $interval (@$aref) {
      my ($line) = $interval->[0]->strftime("%H:%M:%S") . ",";
      $line .= join ",", @{$interval}[3,5,7,8,9,10,11];
      say $line;
    }
  }
}

__PACKAGE__->meta->make_immutable;

1;
