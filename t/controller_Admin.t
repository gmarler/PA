use strict;
use warnings;
use Test::More;


use Catalyst::Test 'PA::Web';
use PA::Web::Controller::Admin;

ok( request('/admin')->is_success, 'Request should succeed' );
done_testing();
