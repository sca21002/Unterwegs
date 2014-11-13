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
   
    $c->stash( 
        json_url => $c->uri_for_action('track/json'),
        template => 'track/list.tt',
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
    $tracks_rs = $tracks_rs->search(
        {},
        {
            page => $page,
            rows => $entries_per_page,
            order_by => {"-$sord" => $sidx},
        },
    );

    my $ft_col =  $tracks_rs->as_feature_collection;

    #  $c->log->debug(Dumper($ft_col->to_json));

     $ft_col->page($page);
     $ft_col->total($tracks_rs->pager->last_page);
     $ft_col->records($tracks_rs->pager->total_entries);
#    while (my $track = $tracks_rs->next) {
#        $c->log->debug($track->track_line);
#        my $row->{ogs_fid} = $track->ogc_fid;
#        $row->{cell} = [
#            $track->ogc_fid,
#            $track->tour  && $track->tour->name || '',            
#            $track->name,
#            $track->src,
#            $track->get_column('len'),
#            $track->start()->strftime('%d.%m.%Y %H:%M'),
#            (    $track->start()->year  == $track->end()->year
#              && $track->start()->month == $track->end()->month
#              && $track->start()->day   == $track->end()->day 
#              ? $track->end()->strftime('%H:%M') 
#              : $track->end()->strftime('%d.%m.%Y %H:%M')
#            )
#        ];
#        push @{ $response{rows} }, $row;
#    }

    $c->stash(
        feature_collection => $ft_col,
        current_view => 'JSON',
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
