use strict;
use warnings;
use Test::More;


use Catalyst::Test 'PA::Web';
use PA::Web::Controller::REST;

ok( request('/rest')->is_success, 'Request should succeed' );

done_testing();
