package PA::Schema::Result::Memstat;

use strict;
use warnings;

# VERSION

use base 'DBIx::Class::Core';

__PACKAGE__->load_components(qw/ InflateColumn::DateTime /);
__PACKAGE__->table('memstat');

__PACKAGE__->add_columns(
  'memstat_id' => {
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
  #
  # Groups of 3
  #
  'free_cachelist_bytes'  => {
    data_type         => 'bigint',
  },
  'free_cachelist_page_count'  => {
    data_type         => 'integer',
  },
  'free_cachelist_pct_of_total'  => {
    data_type         => 'smallint',
  },
  #
  'defdump_prealloc_bytes'  => {
    data_type         => 'bigint',
  },
  'defdump_prealloc_page_count'  => {
    data_type         => 'integer',
  },
  'defdump_prealloc_pct_of_total'  => {
    data_type         => 'smallint',
  },
  #
  'exec_and_libs_bytes'  => {
    data_type         => 'bigint',
  },
  'exec_and_libs_page_count'  => {
    data_type         => 'integer',
  },
  'exec_and_libs_pct_of_total'  => {
    data_type         => 'smallint',
  },
  #
  'free_freelist_bytes'  => {
    data_type         => 'bigint',
  },
  'free_freelist_page_count'  => {
    data_type         => 'integer',
  },
  'free_freelist_pct_of_total'  => {
    data_type         => 'smallint',
  },
  #
  'zfs_file_data_bytes'  => {
    data_type         => 'bigint',
  },
  'zfs_file_data_page_count'  => {
    data_type         => 'integer',
  },
  'zfs_file_data_pct_of_total'  => {
    data_type         => 'smallint',
  },
  #
  'anon_bytes'  => {
    data_type         => 'bigint',
  },
  'anon_page_count'  => {
    data_type         => 'integer',
  },
  'anon_pct_of_total'  => {
    data_type         => 'smallint',
  },
  #
  'page_cache_bytes'  => {
    data_type         => 'bigint',
  },
  'page_cache_page_count'  => {
    data_type         => 'integer',
  },
  'page_cache_pct_of_total'  => {
    data_type         => 'smallint',
  },
  #
  'zfs_metadata_bytes'  => {
    data_type         => 'bigint',
  },
  'zfs_metadata_page_count'  => {
    data_type         => 'integer',
  },
  'zfs_metadata_pct_of_total'  => {
    data_type         => 'smallint',
  },
  #
  'kernel_bytes'  => {
    data_type         => 'bigint',
  },
  'kernel_page_count'  => {
    data_type         => 'integer',
  },
  'kernel_pct_of_total'  => {
    data_type         => 'smallint',
  },
  #
  'total_bytes'  => {
    data_type         => 'bigint',
  },
  'total_page_count'  => {
    data_type         => 'integer',
  },
  'total_pct_of_total'  => {
    data_type         => 'smallint',
  },

);

__PACKAGE__->set_primary_key('memstat_id');
__PACKAGE__->belongs_to(
  'host_rs' => "PA::Schema::Result::Host",
  { 'foreign.host_id' => 'self.host_fk' } );


1;
