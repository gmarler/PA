package PA::Web::View::HTML;

use Moose;
use namespace::autoclean;

extends 'Catalyst::View::TT';

# VERSION

__PACKAGE__->config(
  # Commented out to allow our index.html to be served statically, rather than
  # via TT
  #TEMPLATE_EXTENSION => '.tt',
    render_die => 1,
);

=head1 NAME

PA::Web::View::HTML - TT View for PA::Web

=head1 DESCRIPTION

TT View for PA::Web.

=head1 SEE ALSO

L<PA::Web>

=head1 AUTHOR

Gordon Marler

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
