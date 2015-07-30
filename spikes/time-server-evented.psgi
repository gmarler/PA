use IO::Async::Timer::Periodic;

use IO::Async::Loop;

my $loop = IO::Async::Loop->new;

my $watcher;
my $timer_model = sub {
  my $writer = shift;

  $watcher =
    IO::Async::Timer::Periodic->new(
      interval => 1,
      on_tick => sub {
        $writer->write(scalar localtime);
      },
    );

  $watcher->start;
  $loop->add( $watcher );
};

my $psgi_app = sub {
  my $env = shift;
  return sub {
    my $responder = shift;
    my $writer = $responder->(
      [  200,
         [ 'Content-Type'  => 'text/plain' ],
      ]);

    $timer_model->($writer); 
  };
};
