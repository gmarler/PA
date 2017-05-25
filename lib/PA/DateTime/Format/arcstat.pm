package PA::DateTime::Format::iostat;

use strict;
use warnings;
use v5.20;

use DateTime::Format::Builder (
  # Accepted Formats:
  # 14:58:03 (output from arcstat.pl)
  parsers => {
    parse_datetime => [
      {
        # instead of just specifying a strptime pattern in a scalar, pass an
        # href to in turn be passed directly to DTF::Strptime->new()
        strptime =>
          {
            # 14:58:03 (output from arcstat.pl)
            pattern => '%H:%M:%S',
          }
      },
    ]
  }
);


1;
