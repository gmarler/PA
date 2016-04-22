package PA::Web::Plugin::ConfigLoader;

use strict;
use warnings;
use v5.20;

# VERSION

use parent 'Catalyst::Plugin::ConfigLoader';

use Catalyst::Utils      qw();
use Sys::Hostname        qw();

=method get_config_local_suffix

Taken from example at L<http://www.catalystframework.org/calendar/2009/11>,
create the ability to specify a config specific for the following
configurations:

username
hostname
CATALYST_CONFIG_ENV_SUFFIX

=cut

sub get_config_local_suffix {
  my ($c) = @_;

  my $username = $ENV{USER} || getpwuid($<);
  my ($hostname) = Sys::Hostname::hostname() =~ m/^([^\.]+)/;
  my $env_suffix = Catalyst::Utils::env_value($c, 'CONFIG_ENV_SUFFIX' );
  my $config_local_suffix =
    Catalyst::Utils::env_value($c, 'CONFIG_LOCAL_SUFFIX')
    || join('_', grep { $_ } ($username, $hostname, $env_suffix));

  say __PACKAGE__ . " will look for config here: " . $config_local_suffix;
  return $config_local_suffix;
}

1;
