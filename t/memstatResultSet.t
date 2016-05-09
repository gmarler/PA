
#
# INVOKE with:
# BASE_DIR=/tmp/test KEEP_DB=1 prove -lv t/memstatResultSet.t
#
use v5.20;

use Test::Most;
use Data::Dumper;
use Test::DBIx::Class
  -schema_class  => 'PA::Schema',
  -fixture_class => '::Population',
  -resultsets    => [ 'Host', 'Memstat' ],
  -traits        => 'Testpostgresql',
  #-connect_info  => {
  #  dsn => 'dbi:Pg:dbname=template1,host=127.0.0.1,port=15432',
  #  user => 'postgres',
  #  pass => '',
  #  on_connect_do => 'SET client_min_messages=WARNING;',
  #},
  qw(Host Memstat);

plan skip_all => 'only valid for schema version 8'
  if Schema->schema_version != 8;

#say Dumper( dump_settings );

fixtures_ok ['host', 'memstat'];

is Memstat->count, 1,
  'Got expected number of Memstat entries';

done_testing;
