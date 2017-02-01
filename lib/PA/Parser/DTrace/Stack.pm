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


=method add_recurse

Recursive implementation for adding another frame to a stack

=cut

sub add_recurse {
  my ($self, $this, $frames, $value) = @_;

  my ($child);

  $this->{value} += $value;

  if (defined($frames) and scalar(@$frames)) {
    my $head = $frames->[0];
    if (exists($this->{children}->{$head})) {
      $child = $this->{children}->{$head};
    } else {
      $child = { name => $head, value => 0, children => {} };
      $this->{children}->{$head} = $child;
    }
    splice(@$frames,0,1);
    $self->add_recurse($child,$frames,$value);
  }
  return $this;
}

=method serialize_recurse

Recursive implementation for serializing an existing stack out into a data
structure that can be directly encoded into JSON

=cut

#
# The trick here is that serialization converts the children from hrefs to
# arefs, so that they'll more closely fit D3's JSON format requirements - this
# can probably be improved.
#
sub serialize_recurse {
  my ($self, $this) = @_;
  my ($result) = { name  => $this->{name},
                   value => $this->{value},
                 };

  my ($children) = [];

  foreach my $key (keys %{$this->{children}}) {
    push @$children, $self->serialize_recurse($this->{children}->{$key});
  }

  if (scalar(@$children)) {
    $result->{children} = $children;
  }

  return $result;
}




1;
