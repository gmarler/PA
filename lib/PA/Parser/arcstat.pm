package PA::Parser::arcstat;

use strict;
use warnings;
use v5.20;

# VERSION
# ABSTRACT: Parser for iostat output variants

use Moose;
use Data::Dumper;
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

has 'chosen_interval_regex' => (
  is         => 'rw',
  isa        => 'RegexpRef|Undef',
  default    => undef,
  lazy       => 1,
);

has 'chosen_interval_regex_no_eof' => (
  is         => 'rw',
  isa        => 'RegexpRef|Undef',
  default    => undef,
  lazy       => 1,
);

# Which datetime/epoch regex matches the data passed in
has 'chosen_time_regex' => (
  is         => 'rw',
  isa        => 'RegexpRef|Undef',
  builder    => '_build_chosen_time_regex',
  lazy       => 1,
);

# matches on interval boundary, but warning, will match incomplete intervals.
# This regex is only intended to be used when you know for certain that you've
# read the complete file/datastream containing the stat output.
has 'epoch_interval_regex' => (
  is         => 'ro',
  isa        => 'RegexpRef',
  lazy       => 1,
  builder    => '_build_epoch_interval_regex',
);

# guaranteed to match exactly on interval boundary, to be used most of the time,
# due to partial intervals at the end of each datastream read up to the point
# where the entire file has been read in
has 'epoch_interval_regex_no_eof' => (
  is         => 'ro',
  isa        => 'RegexpRef',
  lazy       => 1,
  builder    => '_build_epoch_interval_regex_no_eof',
);

# matches on interval boundary, but warning, will match incomplete intervals.
# This regex is only intended to be used when you know for certain that you've
# read the complete file/datastream containing the stat output.
has 'datetime_interval_regex' => (
  is         => 'ro',
  isa        => 'RegexpRef',
  lazy       => 1,
  builder    => '_build_datetime_interval_regex',
);

# guaranteed to match exactly on interval boundary, to be used most of the time,
# due to partial intervals at the end of each datastream read up to the point
# where the entire file has been read in
has 'datetime_interval_regex_no_eof' => (
  is         => 'ro',
  isa        => 'RegexpRef',
  lazy       => 1,
  builder    => '_build_datetime_interval_regex_no_eof',
);

has 'epoch_regex' => (
  is         => 'ro',
  isa        => 'RegexpRef',
  default    =>
    sub {
      # Epoch secs take at least 10 digits
      qr/ (?: ^\d{10,}+ ) /smx;
    },
);


# Thu Mar 30 14:58:03 EDT 2017 (output from iostat's -T d option)
# pattern => '%a %b %d %H:%M:%S %Z %Y',
has 'datetime_regex' => (
  is         => 'ro',
  isa        => 'RegexpRef',
  default    =>
  sub {
    qr{
       (
         (?^ix:wednesday|saturday|thursday|tuesday|friday|monday|sunday|
               fri|mon|sat|sun|thu|tue|wed)
       )
       \s+
       (
         (?^ix:september|december|february|november|january|october|august|
               april|march|july|june|apr|aug|dec|feb|jan|jul|jun|mar|may|nov|
               oct|sep
         )
       )
       \s+
       (
         (?^:[0-9 ]?(?^:(?:[0-9])))
       )
       \s+
       ( (?^:[0-9 ]?(?^:(?:[0-9]))))
       \:
       ( (?^:[0-9 ]?(?^:(?:[0-9]))))
       \:
       ( (?^:[0-9 ]?(?^:(?:[0-9]))))
       \s+
       (
         (?^:[a-zA-Z]{1,6}|[\-\+](?^:(?:[0-9])){2})
       )
       \s+
       (
         (?^:(?^:(?:[0-9])){4})
       )
    }smx;
  },
);

sub _build_epoch_interval_regex {
  my ($self) = @_;
  my ($epoch_regex) = $self->epoch_regex;

  return
    qr/
          # We call this datetime too, even though it's epoch
        (?<datetime>
         $epoch_regex   # Don't include newline in capture
        )
          \n            # Newline after epoch datetime
        (?<interval_data> .+?)
        (?= (?: $epoch_regex \n | \z ) )
      /smx;
}

sub _build_epoch_interval_regex_no_eof {
  my ($self) = @_;
  my ($epoch_regex) = $self->epoch_regex;

  return
    qr/
          # We call this datetime too, even though it's epoch
        (?<datetime>
         $epoch_regex   # Don't include newline in capture
        )
          \n            # Newline after epoch datetime
        (?<interval_data> .+?)
        (?= (?: $epoch_regex \n ) )
      /smx;
}

sub _build_datetime_interval_regex {
  my ($self) = @_;
  my ($datetime_regex) = $self->datetime_regex;

  return
  qr{^
     (?<datetime>
      $datetime_regex   # Don't include newline in capture
     )
       \n               # Newline after datetime
     (?<interval_data> .+?)
     (?=
       (?:
         $datetime_regex
         \n
         |
         \z
       )
     )
    }smx;
}

