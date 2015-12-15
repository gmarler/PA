package PA::Schema::ResultSet::Arcstat;

use 5.20.0;
use warnings;
use parent 'PA::Schema::ResultSet';

#sub search_by_name {
#  $_[0]->search({ $_[0]->me . name => $_[1] })
#}

#sub find_by_name { $_[0]->search_by_name($_[1])->single }

sub search_by_host {
  my ($rs,$host_id) = @_;
  my ($schema) = $rs->result_source->schema;

  $schema->resultset('Arcstat')->search({
      'me.host_fk' => $host_id,
    });
}

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

# SELECT ((hits - prev_hits) / ( (snaptime::float - prev_snaptime::float) / 1000000000.0 ))::bigint AS hit_rate_per_sec
# FROM
#   (SELECT snaptime, hits,
#           lag(hits) OVER (ORDER BY snaptime ASC) as prev_hits,
#           lag(snaptime) OVER (ORDER BY snaptime ASC) as prev_snaptime
#    FROM
#      arcstat
#    ORDER BY
#      snaptime ASC) as w1;

1;
