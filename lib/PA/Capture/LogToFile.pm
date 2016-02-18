package PA::Capture::LogToFile;

use strict;
use warnings;

# VERSION
#
# ABSTRACT: Role that provides common capture logging to file behavior

use v5.20;

use Moose::Role;
use MooseX::Types::Moose qw(Bool Str Int Undef HashRef ArrayRef);
use Moose::Util::TypeConstraints;
use namespace::autoclean;
use Data::Dumper;

with 'MooseX::Log::Log4perl';

#############################################################################
# Attributes
#############################################################################

has [ 'logdir' ] => (
  is       => 'ro',
  isa      => '(Str|Undef)',
  required => 1,
);

has [ 'logfile' ] => (
  is       => 'ro',
  isa      => '(Str|Undef)',
  required => 1,
);

#############################################################################
# Methods
#############################################################################





1;
