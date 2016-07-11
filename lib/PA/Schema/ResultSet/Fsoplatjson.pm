package PA::Schema::ResultSet::Fsoplatjson;

use strict;
use warnings;
use 5.20.0;

# VERSION

use parent 'PA::Schema::ResultSet';

=method search_by_host

Search for Fsoplatjson data by host

=cut

sub search_by_host {
  my ($rs,$host_id) = @_;
  my ($schema) = $rs->result_source->schema;

  $schema->resultset('Fsoplatjson')->search({
      'me.host_fk' => $host_id,
    });
}


=method search_by_host_sorted

Search for Fsoplatjson data by host, sorted by ascending timestamp

=cut

sub search_by_fsoplatjson_sorted {
  my ($rs,$host_id) = @_;
  my ($schema) = $rs->result_source->schema;

  $schema->resultset('Fsoplatjson')->search({
      'me.host_fk' => $host_id,
    },
    { order_by => 'timestamp ASC',
      columns  => [
        # Turn the PostgreSQL timestamp into epoch seconds
        {
          'timestamp' =>
          \[
            'EXTRACT(epoch from timestamp) AS timestamp'
          ],
        },
        'interval_data',
      ],
    }
  );
}

=method search_by_fsoplatjson_on_date

Search for Fsoplatjson data by host, on a particular date, in a particular time zone

=cut

sub search_by_host_on_date {
  my ($rs,$host_id, $date, $time_zone) = @_;
  my ($schema) = $rs->result_source->schema;

  $schema->resultset('Fsoplatjson')->search({
      -and => [
        'me.host_fk' => $host_id,
        \[ 'DATE(timestamp AT TIME ZONE \'' . $time_zone . '\') = ?', $date ],
      ]
    },
    { order_by => 'timestamp ASC',
      columns  => [
        # Turn the PostgreSQL timestamp into epoch seconds
        {
          'timestamp' =>
          \[
            'EXTRACT(epoch from timestamp) AS timestamp'
          ],
        },
        'interval_data',
      ],
    }
  );
}

=method avail_dates

Extract the list of dates for which Memstat statistics are available

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


1;
