package PA::Schema::Candy;

use v5.20;
use warnings;

# VERSION

use parent 'DBIx::Class::Candy';

sub base { 'PA::Schema::Result' }

sub perl_version { 20 }
sub autotable { 1 }

1;
