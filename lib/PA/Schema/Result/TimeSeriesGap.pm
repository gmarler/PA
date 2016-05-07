package PA::Schema::Result::TimeSeriesGap;

use strict;
use warnings;

# VERSION

use base 'DBIx::Class::Core';

__PACKAGE__->load_components(qw/ InflateColumn::DateTime /);
__PACKAGE__->table('timeseriesgap');

__PACKAGE__->add_columns(
  'entity_fk'   => {
    data_type         => 'integer',
  },
  'timestamp' => {
    data_type => 'timestamptz',
    timezone => 'UTC',
  },
  'value'   => {
    data_type         => 'bigint',
  },
);

1;
