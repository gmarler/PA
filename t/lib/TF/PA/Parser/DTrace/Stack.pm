# NOTE: TF stands for TestsFor::...
package TF::PA::Parser::DTrace::Stack;

use File::Temp          qw();
use Data::Dumper        qw();
use JSON::MaybeXS       qw();
# Possible alternative assertion methodology
# use Devel::Assert     qw();

use Test::Class::Moose;
with 'Test::Class::Moose::Role::AutoUse';


# sub test_startup {
#   my ($test, $report) = @_;
#   $test->next::method;
#
#   # Log::Log4perl configuration in a string ...
#   my $log_conf = q(
#     logperl.rootLogger              = DEBUG, Screen
#
#     log4perl.Appender.Screen        = Log::Log4perl::Appender::Screen
#     log4perl.Appender.Screen.stderr = 0
#     log4perl.Appender.Screen.layout = Log::Log4perl::Layout::SimpleLayout
#   );
#
#   # ... passed as a reference to init()
#   Log::Log4perl::init( \$log_conf );
# }

sub test_constructor {
  my ($test) = shift;

  my $class = $test->class_name;
  can_ok $class, 'new';
  isa_ok my $object = $class->new, $class;
}

sub test_regexes {
  my ($test) = shift;

  my $class = $test->class_name;
  isa_ok my $object = $class->new, $class;

  my (@regexes) = qw/epoch_interval_regex datetime_interval_regex stack_regex/;
  foreach my $regex_name (@regexes) {
    isa_ok($object->$regex_name, 'Regexp', "$regex_name exists");
  }
}

