package PA::Schema::Result;

use parent 'DBIx::Class::Core';

__PACKAGE__->load_components(
  'Helper::Row::RelationshipDWIM',
);

1;