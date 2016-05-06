

use Test::Most;
use Test::DBIx::Class
  -schema_class  => 'PA::Schema',
  -connect_info  =>
  ['dbi=template1;host=127.0.0.1;port=25432','postgres',''],
  -fixture_class => '::Population',
  -traits        => 'Testpostgresql',
  qw(Host);

plan skip_all => 'only valid for schema version 8'
  if Schema->schema_version != 8;

fixtures_ok ['host'];

is Host->count, 2,
  'Got expected number of hosts';

done_testing;
