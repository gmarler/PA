package PA::Web::Model::DB;

use strict;
use warnings;
use v5.20;

# VERSION

use base 'Catalyst::Model::DBIC::Schema';

__PACKAGE__->config(
    schema_class => 'PA::Schema',
    # This will be overridden by the custom config for prod or dev or test
    connect_info =>
      ['DBI:Pg:dbname=template1;host=localhost;port=0','postgres',''],
);

=head1 NAME

PA::Web::Model::DB - Catalyst DBIC Schema Model

=head1 SYNOPSIS

See L<PA::Web>

=head1 DESCRIPTION

L<Catalyst::Model::DBIC::Schema> Model using schema L<PA::Schema>

=head1 GENERATED BY

Catalyst::Helper::Model::DBIC::Schema - 0.65

=head1 AUTHOR

Gordon Marler

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
