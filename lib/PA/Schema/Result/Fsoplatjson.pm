package PA::Schema::Result::Fsoplatjson;

use strict;
use warnings;
use v5.20;

# VERSION
#
# Filesystem Operations Latency Table, stored as JSON
#

use base 'DBIx::Class::Core';
use Data::Dumper;

__PACKAGE__->load_components(qw/ InflateColumn::DateTime /);
__PACKAGE__->table('fsoplatjson');

__PACKAGE__->add_columns(
  'fsoplatjson_id' => {
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
  # Filesystem operations stored purely as JSON:
  'interval_data' => {
    data_type         => 'jsonb',
  },
);


__PACKAGE__->set_primary_key('fsoplatjson_id');
# This constraint currently doesn't work because it's possible for the same
# timestamp to show up twice, even though that shouldn't be possible
# TODO: Hunt down and kill this bug
# __PACKAGE__->add_unique_constraint(['host_fk','timestamp','fstype',]);

__PACKAGE__->belongs_to(
  'host_rs' => "PA::Schema::Result::Host",
  { 'foreign.host_id' => 'self.host_fk' } );

1;
