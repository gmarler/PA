# NOTE: TF stands for TestsFor::...
package TF::PA::Parser::arcstat;

use File::Temp                    qw();
use Data::Dumper                  qw();
use Path::Class::File             qw();
use IO::File                      qw();
use DateTime::Format::Strptime    qw();
use PA::DateTime::Format::arcstat qw();
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

  my ($datastream) = $test->_mock_data_filehandle("arcstat.out");
  isa_ok($datastream, 'IO::File', 'Mock data for arcstat.pl available');

  isa_ok my $object = $class->new(datastream => $datastream), $class;
}

sub test_mock_data_available {
  my ($test) = shift;

  my ($datastream) = $test->_mock_data_filehandle("arcstat.out");
  isa_ok($datastream, 'IO::File', 'Mock data for arcstat.pl available');
}

sub test_parse_intervals {
  my ($test) = shift;

  my ($datastream) = $test->_mock_data_filehandle("arcstat.out");

  my $class = $test->class_name;
  isa_ok my $object = $class->new(datastream => $datastream), $class;

  my $intervals = $object->parse_intervals;
  my $msg = Data::Dumper->Dump($intervals);
  # diag $msg;
  cmp_ok(scalar(@$intervals), '==', 43,
         "Proper Number of Intervals Found");
  cmp_deeply($intervals, 
             array_each( [ re(qr/\d{2}:\d{2}:\d{2}/),
                           ignore(),
                           ignore(),
                           ignore(),
                           ignore(),
                           ignore(),
                           ignore(),
                           ignore(),
                           ignore(),
                           ignore(),
                           re(qr/^\d+[KMG]$/),
                           re(qr/^\d+[KMG]$/),
                         ]
                       ),
             "Raw Interval content correct"
            );
}
#
#sub test_regexes {
#  my ($test) = shift;
#
#  my $class = $test->class_name;
#  isa_ok my $object = $class->new, $class;
#
#  my (@regexes) = qw/epoch_interval_regex datetime_interval_regex stack_regex/;
#  foreach my $regex_name (@regexes) {
#    isa_ok($object->$regex_name, 'Regexp', "$regex_name exists");
#  }
#}

#sub test_add_recurse {
#  my ($test) = shift;
#
#  my $class = $test->class_name;
#  my $object = $class->new;
#  can_ok($object, 'add_recurse');
#
#  is_deeply( $actual_add_result, $expected_add_result,
#             "simple kernel stack recursive add" );
#}

sub _mock_data_filehandle {
  my $self     = shift;
  my $datafile = shift;

  my $filepath =
    Path::Class::File->new(__FILE__)->parent->parent->parent->parent
                                    ->parent
                     ->file("data",$datafile)
                     ->absolute->stringify;

  if (not -f $filepath) { diag "$filepath does not exist"; return;  }

  my $fh       = IO::File->new($filepath,"<") or
    die "Unable to open $filepath for reading";

  return $fh;
}
