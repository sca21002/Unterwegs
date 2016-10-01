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

    my $track_rs = $c->stash->{tracks}->search_with_len(
        {}, $page, $entries_per_page
    );

    my @rows;
    while (my $track = $track_rs->next) {
        my $href = { $track->get_columns() };
        my $start = $track->start;
        my $end   = $track->end; 
        $href->{start} = $start->strftime('%d.%m.%Y %H:%M'),
        $href->{end} = 
               $start->year  == $end->year
            && $start->month == $end->month
            && $start->day   == $end->day 
            ? $end->strftime('%H:%M') 
            : $end->strftime('%d.%m.%Y %H:%M');
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

#sub json : Chained('tracks') PathPart('json') Args(0) {
#    my ( $self, $c ) = @_;
#
#    my $data = $c->req->params;
#
#    my $page = $data->{page} || 1;
#    my $entries_per_page = $data->{rows} || 10;
#    my $sidx = $data->{sidx} || 'ogc_fid';
#    my $sord = $data->{sord} || 'asc';
#
#    my $tracks_rs = $c->stash->{tracks};
#
#    $tracks_rs = $tracks_rs->search_with_len();
#    warn "Bin nach search_with_len";
#    $tracks_rs = $tracks_rs->search(
#        {},
#        {
#            page => $page,
#            rows => $entries_per_page,
#            order_by => {"-$sord" => $sidx},
#        },
#    );
#
#    my $response;
#    $response->{page} = $page;
#    $response->{total} = $tracks_rs->pager->last_page;
#    $response->{records} = $tracks_rs->pager->total_entries;
#    my @rows; 
#    while (my $track = $tracks_rs->next) {
#        my $row->{ogs_fid} = $track->ogc_fid;
#        my $start = $track->start();
#        my $end   = $track->end();
#        $row->{cell} = [
#            $track->ogc_fid,
#            $track->tour  && $track->tour->name || '',            
#            $track->name,
#            $track->src,
#            $track->get_column('len'),
#            $start->strftime('%d.%m.%Y %H:%M'),
#            (    $start->year  == $end->year
#              && $start->month == $end->month
#              && $start->day   == $end->day 
#              ? $end->strftime('%H:%M') 
#              : $end->strftime('%d.%m.%Y %H:%M')
#            )
#        ];
#        push @{ $response->{rows} }, $row;
#    }
#
#    $c->stash(
#        %$response,
#        current_view => 'JSON',
#    );
#}

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

    $c->log->debug('Bin in trackpoints');

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
        },
    );

    $c->log->debug('Count: ', $track_points_rs->count);

    my $fcol = $track_points_rs->as_feature_collection;

    $c->log->debug(Dumper($fcol));
    
    $c->stash(
        feature => $fcol,
        current_view => 'GeoJSON'
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
