package PA::Parser::iostat;

use strict;
use warnings;
use v5.20;

# VERSION
# ABSTRACT: Parser for iostat output variants

use Moose;
use Data::Dumper;
use JSON::MaybeXS               qw(encode_json decode_json);
use PA::DateTime::Format::iostat;
use namespace::autoclean;

# with 'PA::Parser';

# Which datetime/epoch regex matches the data passed in
has 'chosen_interval_regex' => (
  is         => 'rw',
  isa        => 'RegexpRef|Undef',
  default    => undef,
);

has 'epoch_interval_regex' => (
  is         => 'ro',
  isa        => 'RegexpRef',
  default    =>
    sub {
      qr/ (?<epoch> ^\d+) \n
          (?<interval_data> .+?)
          (?= (?: ^ \d+ \n | \z ) )
        /smx;
    },
);

  # Thu Mar 30 14:58:03 EDT 2017 (output from iostat's -T d option)
  # pattern => '%a %b %d %H:%M:%S %Z %Y',
my $datetime_regex =
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

has 'datetime_interval_regex' => (
  is         => 'ro',
  isa        => 'RegexpRef',
  default    =>
    sub {
      qr{^
         (?<datetime>
          $datetime_regex
           \n
         )
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
    },
);

=head2 _choose_datetime_regex

Determine whether the intervals are delimited by epoch or locale based
date/timestamps

=cut

sub _choose_datetime_regex {
  my ($self,$data) = @_;

  say STDERR "Received " . length($data) . " bytes of iostat data!";
  # Carve off the first 1 MB of the data
  my ($slice) = substr( $data, 0, 1048576 );

  my $epoch_interval_regex = $self->epoch_interval_regex;
  my $datetime_interval_regex = $self->datetime_interval_regex;

  #say STDERR $slice;
  #say STDERR $datetime_regex;
  # Search through the carved off data slice to see which regex matches, then
  # store that one away as the one to use throughout the parsing of intervals
  if ($slice =~ m/$epoch_interval_regex/gsmx) {
    say STDERR "Matched epoch regex";
    $self->chosen_interval_regex($epoch_interval_regex);
  } elsif ($slice =~ m/$epoch_interval_regex/gsmx) {
    say STDERR "Matched datetime regex";
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
  my ($self,$data) = @_;

  my $time_regex = $self->chosen_interval_regex();

  say STDERR "Received " . length($data) . " bytes of iostat data!";
  say "Time (Epoch or DateTime),Read IOPs,Write IOPs,Read Bytes,Write Bytes," .
      "actv,wsvc_t,asvc_t";

  my (%iostat_data, $bw_multiplier, $intervals);

  my $iostat_header_regex =
    qr{ (?<time> $time_regex ) \n
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

  # Iterate over the iostat headers, and the many device stats between each
  while ($data =~ m{ $iostat_interval_regex }gsmx ) {
    $intervals++;
    # Check whether BandWidth Units are in KB or MB
    if ($+{bwunit} eq "k") {
      $bw_multiplier = 1024;
    } elsif ($+{bwunit} eq "M") {
      $bw_multiplier = 1024 * 1024;
    }
    my ($time)          = $+{time};
    my ($interval_data) = $+{interval_data};
    my ($per_interval_reads,$per_interval_writes,$per_interval_rbw,
        $per_interval_wbw, $per_interval_actv, $per_interval_wsvc_t,
        $per_interval_asvc_t) = (0, 0, 0, 0, 0, 0, 0);

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
      $per_interval_actv     += $actv;
      $per_interval_wsvc_t   += $wsvc_t;
      $per_interval_asvc_t   += $asvc_t;
    }
    say "$epoch_time,$per_interval_reads,$per_interval_writes," .
        "$per_interval_rbw,$per_interval_wbw,$per_interval_actv," .
        "$per_interval_wsvc_t,$per_interval_asvc_t";
  }
  say STDERR "Found $intervals INTERVALS";

  return \%iostat_data;
}

__PACKAGE__->meta->make_immutable;

1;
