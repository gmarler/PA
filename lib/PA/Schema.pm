package PA::Schema;

use 5.20.0;
use warnings;

use base 'DBIx::Class::Schema';

our $VERSION = 2;

__PACKAGE__->load_namespaces(
  default_resultset_class => 'ResultSet',
);

1;
