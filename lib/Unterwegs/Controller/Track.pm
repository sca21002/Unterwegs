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
            columns => [qw(ogc_fid name cmt desc src number type tour_id)],
            page => $page,
            rows => $entries_per_page,
        }
    );

    my @rows;
    while (my $row = $track_rs->next) {
        my $href = { $row->get_columns() };
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

sub json : Chained('tracks') PathPart('json') Args(0) {
    my ( $self, $c ) = @_;

    my $data = $c->req->params;

    my $page = $data->{page} || 1;
    my $entries_per_page = $data->{rows} || 10;
    my $sidx = $data->{sidx} || 'ogc_fid';
    my $sord = $data->{sord} || 'asc';

    my $tracks_rs = $c->stash->{tracks};

    $tracks_rs = $tracks_rs->search_with_len();
    warn "Bin nach search_with_len";
    $tracks_rs = $tracks_rs->search(
        {},
        {
            page => $page,
            rows => $entries_per_page,
            order_by => {"-$sord" => $sidx},
        },
    );

    my $response;
    $response->{page} = $page;
    $response->{total} = $tracks_rs->pager->last_page;
    $response->{records} = $tracks_rs->pager->total_entries;
    my @rows; 
    while (my $track = $tracks_rs->next) {
        my $row->{ogs_fid} = $track->ogc_fid;
        my $start = $track->start();
        my $end   = $track->end();
        $row->{cell} = [
            $track->ogc_fid,
            $track->tour  && $track->tour->name || '',            
            $track->name,
            $track->src,
            $track->get_column('len'),
            $start->strftime('%d.%m.%Y %H:%M'),
            (    $start->year  == $end->year
              && $start->month == $end->month
              && $start->day   == $end->day 
              ? $end->strftime('%H:%M') 
              : $end->strftime('%d.%m.%Y %H:%M')
            )
        ];
        push @{ $response->{rows} }, $row;
    }

    $c->stash(
        %$response,
        current_view => 'JSON',
    );
}

sub geojson : Chained('tracks') PathPart('geojson') Args(0) {
    my ($self, $c) = @_;

    my $data = $c->req->params;
    $c->log->debug(Dumper($data->{ogc_fid}));

    my $ogc_fid = $data->{ogc_fid};
    my $tracks_rs = $c->stash->{tracks};

    $tracks_rs = $tracks_rs->search_with_geojson_geometry({ogc_fid => $ogc_fid});
    my $track = $tracks_rs->first;
    my $feature = $track->as_feature_object;
    $c->stash(
        feature => $feature,
        current_view => 'GeoJSON',
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
