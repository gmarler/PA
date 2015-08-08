package PA::Stash;

use strict;
use warnings;

# VERSION
#
# ABSTRACT: Facilities for PA data persistence

use Moose;
use namespace::autoclean;
use PA;
use CHI;

with 'MooseX::Log::Log4perl';

#
# A "stash" is a collection of named buckets containing data.  This is the main
# abstraction exposed by the persistence service to the rest of PA.  PA::Stash
# implements a stash, including routines to save and load it from disk.
#
# The stash version covers the directory layout and metadata formats.  The
# bucket version covers the format of each individual bucket data file.  For
# examples:
# 
#    - If we wanted to change the data format in the future to use msgpack
#      instead of raw bytes, we would rev bucket_version_major, since old
#      software should not attempt to read the new file.
# 
#    - If we wanted to change the metadata files to use msgpack instead of
#      JSON, we'd rev stash_version_major, since old software should not
#      even attempt to read any of the metadata files.
# 
#    - If we wanted to change the metadata format in the future to provide an
#      optional "format" member that specified what format the actual data was
#      stored in, we would probably rev stash_version_minor, since old
#      software could still read new metadata files, but we would probably also
#      rev bucket_version_major to indicate that the data should not be read
#      by older software.

# stash format major version
has 'stash_version_major' =>
  ( is       => 'ro',
    isa      => 'Int',
    default  => 1;
  );

# stash format minor version
has 'stash_version_minor' =>
  ( is       => 'ro',
    isa      => 'Int',
    default  => 0;
  );

# bucket format major version
has 'bucket_version_major' =>
  ( is       => 'ro',
    isa      => 'Int',
    default  => 1;
  );

# bucket format minor version
has 'bucket_version_minor' =>
  ( is       => 'ro',
    isa      => 'Int',
    default  => 0;
  );

# See the block comment at the top of this file.  This implementation of a
# stash stores data in a filesystem tree as follows:
# 
#    $stash_root/
#        stash.json		Global stash metadata (version)
#        bucket-XX/		Directory for bucket XX
#            metadata.json	Metadata for bucket XX (version)
#            data		Data for bucket XX
#        ...			More buckets

has 'creator' =>
  ( is       => 'ro',
    isa      => 'HashRef',
    builder  => sub {
      my ($self) = shift;

      PA::deep_copy($sysinfo);
    };
  );

has 'busy' =>
  ( is       => 'rw',
    isa      => 'HashRef',
    default  => sub { return {}; },
  );

has 'cleanup' =>
  ( is       => 'rw',
    isa      => 'ArrayRef',
    default  => sub { return []; },
  );

has 'rootdir' =>
  ( is       => 'ro',
    isa      => 'Str',
    required => 1,
    builder  => _build_rootdir,
    clearer  => _clear_rootdir,
  );

sub _build_rootdir {
  my ($self) = shift;

  if ($self->buckets) {
    $self->log->warn("Stash already initialized");
  }
  if ($self->rootdir) {
    $self->log->warn("Stash already initializing");
  }

  $self->log->info("Loading stash from " . $self->rootdir);

  return $self->rootdir;
}

after _build_rootdir => sub {
  my ($self) = shift;

  $stages = [
    loadInit,
    loadbuckets,
    loadFini,
  ];

  PA::run_stages($stages, undef,
                 sub {
                   my ($err) = shift;
                   if ($err) {
                     $self->_clear_rootdir;
                   }
                 }
                );
};

=method

PA::Stash->new( rootdir => '/tmp/stash' );

=cut



1;

