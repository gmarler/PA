package PA::Schema::ResultSet;

use strict;
use warnings;
use 5.20.0;

# VERSION

use parent 'DBIx::Class::ResultSet';

__PACKAGE__->load_components(
  'Helper::ResultSet::IgnoreWantarray',
  'Helper::ResultSet::Me',
);

1;
