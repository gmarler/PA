
#
# INVOKE with:
# BASE_DIR=/tmp/test KEEP_DB=1 prove -lv t/timeseriesgapResultSet.t
#
use v5.20;

use Test::Most;
use Data::Dumper;
use Test::DBIx::Class
  -schema_class  => 'PA::Schema',
  -fixture_class => '::Population',
  -resultsets    => [ 'TimeSeriesGap' ],
  -traits        => 'Testpostgresql',
  #-connect_info  => {
  #  dsn => 'dbi:Pg:dbname=template1,host=127.0.0.1,port=15432',
  #  user => 'postgres',
  #  pass => '',
  #  on_connect_do => 'SET client_min_messages=WARNING;',
  #},
  qw(TimeSeriesGap);

# This test is meant to prove out the concepts for creating proper result sets
# for any table that contains time series with possible gaps throughout a given
# day.
# The important item is to properly bound gaps in a time series that exceed a
# given gap_threshold, which can differ for each database table.  Since this
# data is to be visualized via D3.js, which can demarcate gaps with NaN values
# associated with timestamps, the bounding will be performed by taking
# the following steps:
#
# The necessary special cases which must be detected and handled are:
# 1. A gap at the beginning of a day
# 2. Gaps in the middle of the day (the most common case)
# 3. A gap at the end of a day
#

plan skip_all => 'only valid for schema version 8'
  if Schema->schema_version != 8;

#say Dumper( dump_settings );

fixtures_ok ['timeseriesgap'];

is TimeSeriesGap->count, 1,
  'Got expected number of TimeSeriesGap entries';

done_testing;
