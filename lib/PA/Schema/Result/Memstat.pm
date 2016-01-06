package PA::Schema::Result::Memstat;

use strict;
use warnings;

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
  # The type of this memstat data row; this is an enumeration of the following:
  # free_cachelist, defdump_prealloc, exec_and_libs, free_freelist,
  # zfs_file_data, anon, page_cache, zfs_metadata, kernel, total
  #
  'type'   => {
    data_type         => 'varchar(16)',
  }
  #
  'bytes'  => {
    data_type         => 'bigint',
  },
  'page_count'  => {
    data_type         => 'integer',
  },
  'pct_of_total'  => {
    data_type         => 'smallint',
  },
);

__PACKAGE__->set_primary_key('memstat_id');
__PACKAGE__->belongs_to(
  'host_rs' => "PA::Schema::Result::Host",
  { 'foreign.host_id' => 'self.host_fk' } );


1;
