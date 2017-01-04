package PA::Parser::DTraceStack;

use strict;
use warnings;
use v5.20;

# VERSION
#
use Moose;
use namespace::autoclean;
use Data::Dumper;
use DateTime              qw();
use DateTime::TimeZone    qw();
use DateTime::Format::Builder (
  # Epoch seconds
  parsers => {
    parse_datetime => [
      {
        # parse epoch secs into a DateTime in the UTC time zone
        # TODO Test that the timezone *IS* in UTC, and not floating or somesuch
        params      => [ qw( epoch ) ],
        regex       => qr/^ (\d+) $/x,
        constructor => [ 'DateTime', 'from_epoch' ],
      },
    ]
  }
);

with 'PA::Parser';

sub _build_dt_regex {
  # TODO: This data needs to be printed by DTrace's nanosecond walltimestamp,
  #       truncated to seconds
  # which *should be* epoch secs
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
  return &parse_datetime;
}

# TODO: implement _parse_interval() ?

__PACKAGE__->meta->make_immutable;

1;
