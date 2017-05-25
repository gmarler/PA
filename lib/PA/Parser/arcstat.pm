package PA::Parser::arcstat;

use strict;
use warnings;
use v5.20;

# VERSION
# ABSTRACT: Parser for iostat output variants

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
    DateTime->today();
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
      $time_regex   # Don't include newline in capture
     )
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
      $time_regex   # Don't include newline in capture
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

  my $parser     = PA::DateTime::Format::arcstat->new;
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

  my $iostat_header_regex =
    qr{
        \s+ extended \s+ device \s+ statistics [^\n]+ \n
        \s+ r/s \s+ w/s \s+ (?<bwunit>k|M)r/s \s+ (k|M)w/s \s+ wait \s+
            actv \s+ wsvc_t \s+ asvc_t \s+ \%w \s+ \%b \s + device \n
      }smx;

  my $iostat_interval_regex =
    qr| $iostat_header_regex
        (?<interval_data>.+?)
        (?=${iostat_header_regex})
      |smx;

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
    my $dt = $parser->parse_datetime($+{datetime});
    #$line .= "$+{datetime},";
    #$line .= $dt->strftime("%Y-%m-%d %H:%M:%S") . ",";
    $line .= $dt->strftime("%H:%M:%S") . ",";
    # - Headers
    #   Need to extract read/write multiplier, as this can change over
    #   time, if metric collection is stopped/restarted
    if ($interval_data =~ m{ $iostat_header_regex }smx) {
      # Check whether BandWidth Units are in KB or MB
      if ($+{bwunit} eq "k") {
        $bw_multiplier = 1024;
      } elsif ($+{bwunit} eq "M") {
        $bw_multiplier = 1024 * 1024;
      }
    }
    # - Per device data to be aggregated
    my ($per_interval_reads,$per_interval_writes,$per_interval_rbw,
        $per_interval_wbw, $per_interval_actv, $per_interval_wsvc_t,
        $per_interval_asvc_t, $count_for_avg, $max_actv, $max_wsvc_t,
        $max_asvc_t) = (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
    while ($interval_data =~ m/$iostat_dev_regex/gsmx) {
      #say join(",", values %+);
      my ($rps,$wps,$rbw,$wbw,$wait,$actv,$wsvc_t,$asvc_t,
          $pctw,$pctb,$device) =
        (@+{qw(rps wps rbw wbw wait actv wsvc_t asvc_t pctw pctb device)});
      # Do something with the data
      #say "WPS: $wps";
      $per_interval_reads    += $rps;
      $per_interval_writes   += $wps;
      $per_interval_rbw      += $rbw * $bw_multiplier;
      $per_interval_wbw      += $wbw * $bw_multiplier;
      # These we need maxes and avgs for
      $per_interval_actv     += $actv;
      $max_actv               = max($max_actv, $per_interval_actv);
      $per_interval_wsvc_t   += $wsvc_t;
      $max_wsvc_t             = max($max_wsvc_t, $per_interval_wsvc_t);
      $per_interval_asvc_t   += $asvc_t;
      $max_asvc_t             = max($max_asvc_t, $per_interval_asvc_t);
      $count_for_avg++;
    }
    # If the interval had no data (completely possible), then skip it
    if ($count_for_avg == 0) {
      next;
    }
    # Calculate averages for the fields that need it
    $per_interval_actv   /= $count_for_avg;
    $per_interval_wsvc_t /= $count_for_avg;
    $per_interval_asvc_t /= $count_for_avg;

    $line .=
        "$per_interval_reads,$per_interval_writes," .
        "$per_interval_rbw,$per_interval_wbw,$per_interval_actv," .
        "$max_actv,$per_interval_wsvc_t,$max_wsvc_t," .
        "$per_interval_asvc_t,$max_asvc_t";

    say $line;

    $intervals++;
  }

  say STDERR "Found $intervals INTERVALS";

  return \%iostat_data;
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

  my $parser     = PA::DateTime::Format::arcstat->new;
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
  my $time_regex     = $self->chosen_time_regex();

  my (@arcstat_data, $intervals);

  #
  #  Time  read  miss  miss%  dmis  dm%  pmis  pm%  mmis  mm%  arcsz     c
  #

  my $arcstat_regex =
    qr{ ^ \s+ (?<read>\d+(?:K|M|G)?) \s+ (?<miss>\d+(?:K|M|G)?) \s+
              (?<miss_pct>\d+)  \s+ (?<dmiss>\d+(?:K|M|G)?) \s+
              (?<dmiss_pct>\d+) \s+ (?<pmiss>\d+(?:K|M|G)?) \s+
              (?<pmiss_pct>\d+) \s+ (?<mmiss>\d+(?:K|M|G)?) \s+
              (?<mmiss_pct>\d+) \s+ (?<arcsz>\d+(?:K|M|G)?) \s+
              (?<arctgt>\d+(?:K|M|G)?) \n
      }smx;

  # Iterate over each stat interval, each on it's own line in the case of
  # arcstat
  while ($remaining_data =~ m{ $interval_regex }gsmx ) {
    my ($interval_data) = $+{interval_data};
    # Tear individual intervals into their respective:
    # - Timestamp in Excel preferred format of yyyy-MM-dd HH:mm:ss
    my $dt = $parser->parse_datetime($+{datetime});
    #$line .= "$+{datetime},";
    #$line .= $dt->strftime("%Y-%m-%d %H:%M:%S") . ",";
    my $formatted_dt = $dt->strftime("%H:%M:%S");

    push @$intervals_aref, [ $formatted_dt, [] ];
    my $interval_aref = $intervals_aref->[-1]->[1];

    # Remove the single interval we just matched
    $remaining_data =~ s{ $interval_regex }{}smx;

    while ($interval_data =~ m/$arcstat_regex/gsmx) {
      my $captured_stats =
        [ (@+{qw(read miss miss_pct dmiss dmiss_pct pmiss pmiss_pct mmiss
                 mmiss_pct arcsz argtgt)}) ] ;
      # Do something with the data
      push @$interval_aref, $captured_stats;
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
}

__PACKAGE__->meta->make_immutable;

1;
