use strict;
use warnings;

package PA;

# VERSION
# ABSTRACT: Performance Analytics Suite

require Exporter;

use Solaris::uname;
use Clone                          qw(clone);
use Data::Compare                  qw();
use Scalar::Util                   qw( reftype );
use List::Util                     qw( any );
use List::MoreUtils                qw( zip uniq );
use POSIX                          qw( floor );
use Carp;

my
@EXPORT_OK = qw($http_port_config $http_port_agg_base $field_arity_discrete
                $field_arity_numeric $arity_scalar $arity_discrete
                $arity_numeric $granularity_min
                &sdc_config &sys_info &deep_equal &deep_copy &deep_copy_into
                &field_exists &is_empty &num_props &do_pad &format_duration
                &starts_with &qualified_id &array_contains &noop &array_merge
                &http_param &run_stages &wrap_method &run_parallel &ends_with
                &substitute
                );
my
%EXPORT_TAGS = (constants => [ qw($http_port_config $http_port_agg_base
                                  $field_arity_discrete $field_arity_numeric
                                  $arity_scalar $arity_discrete $arit_numeric
                                  $granularity_min) ],
                subs => [ qw(&sdc_config &sys_info &deep_equal &deep_copy
                             &deep_copy_into &field_exists &is_empty &num_props
                             &do_pad &format_duration &starts_with
                             &qualified_id &array_contains &noop &array_merge
                             &http_param &run_stages &wrap_method &run_parallel
                             &ends_with &substitute) ],
               );

# Constants
#
# Default HTTP Ports, shared by the services themselves and the tests.
my $http_port_config   = 23181;
my $http_port_agg_base = 23184;

# PA Field Arities
my $field_arity_discrete = 'discrete';
my $field_arity_numeric  = 'numeric';

# PA Instrumentation Arities
my $arity_scalar   = 'scalar';
my $arity_discrete = 'discrete-decomposition';
my $arity_numeric  = 'numeric-decomposition';

# Minimum value for "granularity" > 1. Instrumenters report data at least this
# frequently, and all values for "granularity" must be a multiple of this.
my $granularity_min = 5;

sub sdc_config {
  return;  # We don't do this, so undefined
}

sub sys_info {
  my ($agentname, $agentversion) = @_;

  my $uname = uname();
  my $hostname;

  if ( exists $ENV{'HOST'} and length($ENV{'HOST'}) ) {
    $hostname = $ENV{'HOST'};
  } else {
    $hostname = $uname->{nodename};
  }

  return {
    agent_name => $agentname,
    agent_version => $agentversion,
    os_name       => $uname->{sysname},
    os_release    => $uname->{release},
    os_revision   => $uname->{version},
    os_machine    => $uname->{machine},
    hostname      => $hostname,
    major         => PA::AMQP->vers_major,
    minor         => PA::AMQP->vers_minor,
  };
}

sub deep_equal {
  my ($lhs, $rhs) = @_;

  my $c = Data::Compare->new($lhs, $rhs);

  return $c->Cmp;
}

sub deep_copy {
  my ($obj) = @_;
 
  my $clone = clone($obj);
  return $clone;
}

sub deep_copy_into {
  confess "Not implemented yet";
}

# Raise exception with a reasonable message if the specified key does not
# exist in the object.  If 'prototype' is specified, raise exception
# if the type of $href->{key} doesn't match the TYPE of 'prototype'.
#
#   Returns $href->{key}
#
sub field_exists {
  my ($href, $key, $prototype) = @_;

  if ( not any { $_ =~ m/^$key$/ } keys %$href ) {
    die "missing required field: $key";
  }
  if ($prototype &&
      (reftype($href->{key}) ne reftype($prototype))) {
    die "Field has wrong type: $key";
  }

  return $href->{key};
}

#
# Returns true IFF the given href is empty.
#
sub is_empty {
  my ($href) = @_;

  foreach my $key (keys %$href) {
    return 0;
  }
  return 1;
}

#
# Returns the number of keys in a given href.
#
sub num_props {
  my ($href) = @_;

  return scalar (keys %$href);
}

sub do_pad {
  my ($chr, $width, $left, $str) = @_;
  my $ret = $str;

  while (length($ret) < $width) {
    if ($left) {
      $ret .= $chr;
    } else {
      $ret = $chr . $ret;
    }
  }

  return $ret;
}

