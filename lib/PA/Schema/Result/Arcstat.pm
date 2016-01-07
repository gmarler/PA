package PA::Schema::Result::Arcstat;

# VERSION

use strict;
use warnings;

use base 'DBIx::Class::Core';

__PACKAGE__->load_components(qw/ InflateColumn::DateTime /);
__PACKAGE__->table('arcstat');

__PACKAGE__->add_columns(
  'arcstat_id' => {
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
  # NOTE: All kstat sourced data should store snaptime, in addition to
  #       timestamp, to facilitate rate calculations
  'snaptime'  => {
    data_type         => 'bigint',
  },
  'buf_size'  => {
    data_type         => 'bigint',
  },
  'c'  => {
    data_type         => 'bigint',
  },
  'c_max'  => {
    data_type         => 'bigint',
  },
  'c_min'  => {
    data_type         => 'bigint',
  },
  'data_size'  => {
    data_type         => 'bigint',
  },
  'deleted'  => {
    data_type         => 'bigint',
  },
  'demand_data_hits'  => {
    data_type         => 'bigint',
  },
  'demand_data_misses'  => {
    data_type         => 'bigint',
  },
  'demand_metadata_hits'  => {
    data_type         => 'bigint',
  },
  'demand_metadata_misses'  => {
    data_type         => 'bigint',
  },
  # GAP
  'evict_mfu'  => {
    data_type         => 'bigint',
  },
  'evict_mru'  => {
    data_type         => 'bigint',
  },
  # GAP
  'hits'  => {
    data_type         => 'bigint',
  },
  # GAP
  'l2_hits'  => {
    data_type         => 'bigint',
  },
  # GAP
  'l2_misses'  => {
    data_type         => 'bigint',
  },
  'l2_persistence_hits'  => {
    data_type         => 'bigint',
  },
  'l2_read_bytes'  => {
    data_type         => 'bigint',
  },
  'l2_rw_clash'  => {
    data_type         => 'bigint',
  },
  'l2_size'  => {
    data_type         => 'bigint',
  },
  # GAP
  'memory_throttle_count'  => {
    data_type         => 'bigint',
  },
  'meta_limit'  => {
    data_type         => 'bigint',
  },
  'meta_max'  => {
    data_type         => 'bigint',
  },
  'meta_used'  => {
    data_type         => 'bigint',
  },
  'mfu_ghost_hits'  => {
    data_type         => 'bigint',
  },
  'mfu_hits'  => {
    data_type         => 'bigint',
  },
  'misses'  => {
    data_type         => 'bigint',
  },
  'mru_ghost_hits'  => {
    data_type         => 'bigint',
  },
  'mru_hits'  => {
    data_type         => 'bigint',
  },
  'mutex_miss'  => {
    data_type         => 'bigint',
  },
  'other_size'  => {
    data_type         => 'bigint',
  },
  'p'  => {
    data_type         => 'bigint',
  },
  'prefetch_behind_prefetch'  => {
    data_type         => 'bigint',
  },
  'prefetch_data_hits'  => {
    data_type         => 'bigint',
  },
  'prefetch_data_misses'  => {
    data_type         => 'bigint',
  },
  'prefetch_joins'  => {
    data_type         => 'bigint',
  },
  'prefetch_meta_size'  => {
    data_type         => 'bigint',
  },
  'prefetch_metadata_hits'  => {
    data_type         => 'bigint',
  },
  'prefetch_metadata_misses'  => {
    data_type         => 'bigint',
  },
  'prefetch_reads'  => {
    data_type         => 'bigint',
  },
  'prefetch_size'  => {
    data_type         => 'bigint',
  },
  # GAP
  'size'  => {
    data_type         => 'bigint',
  },
);

__PACKAGE__->set_primary_key('arcstat_id');
__PACKAGE__->belongs_to(
  'host_rs' => "PA::Schema::Result::Host",
  { 'foreign.host_id' => 'self.host_fk' } );


1;
