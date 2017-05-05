package PA::Parser::iostat;

use strict;
use warnings;
use v5.20;

# VERSION
# ABSTRACT: Parser for iostat output variants

use Moose;
use Data::Dumper;
use JSON::MaybeXS               qw(encode_json decode_json);
use PA::DateTime::Format::pgstat;
use namespace::autoclean;

# with 'PA::Parser';

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

has 'datetime_interval_regex' => (
  is         => 'ro',
  isa        => 'RegexpRef',
  default    =>
    sub {
      qr{^
         (?<datetime>
             \d{4} \s+        # year
             (?:Jan|Feb|Mar|Apr|May|Jun|
                Jul|Aug|Sep|Oct|Nov|Dec
             ) \s+
             \d+ \s+          # day of month
             \d+:\d+:\d+ \s+  # HH:MM:DD  (24 hour clock)
             \n
         )
         (?<interval_data> .+?)
         (?=
           (?:
             \d{4} \s+        # year
             (?:Jan|Feb|Mar|Apr|May|Jun|
                Jul|Aug|Sep|Oct|Nov|Dec
             ) \s+
             \d+ \s+          # day of month
             \d+:\d+:\d+ \s+  # HH:MM:DD  (24 hour clock)
             \n
             |
             \z
           )
         )
        }smx;
    },
);


=head2 _parse_interval

Parse data for a single time interval

=cut

sub _parse_interval {
  my ($self,$data) = @_;

  say STDERR "Received " . length($data) . " bytes of iostat data!";
  say "Epoch,Read IOPs,Write IOPs";

  my (%iostat_data, $bw_multiplier, $intervals);

  my $iostat_header_regex =
    qr{ (?<epoch_time>\d+) \n
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
    my ($epoch_time)    = $+{epoch_time};
    my ($interval_data) = $+{interval_data};
    my ($per_interval_reads,$per_interval_writes) = (0, 0);

    while ($interval_data =~ m/$iostat_dev_regex/gsmx) {
      #say join(",", values %+);
      my ($rps,$wps,$rbw,$wbw,$wait,$actv,$wsvc_t,$asvc_t,
          $pctw,$pctb,$device) =
        (@+{qw(rps wps rbw wbw wait actv wsvc_t asvc_t pctw pctb device)});
      $rbw *= $bw_multiplier;
      $wbw *= $bw_multiplier;
      # TODO: Do something with the data
      #say "WPS: $wps";
      $per_interval_reads += $rps;
    }
    say "$epoch_time,$per_interval_reads,$per_interval_writes";
  }
  say STDERR "Found $intervals INTERVALS";

  return \%iostat_data;
}

__PACKAGE__->meta->make_immutable;

1;
