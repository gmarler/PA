use strict;
use warnings;
use Test::More;


use Catalyst::Test 'PA::Web';
use PA::Web::Controller::Stats;

ok( request('/stats')->is_success, 'Request should succeed' );
done_testing();
