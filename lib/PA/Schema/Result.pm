package PA::Schema::Result;

use strict;
use warnings;

# VERSION

use parent 'DBIx::Class::Core';

__PACKAGE__->load_components(
  'Helper::Row::RelationshipDWIM',
);

1;
