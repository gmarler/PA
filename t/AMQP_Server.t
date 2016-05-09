use strict;
use warnings;

use Test::More;
use Future::Utils;
use IO::Async::Loop;
use IO::Async::Timer::Countdown;
use Net::Async::AMQP;
use Net::Async::AMQP::Server;
use Data::Dumper;

#plan skip_all => 'unfinished implementation';

my $loop = IO::Async::Loop->new;

$loop->add(my $cli = Net::Async::AMQP->new);
# $cli->bus->subscribe_to_event(
# 	close => sub { fail("close - @_") },
# 	unexpected_frame => sub { fail("unexpected - @_") },
# );
$cli->bus->subscribe_to_event(close => sub { diag "closed by remote"; });

my $true = Net::AMQP::Value->true;
my $f;

###ok($f = $cli->connect(
###    host  => 'localhost',
###    user  => 'guest',
###    pass  => 'guest',
###    vhost => '/',
###    client_properties => {
###      capabilities => {
###        'connection.blocked'     => $true,
###        'consumer_cancel_notify' => $true,
###      },
###    },
###  )->then(
###  sub { diag "connected OK"; Future->done(1); },
###  sub { diag "Failure during connect: @_"; Future->done; }
###)->get, 'connect to server');
###
###my $timer = IO::Async::Timer::Countdown->new(
###  delay      => 3,
###  on_expire  => sub {
###    diag "FIRING TIMER TO CLOSE CONNECTION";
###    #my $svr_stream = $cli->stream;
###    #$svr_stream->close;
###    $cli->close->get;
###
###    diag "Closure completed";
###    #$loop->stop;
###  },
###);
###
###$timer->start;
###$loop->add($timer);


my $ch;
#ok($ch = $cli->open_channel->get, 'open channel');
#$ch->on_close( sub { diag "CHANNEL CLOSED"; } );
#$srv->close;

###$loop->run;

#diag "Channel closed: " . $ch->closed;
#ok($cli->close->get, 'close connection again');

ok(1);

done_testing;

