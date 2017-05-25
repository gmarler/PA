package PA::Schema::MigrationScript;

use strict;
use warnings;
use v5.20;

# VERSION

# Taken from
# https://metacpan.org/pod/distribution/DBIx-Class-Migration/lib/DBIx/Class/Migration/Tutorial/Catalyst.pod,
# which shows how to integrate DBIx::Class::Migration with Catalyst's
# ConfigLoader
#

use Moose;
use PA::Web;

extends 'DBIx::Class::Migration::Script';

=method defaults

Set the schema to use to be from Catalyst's idea of the Schema

=cut

sub defaults {
  schema => PA::Web->model('DB')->schema,
}


__PACKAGE__->meta->make_immutable;
__PACKAGE__->run_if_script;


1;

