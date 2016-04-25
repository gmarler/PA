## Start like so:
##
## DEV  Environment:
## CATALYST_CONFIG_ENV_SUFFIX=dev \
## CATALYST_DEBUG=1 DBIC_TRACE=1 \
##   plackup -Ilib --port 5000 -r \
##           -s Net::Async::HTTP::Server pa_web.psgi
##
##
## PROD Environment:
## CATALYST_CONFIG_ENV_SUFFIX=prod \
## CATALYST_DEBUG=1 DBIC_TRACE=1 \
##   plackup -Ilib --port 80 -r \
##           -s Net::Async::HTTP::Server pa_web.psgi
##
use strict;
use warnings;

use PA::Web;

my $app = PA::Web->apply_default_middlewares(PA::Web->psgi_app);
$app;

