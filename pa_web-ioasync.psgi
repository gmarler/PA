## Start like so:
# CATALYST_DEBUG=1 plackup -Ilib -s Net::Async::HTTP::Server pa_web-ioasync.psgi
use strict;
use warnings;

use PA::Web;

my $app = PA::Web->apply_default_middlewares(PA::Web->psgi_app);
$app;