sub _build_datetime_interval_regex_no_eof {
  my ($self) = @_;
  my ($datetime_regex) = $self->datetime_regex;

  return
  qr{^
     (?<datetime>
      $datetime_regex   # Don't include newline in capture
     )
       \n               # Newline after datetime
     (?<interval_data> .+?)
     (?=
       (?:
         $datetime_regex
         \n
       )
     )
    }smx;
}


sub BUILD {
  my ($self) = @_;

  $self->epoch_interval_regex();
  $self->epoch_interval_regex_no_eof();
  $self->datetime_interval_regex();
  $self->datetime_interval_regex_no_eof();
  $self->chosen_time_regex();
  $self->chosen_interval_regex();
  $self->chosen_interval_regex_no_eof();
}


=head2 _build_chosen_time_regex

Determine whether the intervals are delimited by epoch or locale based
date/timestamps

=cut

sub _build_chosen_time_regex {
  my ($self) = @_;

  my $datastream = $self->datastream;

  # Carve off the first 1 MB of the data
  my ($slice);
  $datastream->read($slice, 1048576);
  # Reset datastream back to beginning
  $datastream->seek(0, 0);

  my $epoch_regex                    = $self->epoch_regex;
  my $datetime_regex                 = $self->datetime_regex;

  my $epoch_interval_regex           = $self->epoch_interval_regex;
  my $epoch_interval_regex_no_eof    = $self->epoch_interval_regex_no_eof;
  my $datetime_interval_regex        = $self->datetime_interval_regex;
  my $datetime_interval_regex_no_eof = $self->datetime_interval_regex_no_eof;

  #say STDERR $slice;
  #say STDERR $datetime_regex;
  # Search through the carved off data slice to see which regex matches, then
  # store that one away as the one to use throughout the parsing of intervals
  if ($slice =~ m/$epoch_interval_regex/gsmx) {
    say STDERR "Matched epoch regex";
    $self->chosen_time_regex($epoch_regex);
    $self->chosen_interval_regex($epoch_interval_regex);
    $self->chosen_interval_regex_no_eof($epoch_interval_regex_no_eof);
  } elsif ($slice =~ m/$datetime_interval_regex/gsmx) {
    say STDERR "Matched datetime regex";
    $self->chosen_time_regex($datetime_regex);
    $self->chosen_interval_regex($datetime_interval_regex);
    $self->chosen_interval_regex_no_eof($datetime_interval_regex_no_eof);
  } else {
    say STDERR "NO DATE/TIME REGEX MATCHED!";
    return; # undef
  }
}


=head2 _parse_interval

Parse data for a single time interval

=cut

