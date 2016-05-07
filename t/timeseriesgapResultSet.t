
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
# The necessary special cases which must be detected and handled by special
# methods in the ResultSet class for each table are:
# 1. A gap at the beginning of a day.
#    - Check to make sure that there isn't a data point at midnight. If such a
#      datapoint exists, then this case does not apply.
#    - Then find out if the distance between midnight and the first data point
#      is greater than gap_threshold.  If so, then place a timestamp exactly 1
#      second less than the first datapoint with a NaN value.
# 2. Gaps in the middle of the day (the most common case)
#    - Find all rows that have > gap_threshold between them.  For each gap
#      - Place a timestamp 1 second after the starting timestamp with a NaN
#        value.
#      - Place a timestamp 1 second before the ending timestamp with a NaN
#        value.
# 3. A gap at the end of a day
#    - Find the last timestamp of the day.  If it's within gap_threshold of
#      11:59:59, then this case does not apply.
#    - Otherwise, insert a row with a timestamp 1 second after the last data
#      point row, with a NaN value.
#
# With this data provided, D3 can do the rest and visualize gaps in data
# properly.

plan skip_all => 'only valid for schema version 8'
  if Schema->schema_version != 8;

#say Dumper( dump_settings );

fixtures_ok ['timeseriesgap'];

is TimeSeriesGap->count, 1,
  'Got expected number of TimeSeriesGap entries';

done_testing;
