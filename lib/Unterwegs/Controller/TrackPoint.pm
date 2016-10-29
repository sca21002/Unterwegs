use utf8;
package Unterwegs::Controller::TrackPoint;

# ABSTRACT: Controller for track points

use Moose;
use namespace::autoclean;
use Data::Dumper;

BEGIN { extends 'Catalyst::Controller'; }

=head1 NAME

Unterwegs::Controller::TrackPoint - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index

=cut

sub trackpoints : Chained('/base') PathPart('trackpoint') CaptureArgs(0) {
    my ($self, $c) = @_; 
            
    $c->stash->{trackpoints} = $c->model('UnterwegsDB::TrackPoint');
}

sub trackpoint : Chained('trackpoints') PathPart('') CaptureArgs(1) {
    my ($self, $c, $ogc_fid) = @_;

    my $trackpoint_rs = $c->stash->{trackpoints};
    $c->stash->{trackpoint} = $trackpoint_rs->find($ogc_fid);
}

sub delete : Chained('trackpoint') PathPart('delete') Args(0) {
    my ($self, $c) = @_;

    my $trackpoint = $c->stash->{trackpoint};
    $trackpoint->delete;
    my $track = $trackpoint->track;
    my $sub_select_wkb_geometry = 
        '(SELECT ST_Multi(ST_MakeLine(track_points.wkb_geometry '
        . 'ORDER BY track_points.ogc_fid)) FROM track_points '
        . 'WHERE track_points.track_id = tracks.ogc_fid)';
    my $sub_select_start =
        '(SELECT min(time) FROM track_points '
        . 'WHERE track_points.track_id = tracks.ogc_fid)';
    my $sub_select_end = 
        '(SELECT max(time) FROM track_points '
        . 'WHERE track_points.track_id = tracks.ogc_fid)';
   
    my $sub_select_avg_speed = 
        'ROUND('
         .  'CAST(len * 3600 /(EXTRACT(EPOCH FROM duration)*1000) AS numeric)' 
         .',2)';

    $track->update({
        wkb_geometry =>  \$sub_select_wkb_geometry,
        start => \$sub_select_start,
        end   => \$sub_select_end,  
    }); 

    $track->update({
        duration => \'"end" - start',
        len      => \'ST_Length(Geography(wkb_geometry))',
    });

    $track->update({
        avg_speed => \$sub_select_avg_speed,        
    });

    $c->response->body('ok');
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
