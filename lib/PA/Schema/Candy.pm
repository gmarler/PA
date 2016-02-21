package PA::Schema::Candy;

use v5.20;
use warnings;

# VERSION

use parent 'DBIx::Class::Candy';

=method base

Set the base class for our Candy schema

=cut

sub base { 'PA::Schema::Result' }

=method perl_version

Set the Perl version we need to operate properly

=cut

sub perl_version { 20 }

=method autotable

Whether autotables are enabled (YES)

=cut

sub autotable { 1 }

1;
