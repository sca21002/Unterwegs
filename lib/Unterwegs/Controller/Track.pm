use utf8;
package Unterwegs::Controller::Track;

# ABSTRACT: Controller for listing  gpx tracks

use Moose;
use namespace::autoclean;
use Data::Dumper;

BEGIN { extends 'Catalyst::Controller'; }

=head1 NAME

Unterwegs::Controller::Track - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index

=cut

sub tracks : Chained('/base') PathPart('track') CaptureArgs(0) {
    my ($self, $c) = @_; 
            
    $c->stash->{tracks} = $c->model('UnterwegsDB::Track');
}

sub list : Chained('tracks') PathPart('list') Args(0) {
    my ( $self, $c ) = @_;

    my $response;
    my $page = $c->req->params->{page} || 1; 
    my $entries_per_page = 5;

    my $track_rs = $c->stash->{tracks}->search(
        {},
        {   
            select => [ qw( 
                ogc_fid name cmt desc src number tour_id file start end
                duration len avg_speed travel_mode_id travel_mode.icon avg_hr
            ) ],
            as     => [ qw( 
                ogc_fid name cmt desc src number tour_id file start end
                duration len avg_speed travel_mode_id icon avg_hr
            ) ],
            join     => 'travel_mode',
            page     => $page,
            rows     => $entries_per_page,
            order_by => {-desc => 'start'}, 
        },
    );

    my @rows;
    while (my $track = $track_rs->next) {
        my $href = { $track->get_inflated_columns() };
        my ($start, $end) = @{$href}{qw(start end)};
        $href->{start} = $start->strftime('%d.%m.%Y %H:%M'),
        $href->{end} = 
               $start->year  == $end->year
            && $start->month == $end->month
            && $start->day   == $end->day 
            ? $end->strftime('%H:%M') 
            : $end->strftime('%d.%m.%Y %H:%M');
            #$href->{icon} = $track->get_column('icon');
        push @rows, $href;
    }    
 
    $response->{tracks} = \@rows;
    $response->{page}    = $page;
    $response->{tracks_total} = $track_rs->pager->total_entries;
   
    $c->stash(
        %$response,
        current_view => 'JSON'
    );
}

sub track : Chained('tracks') PathPart('') CaptureArgs(1) {
    my ($self, $c, $ogc_fid) = @_;

    $c->stash->{ogc_fid} = $ogc_fid;
}

sub track_as_geojson : Chained('track') PathPart('') Args(0) {
    my ($self, $c) = @_;

    my $tracks_rs = $c->stash->{tracks};
    my $ogc_fid   = $c->stash->{ogc_fid};

    $tracks_rs = $tracks_rs->search_with_geojson_geometry({ogc_fid => $ogc_fid});
    my $track = $tracks_rs->first;
    my $feature = $track->as_feature_object;
    $c->stash(
        feature => $feature,
        current_view => 'GeoJSON',
    );
}

sub trackpoints : Chained('track') PathPart('trackpoints') Args(0) {
    my ($self, $c) = @_;

    my $tracks_rs = $c->stash->{tracks};
    my $ogc_fid   = $c->stash->{ogc_fid};

    my $track_points_rs = $tracks_rs->find($ogc_fid)->search_related(
        'track_points',
        {},
        {   
            '+select' => [ 
                \'ST_AsGeoJSON(ST_Transform(wkb_geometry, 3857))',
            ],
            '+as'     => [ 
                'geojson_geometry' 
            ],      
            order_by => 'time',
        },
    );

    my $fcol = $track_points_rs->as_feature_collection;

    $c->stash(
        feature => $fcol,
        current_view => 'GeoJSON'
    );
} 

sub update : Chained('track') PathPart('update') Args(0) {
    my ($self, $c) = @_;

    my $track_rs = $c->stash->{tracks};
    my $ogc_fid   = $c->stash->{ogc_fid};

    my $track = $track_rs->find($ogc_fid);

    my $data = $c->req->body_data;

    my %columns;
    @columns{qw(cmt travel_mode_id tour_id desc name)} 
        = @{$data}{qw(cmt travel_mode_id tour_id desc name)};

    $track->update(\%columns);
    
    $c->response->body('ok');
} 

sub laptime : Chained('track') PathPart('laptime') Args(0) {
    my ($self, $c) = @_;

       my $ogc_fid = $c->stash->{ogc_fid};
    
        my @res = $c->model('UnterwegsDB::LapTime')->get_laptime($ogc_fid)->search(
            {},
            {result_class => 'DBIx::Class::ResultClass::HashRefInflator'}
        )->all;
    
    my $response;
    $response->{laptime} = [@res];

    $c->stash(
        %$response,
        current_view => 'JSON_LT'
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
