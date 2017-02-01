package PA::DateTime::Format::DTrace;

use strict;
use warnings;
use v5.20;

use DateTime::Format::Builder (
  # Accepted Formats:
  # 2014 Nov  5 11:41:47  (output from DTrace's %Y format for walltimestamp)
  # OR
  # Epoch seconds
  parsers => {
    parse_datetime => [
      {
        # Parse epoch secs
        params => [qw( epoch )],
        regex  => qr/^ (\d+) $/x,
        constructor => [ 'DateTime', 'from_epoch' ],
      },
      {
        # 2014 Nov  5 11:41:47  (output from DTrace's %Y format for walltimestamp)
        strptime => '%Y %B %d %H:%M:%S',
      },
      {
        regex => qr/^(\d{4}) \s+ (\w{3}) \s+ (\d+) \s+
                     (\d+):(\d+):(\d+)$/x,
        params => [qw( year month day hour minute second )],
      },
      {
        # HH:MM:SS with no date provided
        length => 8,
        regex  => qr/^(\d{2}):(\d{2}):(\d{2})$/x,
        params => [qw( hour minute second )],
        extra  => { time_zone => 'floating' },
        preprocess  => \&_add_in_fake_date,
      }
    ]
  }
);

# To be used when only hour:minute:second has been detected with no date
sub _add_in_fake_date {
  my %args = @_;
  my ($date, $p) = @args{qw( input parsed )};
  # Yeah, the month and day have to be between 1 and 12
  @{$p}{qw( year month day )} = (0, 1, 1);
  return $date;
}



1;
