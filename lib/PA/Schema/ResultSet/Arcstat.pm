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

1;
