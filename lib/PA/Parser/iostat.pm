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

  my (%iostat_data);

  #say "\nBEGIN:\n" . $data . "\nEND:\n";
  my $iostat_sys_regex =
    qr{^ ID \s+ RELATIONSHIP \s+ HW \s+ SW \s+ CPUS \n
       ^ (?: \s+)? (?<id>\d+) \s+ System \s+ \( Software \) \s+ \- \s+
            (?<sw_util> [\d\.]+ )\% \s+ (?<cpus> \d+ \- \d+) \n
      }smx;

  while ($data =~ m{ $iostat_sys_regex }gsmx ) {
    $iostat_data{util} = "$+{sw_util}" . "%";
  }

  return \%iostat_data;
}

__PACKAGE__->meta->make_immutable;

1;
