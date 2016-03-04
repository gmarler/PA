package PA::Schema::ResultSet::Memstat;

use strict;
use warnings;
use 5.20.0;

# VERSION

use parent 'PA::Schema::ResultSet';

=method search_by_host

Search for Memstat data by host

=cut

sub search_by_host {
  my ($rs,$host_id) = @_;
  my ($schema) = $rs->result_source->schema;

  $schema->resultset('Memstat')->search({
      'me.host_fk' => $host_id,
    });
}


=method search_by_host_sorted

Search for memstat data by host, sorted by ascending timestamp

=cut

sub search_by_host_sorted {
  my ($rs,$host_id) = @_;
  my ($schema) = $rs->result_source->schema;

  $schema->resultset('Memstat')->search({
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
        'free_cachelist_bytes', 'defdump_prealloc_bytes',
        'exec_and_libs_bytes', 'free_freelist_bytes',
        'zfs_file_data_bytes', 'anon_bytes', 'page_cache_bytes',
        'zfs_metadata_bytes', 'kernel_bytes', 'total_bytes',
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
