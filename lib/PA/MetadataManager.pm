use strict;
use warnings;

package PA::MetadataManager;

# VERSION
#
# ABSTRACT: 

use namespace::autoclean;
use Moose;

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



1;