# Given a time duration in millisecs, format it appropriately for output
sub format_duration {
  my ($time_in_ms) = @_;

  my ($days, $hours, $minutes, $seconds, $msec, $str);

  $msec       = $time_in_ms % 1000;
  $time_in_ms = floor($time_in_ms / 1000);

  $seconds    = $time_in_ms % 60;
  $time_in_ms = floor($time_in_ms / 60);

  $minutes    = $time_in_ms % 60;
  $time_in_ms = floor($time_in_ms / 60);

  $hours      = $time_in_ms % 24;
  $time_in_ms = floor($time_in_ms / 24);

  $days = $time_in_ms;

  if ($days > 0) {
    $str .= sprintf("%dd", $days);
  }

  if ($days > 0 || $hours > 0) {
    $str .= sprintf("%02d:", $hours);
  }

  if ($days > 0 || $hours > 0 || $minutes > 0) {
    $str .= sprintf("%02d:", $minutes);
  }

  $str .= sprintf("%02d.%03ds", $seconds, $msec);
  return $str;
}

#
# Return true if the input string starts with the specified prefix.
#
sub starts_with {
  my ($str, $prefix) = @_;

  if (length($prefix) > length($str)) {
    return 0;
  }

  # True if $str starts with $prefix
  if (index($str,$prefix) == 0) {
    return 1;
  } else {
    return 0;
  }
}

sub noop { }

#
# Given a customer identifier and per-customer instrumentation identifier,
# return the fully quanlified instrumentation id.  If custid is undefined, it
# is assumed that instid refers to the global scope.  For details, see
# the block comment at the top of this file on cfg_insts.
#
sub qualified_id {
  my ($custid, $instid) = @_;

  if (not defined($custid)) {
    return "global;$instid";
  }

  return "cust:$custid;$instid";
}

# function to walk an array and see if it conatins a given field.
sub array_contains {
  my ($arr, $field) = @_;

  if ( any { $_ eq $field  } @$arr ) {
    return 1;
  } else {
    return 0;
  }
}

sub array_merge {
  my ($orig, $addl) = @_;

  my @merged = zip @$orig, @$addl;
  @merged = uniq @merged;

  return \@merged;
}

sub http_param {
  confess "Not implemented yet";
}


# run_stages() is given an array "stages" of functions, an initial argument
# "arg", and a callback "callback".  Each stage represents some task,
# asynchronous or not, which should be completed before the next stage is
# started.  Each stage is invoked with the result of the previous stage
# and can abort this process if it encounters an error.  When all stages
# have completed, "callback" is invoked with the error and results
# of the last stage that was run.
#
# More precisely: the first function of "stages" may be invoked during
# run_stages() or immediately after (asynchronously).  Each stage is
# invoked as stage(arg, callback), where "arg" is the result of the
# previous stage (or the "arg" specified to run_stages(), for the first
# stage) and "callback" should be invoked when the stage is complete.
# "callback" should be invoked as callback->(err, result), where "err"
# is a non-null instance of Error iff an error was encountered and null
# otherwise, and "result" is an arbitrary object to be passed to the
# next stage.  The "callback" given to run_stages() is invoked after
# the last stage has been run with the arguments given to that
# stage's completion callback.
#
sub run_stages {
  my ($stages, $arg, $callback) = @_;

  my ($stage, $next);

  $next = sub {
    my ($err, $result) = @_;
    my $nextfunc;

    if ($err) {
      $callback->($err, $result);
    }

    $nextfunc = $stages->[$stage++];
    if (!$nextfunc) {
      return $callback->(undef, $result);
    }

    return $nextfunc->($result, $next);
  };

  $stage = 0;
  $next->(undef, $arg);
}

# given an object and one of its methods, return a function that invokes that
# method in the context of the specified object.
sub wrap_method {
  my ($obj, $method) = @_;

  return sub {
    return $obj->$method(@_);
  }
}

sub run_parallel {
  confess "Not implemented yet";
}

# Returns true if the given string ends with the given suffix.
sub ends_with {
  my ($str, $suffix) = @_;

  if ($str =~ m/$suffix$/) {
    return 1;
  } else {
    return 0;
  }
}

sub substitute {
  confess "Not implemented yet";
}


1;
