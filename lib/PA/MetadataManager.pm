use strict;
use warnings;

package PA::MetadataManager;

# VERSION
#
# ABSTRACT: 

use Moose;
use namespace::autoclean;

has 'log'        => ( is       => 'ro',
                      isa      => 'Str',
                      required => 1,
                    );

has 'depth'      => ( is       => 'ro',
                      isa      => 'Str',
                      required => 1,
                    );

has 'metadata'   => ( is       => 'ro',
                      isa      => 'HashRef',
                    );

has 'directory'  => ( is       => 'ro',
                      isa      => 'Str',
                      required => 1,
                    );


=method get( $type, $instance )

Get the specified type and instance for the metdata

=cut

sub get {
  my ($self, $type, $instance) = @_;

  return $self->metadata->{$type}->{$instance};
}

=method list( $type )

List the metadata for the given type

=cut

sub list {
  my ($self, $type) = @_;

  my @list = keys %{$self->metadata->{$type}};

  return \@list;
}

=method list_types

List the types for the given metadata

=cut

sub list_types {
  my ($self) = shift;

  my @types = keys %{$self->metadata};

  return \@types;
}

1;
