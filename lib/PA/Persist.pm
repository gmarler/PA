use strict;
use warnings;

package PA::Persist;

# VERSION
#
# ABSTRACT: Facilities for PA data persistence

use Moose;
use namespace::autoclean;

# A "stash" is a collection of named buckets containing data.  This is the main
# abstraction exposed by the persistence service to the rest of PA.  PA::Stash
# implements a stash, including routines to save and load it from disk.

# 
has 'modules' =>
  ( is       => 'ro',
    isa      => 'HashRef',
  );








1;

