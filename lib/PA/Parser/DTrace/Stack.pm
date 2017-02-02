package PA::Parser::DTrace::Stack;

use strict;
use warnings;
use v5.20;

# VERSION
# ABSTRACT: Parser for DTrace stack()/ustack() output variants

use Moose;
use List::MoreUtils             qw(first_index);
use Data::Dumper;
use JSON::MaybeXS               qw(encode_json decode_json);
use PA::DateTime::Format::DTrace;
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


=method interval_parse_recurse

Given a raw stack, parse and return each reduced interval.

=cut

sub interval_parse_recurse {
  my ($self, $raw_stack) = @_;

  # TODO: See which regex matches, then start using that one
  #
  my $interval_regex = $self->datetime_interval_regex;
  my $stack_regex    = $self->stack_regex;
  my ($match_count);

  while ($raw_stack =~ m{$interval_regex}gsmx) {

    $match_count++;
    say "DATETIME " . $+{datetime};
    #say "STACKS   " . $+{interval_stacks};

    my $interval_stacks = $+{interval_stacks};
    my $interval_href = { name => 'root', value => 0, children => {} };
    while ($interval_stacks =~ m{$stack_regex}gsmx) {
      say "STACK:\n$+{stack}";
      say "STACK_COUNT: $+{stack_count}";
      my ($stack) = $+{stack};
      # Tear down stack
      # - split on newlines
      # - AND *reverse* to get order right for visualizing
      my (@stack) = reverse split /\n/, $stack;
      # - delete blanks lines at beginning of the array
      my $index = List::MoreUtils::first_index {$_ ne ''} @stack;
      if (defined($index)) {
        splice(@stack,0,$index);
      }
      # - delete blanks lines at end of the array
      #   Apparently unnecessary due to regex above
      #   NOTE: below is BROKEN - fix if we later determine it is actually
      #         needed
      #$index = List::MoreUtils::first_index {$_ ne ''} reverse @stack;
      #if (defined($index)) {
      #  say "INDEX: $index";
      #  #splice(@stack,-1,$index);
      #}
      foreach my $frame (@stack) {
        # - Strip off leading whitespace
        $frame =~ s{^\s+}{};
        # - strip off +0x.+
        $frame =~ s{\+.+}{};
        # - Replace blank line in middle of stack with '-'
        #   That's the dividing mark between user/kernel stacks
        $frame =~ s{^$}{\-};
      }
      say Dumper(\@stack);
      my $intermediate =
        $self->add_recurse($interval_href, \@stack, $+{stack_count});
      my $serialized =
        $self->serialize_recurse($intermediate);
      $Data::Dumper::Indent = 1;
      say Dumper($serialized);
      my ($json) = encode_json($serialized);
    }
  }

}

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
