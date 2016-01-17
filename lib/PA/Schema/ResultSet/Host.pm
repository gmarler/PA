package PA::Schema::ResultSet::Host;

use strict;
use warnings;
use 5.20.0;

# VERSION

use parent 'PA::Schema::ResultSet';

=method search_by_name

Search for host by its hostname

=cut

sub search_by_name { $_[0]->search({ $_[0]->me . name => $_[1] }) }

=method find_by_name

Find single host by name

=cut

sub find_by_name { $_[0]->search_by_name($_[1])->single }

1;
