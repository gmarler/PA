# NOTE: TF stands for TestsFor::...
package TF::PA::Capture::mdb::memstat;

use File::Temp          qw();
use Data::Dumper        qw();
use Assert::Conditional qw();
use JSON::MaybeXS       qw();
use boolean;
# Possible alternative assertion methodology
# use Devel::Assert     qw();

use Test::Class::Moose;
with 'Test::Class::Moose::Role::AutoUse';


sub test_startup {
  my ($test, $report) = @_;
  $test->next::method;

  # Log::Log4perl configuration in a string ...
  my $log_conf = q(
    logperl.rootLogger              = DEBUG, Screen

    log4perl.Appender.Screen        = Log::Log4perl::Appender::Screen
    log4perl.Appender.Screen.stderr = 0
    log4perl.Appender.Screen.layout = Log::Log4perl::Layout::SimpleLayout

    log4perl.category.PA.Capture.mdb.memstat = INFO, FWR_memstat

    log4perl.appender.FWR_memstat           = Log::Dispatch::FileWriteRotate
    log4perl.appender.FWR_memstat.dir       = /tmp
    log4perl.appender.FWR_memstat.histories = 7
    log4perl.appender.FWR_memstat.prefix    = memstat
    log4perl.appender.FWR_memstat.period    = daily
    log4perl.appender.FWR_memstat.layout    = \
         Log::Log4perl::Layout::PatternLayout
    log4perl.appender.FWR_memstat.layout.ConversionPattern = \
         %m%n
  );

  # ... passed as a reference to init()
  Log::Log4perl::init( \$log_conf );
}

# Test that log rotation occurs at midnight
# Test that log rotation keeps the proper number of files
#
# Test that log contents look right
