use strict;
use warnings;

use PA::Web;

my $app = PA::Web->apply_default_middlewares(PA::Web->psgi_app);
$app;

