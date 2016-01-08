# NOTE: TF stands for TestsFor::...
package TF::PA::Stash;

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
  );

  # ... passed as a reference to init()
  Log::Log4perl::init( \$log_conf );
}

