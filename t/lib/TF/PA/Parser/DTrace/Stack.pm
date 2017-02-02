# NOTE: TF stands for TestsFor::...
package TF::PA::Parser::DTrace::Stack;

use File::Temp                   qw();
use Data::Dumper                 qw();
use JSON::MaybeXS                qw();
use Path::Class::File            qw();
use IO::File                     qw();
use DateTime::Format::Strptime   qw();
use PA::DateTime::Format::DTrace qw();
# Possible alternative assertion methodology
# use Devel::Assert     qw();

use Test::Class::Moose;
with 'Test::Class::Moose::Role::AutoUse';

my $datetime = "2017 Jan  9 15:48:00";
my $epoch    = "1483976880";
my $TZ       = "US/Eastern";

# A formatter that will allow us to increment a DateTime and print it again
# NOTE: the pattern is set to reproduce the above output example exactly
my $formatter = DateTime::Format::Strptime->new(pattern => '%Y %b %e %H:%M:%S');
#
my $dt = PA::DateTime::Format::DTrace->parse_datetime( $datetime );
$dt->set_formatter( $formatter );



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

sub test_add_recurse {
  my ($test) = shift;

  my $class = $test->class_name;
  my $object = $class->new;
  can_ok($object, 'add_recurse');

  my $raw_stack = _load_mock_data('stack_kernel_simple.raw');
  cmp_ok(length($raw_stack), ">", 0, 'simple kernel stack data loaded');

  my $interval_href = { name => 'root', value => 0, children => {} };

  my $stack =
    [
      'unix`thread_start',
      'unix`idle',
      'unix`cpu_idle',
      'unix`mach_cpu_idle'
    ];
  my $stack_count = 19199;

  my $expected_add_result =
  {
    'name' => 'all',
    'value' => 19199,
    'children' => {
      'unix`thread_start' => {
        'name' => 'unix`thread_start',
        'value' => 19199,
        'children' => {
          'unix`idle' => {
            'children' => {
              'unix`cpu_idle' => {
                'value' => 19199,
                'children' => {
                  'unix`mach_cpu_idle' => {
                    'children' => {},
                    'value' => 19199,
                    'name' => 'unix`mach_cpu_idle'
                  }
                },
                'name' => 'unix`cpu_idle'
              }
            },
            'value' => 19199,
            'name' => 'unix`idle'
          }
        }
      }
    }
  };

  my $actual_add_result =
    $object->add_recurse($interval_href, $stack, $stack_count);

  is_deeply( $actual_add_result, $expected_add_result,
             "simple kernel stack recursive add" );
}

sub test_serialize_recurse {
  my ($test) = shift;

  my $class = $test->class_name;
  my $object = $class->new;
  can_ok($object, 'serialize_recurse');
}

sub _load_mock_data {
  my $datafile = shift;
  my $filepath =
    Path::Class::File->new(__FILE__)->parent->parent->parent->parent->parent
                                    ->parent
                     ->file("data",$datafile)
                     ->absolute->stringify;

  if (not -f $filepath) { return;  }

  my $fh       = IO::File->new($filepath,"<") or
    die "Unable to open $filepath for reading";

  my $content = do { local $/; <$fh>; };

  $fh->close;
  return $content;

}
