use strict;
use warnings;
use Test::More;


use Catalyst::Test 'PA::Web';
use PA::Web::Controller::Host;

ok( request('/host')->is_success, 'Request should succeed' );
done_testing();
