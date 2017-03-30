package PA::DateTime::Format::pgstat;

use strict;
use warnings;
use v5.20;

use DateTime::Format::Builder (
  # Accepted Formats:
  # Thu Mar 30 14:58:03 EDT 2017 (output from pgstat's -T d option)
  # OR
  # Epoch seconds (output from pgstat's -T u option)
  parsers => {
    parse_datetime => [
      {
        # Parse epoch secs
        params => [qw( epoch )],
        regex  => qr/^ (\d+) $/x,
        constructor => [ 'DateTime', 'from_epoch' ],
      },
      {
        # instead of just specifying a strptime pattern in a scalar, pass an
        # href to in turn be passed directly to DTF::Strptime->new()
        strptime =>
          {
            # Thu Mar 30 14:58:03 EDT 2017 (output from pgstat's -T d option)
            pattern => '%a %b %d %H:%M:%S %Z %Y',
            # TODO: Confirm this works, and add more as needed
            zone_map => { EDT => '-0500' },
          }
      },
      # TODO: Test whether we can just ditch this one...
      {
        regex => qr/^(\d{4}) \s+ (\w{3}) \s+ (\d+) \s+
                     (\d+):(\d+):(\d+)$/x,
        params => [qw( year month day hour minute second )],
      },
    ]
  }
);


1;
