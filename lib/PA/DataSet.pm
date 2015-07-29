use strict;
use warnings;

package PA::DataSet;

use Moose;

# ABSTRACT: Data collected by aggregator for instrumentation over time period.

=head1 DESCRIPTION

A dataset represents data collected by the aggregator for a particular
instrumentation over a specified period of time.  The base class PA::Dataset
implements common functions like tracking the number of sources reporting for
this instrumentation, but PA::Dataset itself is an abstract class and doesn't
manage the actual data.  That's handled by four subclasses:

=for :list
* PA::DataSet::Scalar
scalar values
* PA::DataSet::Decomp
simple discrete decompositions
* PA::DataSet::HeatmapScalar
heatmap values with no additional decomposition
* PA::DataSet::HeatmapDecomp
heatmap values with an additional decomposition

Additionally, the PA::DataSet::Simple class is used as a role class of the
first three of these to provide functionality common to these
implementations.

The methods provided by PA::DataSet itself (and thus available for all
datasets) include:

=for :list
* update(source, time, datum)
Add new data to this dataset.
* expireBefore(exptime)
Throws out data older than 'exptime'.
* dataForTime(start, duration)
Returns the raw data representation for the specified data point.
* nsources()
Returns the total number of distinct sources which have ever reported data
for this instrumentation.
* nreporting(start, duration)
Returns the minimum number of sources which have reported data over the
specified interval.  See nreporting() for details.
* maxreporting(start, duration)
Returns the maximum number of sources which have reported data over the
specified interval.  See maxreporting() for details.
* normalizeInterval(start, duration)
Returns an interval described with 'start_time' and 'duration'
properties that's aligned with this dataset's granularity.
* stash()
Returns a serialized representation of the dataset's data for passing
to unstash().
* unstash(data)
Given a serialized representation as returned by a previous call to stash(),
load the specified data into this dataset.  This data will be combined
with other data already stored in the dataset.

Heatmap datasets provide additional methods to retrieve data that's stored
more efficiently for the heatmap generator:

=for :list
* keysForTime(start, duration)
Returns an array of values of the discrete decomposition field that have
non-zero values during the specified interval.
* total()
Returns the data for all keys.  That is, the data at each time index is the sum
of data over all keys at that time.
* dataForKey(key)
Returns the data for a specific key.

Note that the data accessors for the heatmap objects do not reference a
particular time.  They return data for all time.  This avoids having to
create a new object for each request for the specific time interval in the
request.  This works because PA::Vis::Heatmap can consume much more data than it
actually needs as long as the caller specifies which data to look at.

=cut

has granularity => { is => 'ro',
                     isa => 'Int',
                   };

has nsources    => { is => 'ro',
                     isa => 'Int',
                   };

has sources     => { is => 'ro',
                     isa => 'HashRef',
                   };

has reporting   => { is => 'ro',
                     isa => 'HashRef',
                   };

has major_vers  => { is => 'ro',
                     isa => 'Int',
                     default => 0,
                   };

has minor_vers  => { is => 'ro',
                     isa => 'Int',
                     default => 1,
                   };

=method update(source, time, datum)

Save the specified datum for the specified time
index into this dataset.  If data already exists for this time index, the new
datum will be combined with (added to) the existing data.

This base class implementation updates our state about which sources are
reporting data for this instrumentation and then delegates the actual data
handling to subclasses via aggregateValue().

=cut

sub update {
  my ($self, $source, $rawtime, $datum) = @_;

  my $time;

  

}


1;
