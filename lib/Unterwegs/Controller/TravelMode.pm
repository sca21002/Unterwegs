use utf8;
package Unterwegs::Controller::TravelMode;

# ABSTRACT: Controller for listing travel modes 

use Moose;
use namespace::autoclean;
use DBIx::Class::ResultClass::HashRefInflator;
use Data::Dumper;

BEGIN { extends 'Catalyst::Controller'; }

=head1 NAME

Unterwegs::Controller::TravelMode - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index

=cut

sub travel_modes : Chained('/base') PathPart('travel_mode') CaptureArgs(0) {
    my ($self, $c) = @_; 
            
    $c->stash->{travel_modes} = $c->model('UnterwegsDB::TravelMode');
}

sub list : Chained('travel_modes') PathPart('list') Args(0) {
    my ( $self, $c ) = @_;

    $c->stash(
        travel_modes => [ 
            $c->stash->{travel_modes}->search(
                {},
                {result_class => 'DBIx::Class::ResultClass::HashRefInflator'}
            )->all
        ],
        current_view => 'JSON_TM'
    );
}

=encoding utf8

=head1 AUTHOR

sca21002,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
