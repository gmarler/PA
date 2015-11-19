package PA::Schema::Result::Host;

use strict;
use warnings;

use base 'DBIx::Class::Core';

__PACKAGE__->table('host');

__PACKAGE__->add_columns(
  'host_id' => {
    data_type         => 'integer',
    is_auto_increment => 1,
  },
  'name' => {
    data_type => 'varchar',
    size      => '32',
  },
  'time_zone' => {
    data_type => 'varchar',
    size      => '64',
  },
);

__PACKAGE__->set_primary_key('host_id');

__PACKAGE__->has_many(
  'vmstat_rs'  => 'PA::Schema::Result::vmstat',
  {'foreign.host_fk' => 'self.host_id'} );

1;
