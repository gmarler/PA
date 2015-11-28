package PA::Schema::ResultSet::Host;

use 5.20.0;
use warnings;
use parent 'PA::Schema::ResultSet';

sub search_by_name { $_[0]->search({ $_[0]->me . name => $_[1] }) }
sub find_by_name { $_[0]->search_by_name($_[1])->single }

1;
