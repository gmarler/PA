package PA::Schema::ResultSet::Arcstat;

use strict;
use warnings;
use 5.20.0;

# VERSION

use parent 'PA::Schema::ResultSet';

#sub search_by_name {
#  $_[0]->search({ $_[0]->me . name => $_[1] })
#}

#sub find_by_name { $_[0]->search_by_name($_[1])->single }

=method search_by_host

Search for Arcstat data by host

=cut

sub search_by_host {
  my ($rs,$host_id) = @_;
  my ($schema) = $rs->result_source->schema;

  $schema->resultset('Arcstat')->search({
      'me.host_fk' => $host_id,
    });
}

=method search_by_host_sorted

Search for ARC stat data by host, sorted by ascending timestamp

=cut

sub search_by_host_sorted {
  my ($rs,$host_id) = @_;
  my ($schema) = $rs->result_source->schema;

  $schema->resultset('Arcstat')->search({
      'me.host_fk' => $host_id,
    },
    { order_by => 'timestamp ASC',
      columns  => [ 'timestamp', 'hits', 'misses', ],
    }
  );
}

=method host_hit_rate

Get the hit rate for the given host

=cut

sub host_hit_rate {
  my ($rs,$host_id) = @_;
  my ($schema) = $rs->result_source->schema;

  $rs->search(
    {
      'me.host_fk'    => $host_id,
    },
    {
      columns => [
        'snaptime',
        'hits',
        {
          'prev_snaptime' =>
          \[
            'lag(snaptime) OVER (ORDER BY snaptime ASC) AS prev_snaptime'
           ],
          'prev_hits' =>
          \[
            'lag(hits) OVER (ORDER BY hits ASC) AS prev_hits'
           ],

        },
      ],
      order_by => { -asc => [ 'snaptime' ] },
    },
  )
  ->as_subselect_rs
  ->search(
    { 'prev_snaptime' => { '!=', undef } },
    {
      columns => [
        {
          'hit_rate_per_sec' =>
          \[
             '((hits - prev_hits)::float / ' .
             ' ((snaptime - prev_snaptime)::float / 1000000000.0) )::bigint ' .
             'AS hit_rate_per_sec'
           ],
        },
      ],
    },
  );
}


=method stat_rate( $stat )

Extract rate per time interval for the specific ARC statistic

=cut

sub stat_rate {
  my ($rs,$stat) = @_;
  my ($schema) = $rs->result_source->schema;

  # Validate that the stat's name is the name of an available column in the table:
  #
  unless ($rs->result_source->has_column( $stat )) {
    die "There is no $stat column in this table";
  }

  $rs->search(undef,
    {
      columns => [
        'timestamp',
        'snaptime',
        $stat,
        {
          'prev_snaptime' =>
          \[
            'lag(snaptime) OVER (ORDER BY snaptime ASC) AS prev_snaptime'
           ],
          'prev_hits' =>
          \[
            "lag( $stat ) OVER (ORDER BY $stat ASC) AS prev_${stat}"
           ],

        },
      ],
      order_by => { -asc => [ 'snaptime' ] },
    },
  )
  ->as_subselect_rs
  ->search(
    { 'prev_snaptime' => { '!=', undef } },
    {
      columns => [
        'timestamp',
        {
          'rate_per_sec' =>
          \[
             "(($stat - prev_${stat})::float / " .
             ' ((snaptime - prev_snaptime)::float / 1000000000.0) )::bigint ' .
             'AS rate_per_sec'
           ],
        },
      ],
      order_by => { -asc => [ 'timestamp' ] },
    },
  );
}


# To fill out the date/time picker in a web interface, we'll need to display
# what date/time ranges are available for selection in the begin/end range.
#
# Here are thoughts on how to do this with PostgreSQL:
#
# Beginning dates for which data is available in a table for a particular host:
# SELECT DISTINCT to_char(timestamp, 'YYYY-MM-DD') from arcstat where host_fk=6;
#
# Hours during a day where data is available:
#  SELECT DISTINCT to_char(timestamp, 'HH24') AS hours
#  FROM arcstat
#  WHERE host_fk=6 AND (to_char(timestamp, 'YYYY-MM-DD') = $selected_date)
#  ORDER BY hours ASC;
#
# Minutes during a day in the individual hour where data is available:
# SELECT DISTINCT to_char(timestamp, 'MI') AS mins
# FROM arcstat
# WHERE host_fk=6 AND
#       (to_char(timestamp, 'YYYY-MM-DD HH24') = '2015-12-15 23')
# ORDER BY mins ASC;
#
# Seconds during a day in the individual hour/minute where data is available:
# SELECT DISTINCT to_char(timestamp, 'SS') AS secs
# FROM arcstat
# WHERE host_fk=6 AND
#      (to_char(timestamp, 'YYYY-MM-DD HH24:MI') = '2015-12-15 23:51')
# ORDER BY secs ASC;
#
# Ending queries are all the same except for an additional predicate to ensure
# that only date/times *later than* the beginning one are selected.

=method avail_dates

Extract the list of dates for which ARC statistics are available

=cut

sub avail_dates {
  my ($rs) = @_;

  $rs->search(undef,
    {
      columns => [
        {
          'date' =>
          \[ "to_char(timestamp, 'YYYY-MM-DD')" ],
        },
      ],
      order_by => { -asc => 'timestamp' },
      distinct => 1,
    },
  );
}

=method avail_hours_for_date

Given a date, return the list of hours that have ARC stat data available

=cut

sub avail_hours_for_date {
  my ($rs,$selected_date) = @_;

  $rs->search(
    # Cast the timestamp column to date
    \['CAST(timestamp AS DATE) = ?', $selected_date ],
    {
      columns => [
        {
          'hour' =>
          \[ "to_char(timestamp, 'HH24')" ],
        },
      ],
      order_by => { -asc => 'timestamp' },
      distinct => 1,
    },
  );
}


=method avail_mins_for_date_hour

Given a date and an hour, return list of minutes for which ARC stat data is
available.

=cut

sub avail_mins_for_date_hour {
  my ($rs,$selected_date,$selected_HH) = @_;

  $rs->search(
    # Cast the timestamp column to date
    \['(CAST(timestamp AS DATE) = ?) AND (EXTRACT(HOUR FROM timestamp) = ?)',
      $selected_date, $selected_HH ],
    {
      columns => [
        {
          'min' =>
          \[ "to_char(timestamp, 'MI')" ],
        },
      ],
      order_by => { -asc => 'timestamp' },
      distinct => 1,
    },
  );
}


1;
