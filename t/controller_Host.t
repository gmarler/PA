use strict;
use warnings;
use Test::More;

# Ensure we load the proper config for testing before we run
BEGIN { $ENV{CATALYST_CONFIG_ENV_SUFFIX} = "test"; }

use Catalyst::Test 'PA::Web';
use PA::Web::Controller::Host;

ok( request('/host')->is_success, 'Request should succeed' );
done_testing();