sub _parse_interval {
  my ($self) = @_;
  my ($output);

  my $parser     = PA::DateTime::Format::iostat->new;
  my $datastream = $self->datastream;
  # TODO: Read data off 1 MB at a time, parsing and returning the
  #       info as needed
  #$datastream->read($output, 1024 * 1024);
  my ($data) = do { local $/; <$datastream>; };

  say STDERR "PROCESSING " . length($data) . " BYTES OF DATA";

  my $interval_regex = $self->chosen_interval_regex();
  my $time_regex     = $self->chosen_time_regex();

  # TODO: Move this to a method that aggregates over parsed intervals
  say "Time (Epoch or DateTime),Read IOPs,Write IOPs,Read Bytes,Write Bytes," .
      "actv,MAX actv,wsvc_t,MAX wsvc_t,asvc_t,MAX asvc_t";

  my (%iostat_data, $bw_multiplier, $intervals);

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

=head2 parse_interval

Parse data for several time intervals

=cut

sub parse_intervals {
  my ($self) = @_;
  my ($new_data);
  my ($intervals_aref) = [];
  my (@captured_intervals);

  my $mpxio_devs_only = $self->mpxio_devs_only;
  my $datastream = $self->datastream;
  # If we've previously exhausted the datastream, there's nothing left to do
  return if ($datastream->eof);   # undef

  my $parser     = PA::DateTime::Format::iostat->new;
  my $remaining_data = $self->remaining_data;

  # Read data off 1 MB at a time, parsing and returning the
  # info as available in complete intervals
  $datastream->read($new_data, 1024 * 1024);
  # Append the data we just read to the previously remaining data, if any
  $remaining_data .= $new_data;

  my ($interval_regex);
  if ($datastream->eof) {
    $interval_regex = $self->chosen_interval_regex();
  } else {
    $interval_regex = $self->chosen_interval_regex_no_eof();
  }
  my $time_regex     = $self->chosen_time_regex();

  my (@iostat_data, $bw_multiplier, $intervals);

  my $iostat_header_regex =
    qr{
        \s+ extended \s+ device \s+ statistics [^\n]+ \n
        \s+ r/s \s+ w/s \s+ (?<bwunit>k|M)r/s \s+ (k|M)w/s \s+ wait \s+
            actv \s+ wsvc_t \s+ asvc_t \s+ \%w \s+ \%b \s + device \n
      }smx;

  my $iostat_dev_regex =
    qr{ ^ \s+ (?<rps>[\d\.]+) \s+ (?<wps>[\d\.]+) \s+ (?<rbw>[\d\.]+)  \s+
              (?<wbw>[\d\.]+) \s+ (?<wait>[\d\.]+) \s+ (?<actv>[\d\.]+) \s+
              (?<wsvc_t>[\d\.]+) \s+ (?<asvc_t>[\d\.]+) \s+ (?<pctw>\d+) \s+
              (?<pctb>\d+) \s+ (?<device>[^\n]+) \n
      }smx;

  ## Parse all of the complete intervals just read in
  #@captured_intervals = $remaining_data =~ m{ $interval_regex }gsmx;

  #if (@captured_intervals) {
  #} else {
  #  return;  # undef
  #}

  # Iterate over each iostat interval, separated by timestamp of some form
  while ($remaining_data =~ m{ $interval_regex }gsmx ) {
    my ($interval_data) = $+{interval_data};
    # Tear individual intervals into their respective:
    # - Timestamp in Excel preferred format of yyyy-MM-dd HH:mm:ss
    my $dt = $parser->parse_datetime($+{datetime});
    #$line .= "$+{datetime},";
    #$line .= $dt->strftime("%Y-%m-%d %H:%M:%S") . ",";
    my $formatted_dt = $dt->strftime("%H:%M:%S");
    my $epoch = $dt->epoch();

    push @$intervals_aref, [ $formatted_dt, [] ];
    my $interval_aref = $intervals_aref->[-1]->[1];

    # Remove the single interval we just matched
    $remaining_data =~ s{ $interval_regex }{}smx;
    #say "REMAINING TO PARSE: " . length($remaining_data);

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
    } else {
      # If we don't match the header, we should probably skip this
    }

    while ($interval_data =~ m/$iostat_dev_regex/gsmx) {
      my $captured_stats =
        [ (@+{qw(rps wps rbw wbw wait actv wsvc_t asvc_t pctw pctb device)}) ] ;
      if ($mpxio_devs_only and
          not ($+{device} =~ m{^c\d+ t[0-9A-F]{32} d\d+}x)) {
        # If we're only interested in MPxIO devices, skip this one
        #say "SKIPPING: $+{device}";
        next;
      }
      # Do something with the data
      push @$interval_aref, $captured_stats;

      # multiply the read/write throughput by the appropriate multiplier
      $interval_aref->[-1]->[2] *= $bw_multiplier;
      $interval_aref->[-1]->[3] *= $bw_multiplier;
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

  #return \@iostat_data;
  return $intervals_aref;
}

=head2 parse_aggregate_intervals

Parse data for several time intervals and aggregate appropriately for the
statistics, producing a single line of output for each interval in CSV format.

=cut

sub parse_aggregate_intervals {
  my ($self) = shift;

  # Aggregate over each interval
  say "Time (Epoch or DateTime),Read IOPs,Write IOPs,Read Bytes,Write Bytes," .
      "actv,MAX actv,wsvc_t,MAX wsvc_t,asvc_t,MAX asvc_t";

  my ($arefs);
  while ($arefs = $self->parse_intervals()) {
    foreach my $interval_data (@$arefs) {
      my ($line) = '';
      # - Per device data to be aggregated
      my ($per_interval_reads,$per_interval_writes,$per_interval_rbw,
          $per_interval_wbw, $per_interval_actv, $per_interval_wsvc_t,
          $per_interval_asvc_t, $count_for_avg, $max_actv, $max_wsvc_t,
          $max_asvc_t) = (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);

      $line .= $interval_data->[0] . ",";
      # TODO: create a constant as an accessor into each array
      foreach my $devstat (@{$interval_data->[1]}) {
        # Aggregate all of the device info for this interval into a single line
        $per_interval_reads    += $devstat->[0];
        $per_interval_writes   += $devstat->[1];
        $per_interval_rbw      += $devstat->[2];
        $per_interval_wbw      += $devstat->[3];
        # These we need maxes and avgs for
        $per_interval_actv     += $devstat->[5];
        $max_actv               = max($max_actv, $per_interval_actv);
        $per_interval_wsvc_t   += $devstat->[6];
        $max_wsvc_t             = max($max_wsvc_t, $per_interval_wsvc_t);
        $per_interval_asvc_t   += $devstat->[7];
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
    }
  }

}

=head2 parse_aggregate_intervals_by_path

Parse data for several time intervals and aggregate appropriately by path for
the statistics, producing a separate column per unique path for each interval in
CSV format.

=cut

sub parse_aggregate_intervals_by_path {
  my ($self) = shift;

}



__PACKAGE__->meta->make_immutable;

1;
