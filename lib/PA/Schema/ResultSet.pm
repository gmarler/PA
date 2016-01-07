package PA::Schema::ResultSet;

# VERSION

use 5.20.0;
use warnings;

use parent 'DBIx::Class::ResultSet';

__PACKAGE__->load_components(
  'Helper::ResultSet::IgnoreWantarray',
  'Helper::ResultSet::Me',
);

1;
