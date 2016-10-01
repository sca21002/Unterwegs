package Unterwegs::View::JSON;

# ABSTRACT: Catalyst JSON View

use strict;
use base 'Catalyst::View::JSON';
#use Data::Dumper;

__PACKAGE__->config({
    expose_stash => [ qw(
        tracks tracks_total page
    ) ],
});

=head1 NAME

Unterwegs::View::JSON - Catalyst JSON View

=head1 SYNOPSIS

See L<Unterwegs>

=head1 DESCRIPTION

Catalyst JSON View.

=head1 AUTHOR

sca21002,,,

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
