package Unterwegs::View::HTML;

# ABSTRACT: Default TT View in Unterwegs

use Moose;
use namespace::autoclean;

extends 'Catalyst::View::TT';

__PACKAGE__->config(
    TEMPLATE_EXTENSION => '.tt',
    # Set the location for TT files
    INCLUDE_PATH => [
        Unterwegs->path_to( qw(root base) ) ,
    ],
    ENCODING => 'utf8',
    # Set to 1 for detailed timer stats in your HTML as comments
    TIMER              => 0,
    # This is your wrapper template located in the 'root/base/site'
    WRAPPER => 'site/wrapper.tt',
    render_die => 1, # default 
);

=head1 NAME

Unterwegs::View::HTML - TT View for Unterwegs

=head1 DESCRIPTION

TT View for Unterwegs.

=head1 SEE ALSO

L<Unterwegs>

=head1 AUTHOR

sca21002,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
