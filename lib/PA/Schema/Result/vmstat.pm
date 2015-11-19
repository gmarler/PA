package PA::Schema::Result::vmstat;

use strict;
use warnings;

use base 'DBIx::Class::Core';

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
  },
  'freemem' => {
    data_type => 'bigint',
  },
);

__PACKAGE__->set_primary_key('vmstat_id');

__PACKAGE__->has_many(
  'host_rs' => "PA::Schema::Result::Host",
  { 'foreign.host_id' => 'self.host_fk' } );

1;
