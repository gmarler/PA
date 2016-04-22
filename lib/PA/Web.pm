package PA::Web;
use Moose;
use namespace::autoclean;

use Catalyst::Runtime 5.80;

# Set flags and add plugins for the application.
#
# Note that ORDERING IS IMPORTANT here as plugins are initialized in order,
# therefore you almost certainly want to keep ConfigLoader at the head of the
# list if you're using it.
#
#         -Debug: activates the debug mode for very useful log messages
#   ConfigLoader: will load the configuration from a Config::General file in the
#                 application's home directory
# Static::Simple: will serve static files from the application's root
#                 directory

use Catalyst qw/
    +PA::Web::Plugin::ConfigLoader
    Static::Simple
/;
#   -Debug

extends 'Catalyst';

# VERSION

# Configure the application.
#
# Note that settings in pa_web.conf (or other external
# configuration file that you set up manually) take precedence
# over this when using ConfigLoader. Thus configuration
# details given here can function as a default configuration,
# with an external configuration file acting as an override for
# local deployment.

###__PACKAGE__->config(
###  'Plugin::ConfigLoader' => {
###    file => __PACKAGE__->path_to('conf'),
###  },
###);


__PACKAGE__->config(
    name => 'PA::Web',
    # Disable deprecated behavior needed by old applications
    disable_component_resolution_regex_fallback => 1,
    enable_catalyst_header => 1, # Send X-Catalyst header
    # Configure the Static View
    'Plugin::Static::Simple' => {
        logging => 1,
        dirs => [
            'static',
            'app',
            'assets',
            'bower_components',
            'data',
            #qr/^(images|css)/,
        ],
        ignore_extensions => [ qw/htm asp php/ ],
    },
    # Configure the view
    #'View::HTML' => {
    #    #Set the location for TT files
    #    INCLUDE_PATH => [
    #        __PACKAGE__->path_to( 'root', 'src' ),
    #    ],
    #},
    'Plugin::ConfigLoader' => {
      file => __PACKAGE__->path_to('conf'),
    },
);


# Start the application
__PACKAGE__->setup();

=encoding utf8

=head1 NAME

PA::Web - Catalyst based application

=head1 SYNOPSIS

    script/pa_web_server.pl

=head1 DESCRIPTION

[enter your description here]

=head1 SEE ALSO

L<PA::Web::Controller::Root>, L<Catalyst>

=head1 AUTHOR

Gordon Marler

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
