package PA::Schema::Result::Vmstat;

use strict;
use warnings;

use base 'DBIx::Class::Core';

__PACKAGE__->load_components(qw/ InflateColumn::DateTime /);
__PACKAGE__->table('vmstat');

__PACKAGE__->add_columns(
  'vmstat_id' => {
    data_type         => 'integer',
    is_auto_increment => 1,
  },
  'host_fk'   => {
    data_type         => 'integer',
  },
  'timestamp' => {
    data_type => 'timestamptz',
    timezone => 'UTC',
  },
  'freemem' => {
    data_type => 'bigint',
  },
);

__PACKAGE__->set_primary_key('vmstat_id');
# This constraint currently doesn't work because it's possible for the same
# timestamp to show up twice, even though that shouldn't be possible
# TODO: Hunt down and kill this bug
# __PACKAGE__->add_unique_constraint(['host_fk','timestamp']);

__PACKAGE__->belongs_to(
  'host_rs' => "PA::Schema::Result::Host",
  { 'foreign.host_id' => 'self.host_fk' } );

1;
