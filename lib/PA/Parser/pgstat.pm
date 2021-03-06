package PA::Parser::pgstat;

use strict;
use warnings;
use v5.20;

# VERSION
# ABSTRACT: Parser for pgstat output variants

use Moose;
use Data::Dumper;
use JSON::MaybeXS               qw(encode_json decode_json);
use PA::DateTime::Format::pgstat;
use namespace::autoclean;

with 'PA::Parser';

sub _build_dt_regex {
  return qr{^
            (?: \d+     # Epoch secs
                \n
            )
           }smx;
}

sub _build_strptime_pattern {
  return "%s";
}

sub _build_datetime_parser {
  #return &parse_datetime;
  return &PA::DateTime::Format::pgstat->parse_datetime;
}


=head2 _parse_interval

Parse data for a single time interval

=cut

sub _parse_interval {
  my ($self,$data) = @_;

  my (%pgstat_data);

  #say "\nBEGIN:\n" . $data . "\nEND:\n";
  my $pgstat_sys_regex =
    qr{^ ID \s+ RELATIONSHIP \s+ HW \s+ SW \s+ CPUS \n
       ^ (?: \s+)? (?<id>\d+) \s+ System \s+ \( Software \) \s+ \- \s+
            (?<sw_util> [\d\.]+ )\% \s+ (?<cpus> \d+ \- \d+) \n
      }smx;

  while ($data =~ m{ $pgstat_sys_regex }gsmx ) {
    $pgstat_data{util} = "$+{sw_util}" . "%";
  }

  return \%pgstat_data;
}

__PACKAGE__->meta->make_immutable;

1;
