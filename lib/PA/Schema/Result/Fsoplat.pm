package PA::Schema::Result::Fsoplat;

use strict;
use warnings;
use v5.20;

# VERSION
#
# Filesystem Operations Latency Table
#

use base 'DBIx::Class::Core';
use Data::Dumper;

__PACKAGE__->load_components(qw/ InflateColumn::DateTime /);
__PACKAGE__->table('fsoplat');

__PACKAGE__->add_columns(
  'fsoplat_id' => {
    data_type         => 'integer',
    is_auto_increment => 1,
  },
  'host_fk'   => {
    data_type         => 'integer',
  },
  'timestamp' => {
    data_type         => 'timestamptz',
    timezone          => 'UTC',
  },
  # Filesystem operation:
  # lookup, map, readlink, remove, access, create, write, read, etc
  'fsop' => {
    data_type         => 'varchar',
    size              => '12',
  },
  # Filesystem type: zfs, ufs, dev fs, tmpfs, etc
  'fstype' => {
    data_type         => 'varchar',
    size              => '8',
  },
  'latrange' => {
    data_type         => 'int8range',
  },
  'count' => {
    data_type         => 'integer',
  },
);

__PACKAGE__->inflate_column('latrange', {
  inflate => sub {
    my ($raw_value_from_db, $result_object) = @_;
    #say "Need to inflate this from latrange: \n" . Dumper( $raw_value_from_db );
    my ($start, $end, $start_inclusive, $end_inclusive) = (undef, undef, 0, 0);
    if ($raw_value_from_db =~ /^\[/) {
      $start_inclusive++;
    }
    if ($raw_value_from_db =~ /\]$/) {
      $end_inclusive++;
    }
    #say "START INCLUSIVE: $start_inclusive";
    #say "  END INCLUSIVE: $end_inclusive";
    ($start, $end) = $raw_value_from_db =~ m/^[\[(](\d+),(\d+)[)\]]$/;
    if (not $start_inclusive) {
      $start += 1;
    }
    if (not $end_inclusive) {
      $end -= 1;
    }
    return [ $start+0, $end+0 ];
  },
  deflate => sub {
    my ($inflated_value_from_user, $result_object) = @_;
    # We receive an array ref, so we turn it into a range type string
    # expression for PostgreSQL to chew on
    "[ $inflated_value_from_user->[0], $inflated_value_from_user->[1] ]";
  },
});

__PACKAGE__->set_primary_key('fsoplat_id');
# This constraint currently doesn't work because it's possible for the same
# timestamp to show up twice, even though that shouldn't be possible
# TODO: Hunt down and kill this bug
# __PACKAGE__->add_unique_constraint(['host_fk','timestamp','fstype',]);

__PACKAGE__->belongs_to(
  'host_rs' => "PA::Schema::Result::Host",
  { 'foreign.host_id' => 'self.host_fk' } );

#talosian  Is there an example of specifying the use of PostgreSQL Range Types in DBIC?
#talosian	Or should I ask if PostgreSQL Range Types are supported in DBIC?
#ilmari	talosian: DBIC mostly doesn't care
#ilmari	just specify the right data_type, e.g. 'tstzrage' and use the
#        appropriate operators with
#        ->search($rangecolumn => { $operator => $value  })
#ilmari	you might want to write an inflatecolumn component if you want
#        something more useful than the string representation out
#talosian	Assume int8range - so just use int8range as data_type then
#talosian	Just not clear on how to do row creation...  As in, specify
#          the range itself, what with the inclusive/exclusive bound notation
#          and all
#talosian	And how to interpret what the DB gives back on search_rs and such
#ilmari	use strings with the syntax in the postgres documentation
#ilmari	talosian: for discrete ranges (where open vs. closed doesn't matter)
#        you could write an inflatecolumn component that gives you
#        [$lower, $upper] instead
#talosian	ilmari: Wonderful! Exactly what I'm in need of.
#ilmari	talosian: note that ->search can't deflate, so you'd have to stringify
#        yourself
#ilmari	or use { column => \['@@ int8range(?, ?)' $lower, $upper)}
#ilmari	ah, the "standard form" is lower bound inclusive, upper bound exclusive
#ilmari	so that's the range $lower..$upper-1 in perl notation
#ilmari	but you could do int8range(?,?,'[]') to make it inclusive on both ends


1;
