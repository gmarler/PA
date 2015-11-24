package PA::Schema::Candy;

use 5.20.0;
use warnings;

use parent 'DBIx::Class::Candy';

use base { 'PA::Schema::Result' }
sub perl_version { 20 }
sub autotable { 1 }

1;
