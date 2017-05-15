package PA::Parser::iostat;

use strict;
use warnings;
use v5.20;

# VERSION
# ABSTRACT: Parser for iostat output variants

use Moose;
use Data::Dumper;
use List::Util                  qw(max);
use JSON::MaybeXS               qw(encode_json decode_json);
use PA::DateTime::Format::iostat;
use Moose::Util::TypeConstraints;
use namespace::autoclean;

# with 'PA::Parser';

# Define these, so we can use them in type unions below as needed
class_type 'IO::Handle';
class_type 'IO::File';
class_type 'IO::All::File';
class_type 'IO::Uncompress::Bunzip2';

has 'datastream' => ( is       => 'rw',
                      isa      => 'IO::Handle | IO::File | IO::All::File | IO::Uncompress::Bunzip2',
                      required => 1,
                    );

has 'chosen_interval_regex' => (
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

has 'epoch_regex' => (
  is         => 'ro',
  isa        => 'RegexpRef',
  default    =>
    sub {
      # Epoch secs take at least 10 digits
      qr/ (?: ^\d{10,}+ ) /smx;
    },
);

has 'epoch_interval_regex' => (
  is         => 'ro',
  isa        => 'RegexpRef',
  lazy       => 1,
  builder    => '_build_epoch_interval_regex',
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

has 'datetime_interval_regex' => (
  is         => 'ro',
  isa        => 'RegexpRef',
  lazy       => 1,
  builder    => '_build_datetime_interval_regex',
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

sub BUILD {
  my ($self) = @_;

  $self->epoch_interval_regex();
  $self->datetime_interval_regex();
  $self->chosen_time_regex();
  $self->chosen_interval_regex();
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

  my $epoch_regex             = $self->epoch_regex;
  my $datetime_regex          = $self->datetime_regex;

  my $epoch_interval_regex    = $self->epoch_interval_regex;
  my $datetime_interval_regex = $self->datetime_interval_regex;

  #say STDERR $slice;
  #say STDERR $datetime_regex;
  # Search through the carved off data slice to see which regex matches, then
  # store that one away as the one to use throughout the parsing of intervals
  if ($slice =~ m/$epoch_interval_regex/gsmx) {
    say STDERR "Matched epoch regex";
    $self->chosen_time_regex($epoch_regex);
    $self->chosen_interval_regex($epoch_interval_regex);
  } elsif ($slice =~ m/$datetime_interval_regex/gsmx) {
    say STDERR "Matched datetime regex";
    $self->chosen_time_regex($datetime_regex);
    $self->chosen_interval_regex($datetime_interval_regex);
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

  my $parser     = PA::DateTime::Format::iostat->new;
  my $datastream = $self->datastream;
  my ($data) = do { local $/; <$datastream>; };

  say STDERR "PROCESSING " . length($data) . " BYTES OF DATA";

  my $interval_regex = $self->chosen_interval_regex();
  my $time_regex     = $self->chosen_time_regex();

  say "Time (Epoch or DateTime),Read IOPs,Write IOPs,Read Bytes,Write Bytes," .
      "actv,MAX actv,wsvc_t,MAX wsvc_t,asvc_t,MAX asvc_t";

  my (%iostat_data, $bw_multiplier, $intervals);

  my $iostat_header_regex =
    qr{ (?<time> $time_regex ) \n
        \s+ extended \s+ device \s+ statistics [^\n]+ \n
        \s+ r/s \s+ w/s \s+ (?<bwunit>k|M)r/s \s+ (k|M)w/s \s+ wait \s+
            actv \s+ wsvc_t \s+ asvc_t \s+ \%w \s+ \%b \s + device \n
      }smx;

  my $iostat_header_regex2 =
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
    $line .= $dt->strftime("%Y-%m-%d %H:%M:%S") . ",";
    # - Headers
    #   Need to extract read/write multiplier, as this can change over
    #   time, if metric collection is stopped/restarted
    if ($interval_data =~ m{ $iostat_header_regex2 }smx) {
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
      $rbw *= $bw_multiplier;
      $wbw *= $bw_multiplier;
      # TODO: Do something with the data
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

__PACKAGE__->meta->make_immutable;

1;
