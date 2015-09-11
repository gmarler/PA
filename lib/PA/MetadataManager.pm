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


sub get {
  my ($self, $type, $instance) = @_;

  return $self->metadata->{$type}->{$instance};
}

sub list {
  my ($self, $type) = @_;

  my @list = keys %{$self->metadata->{$type}};

  return \@list;
}

sub list_types {
  my ($self) = shift;

  my @types = keys %{$self->metadata};

  return \@types;
}

1;
