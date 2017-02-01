use File::Spec::Functions qw( catdir );
use FindBin qw( $Bin );

use Test::Class::Moose::Load catdir( $Bin, 'lib' );
use Test::Class::Moose::Runner;

# Invocation examples:
#
# Everything:
#   prove -lv t/tests.t
# Individual test:
#   prove -lv t/tests.t :: TF::PA::Metric
#
my $test_suite = Test::Class::Moose::Runner->new(
  #show_timing  => 0,
  #randomize    => 0,
  #statistics   => 1,
  test_classes => \@ARGV,
);

$test_suite->runtests;

#my $report = $test_suite->test_report;

