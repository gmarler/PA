package PA::Parser::DTrace::Stack;

use strict;
use warnings;
use v5.20;

# VERSION
# ABSTRACT: Parser for DTrace stack()/ustack() output variants

use Moose;
use namespace::autoclean;

has 'epoch_interval_regex' => (
  is         => 'ro',
  isa        => 'RegexpRef',
  default    =>
    sub {
      qr/ (?<epoch> ^\d+) \n
          (?<interval_stacks> .+?)
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
         (?<interval_stacks> .+?)
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

has 'stack_regex' => (
  is         => 'ro',
  isa        => 'RegexpRef',
  default    =>
    sub {
      qr{
         (?<stack> .+?)
         ^   \s+? (?<stack_count> \d+) \n
        }smx;
    },
);





1;
