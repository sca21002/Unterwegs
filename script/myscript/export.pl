#!/usr/bin/env perl
use utf8;
use Path::Tiny;
use FindBin qw($Bin);
use lib path($Bin)->parent(2)->child('lib')->stringify;
use warnings  qw(FATAL utf8);    # fatalize encoding glitches
use open      qw(:std :utf8);    # undeclared streams in UTF-8
use Getopt::Long;
use Pod::Usage;
use English qw( -no_match_vars ) ;  # Avoids regex performance penalty
use Modern::Perl;
use XML::Twig;
use Unterwegs::Helper;
use Geo::JSON;
use Data::Dumper;
$Data::Dumper::Maxdepth = 3;

my @track_point_columns = (qw(
 	ele time magvar geoidheight name cmt desc src link1_href link1_text
    link1_type link2_href link2_text link2_type sym type fix sat hdop vdop
	pdop ageofdgpsdata dgpsid
));


### get options 

my($opt_help, $opt_man);

GetOptions(
    'help!' => \$opt_help,
    'man!'  => \$opt_man,
)
    or pod2usage( "Try '$PROGRAM_NAME --help' for more information." );

pod2usage( -verbose => 1 ) if $opt_help;
pod2usage( -verbose => 2 ) if $opt_man;

### read track_id of gpx 

my $ogc_fid = shift @ARGV or pod2usage(
    -message => "No track id given!", 
    -verbose => 1 
);

my $schema = Unterwegs::Helper::get_schema();
my $track_rs = $schema->resultset('Track');
my $tour_rs = $schema->resultset('Tour');

my $track = $track_rs->find($ogc_fid);

my $gpx_file = path($Bin)->parent(2)->child('data', $track->src . '.gpx');

croak("Track with id '$ogc_fid' doesn't exist") unless $track;

my $twig= new XML::Twig(
    twig_handlers => { 
        trk => \&trk,
    },
);

$twig->parsefile( path($Bin)->child("template.gpx"));
$twig->print_to_file($gpx_file, pretty_print => 'indented');


sub trk {
    my ($twig, $trk) = @_;

    $trk->first_child('name')->set_text($track->name);    

    my $track_points_rs = $track->search_related(
        'track_points',
        {},
        {
            '+select' => \'ST_AsGeoJSON(wkb_geometry)',
            '+as'     => 'point',
        }
    );    
    my $trkseg_elt = XML::Twig::Elt->new('trkseg'); 
    $trkseg_elt->paste('last_child', $trk);

    while (my $track_point = $track_points_rs->next) {
        my $json = $track_point->get_column('point');
        my $point = Geo::JSON->from_json( $json );
        my ($lon, $lat) = @{$point->coordinates};
        my $trkp_elt = XML::Twig::Elt->new(
            trkpt => {lat => $lat, lon => $lon},
        );
        foreach my $column (@track_point_columns) {
			if ($track_point->$column) {
                my $content;
                if ($column eq 'time') {
                    my $dt = $track_point->time;
                    $dt->set_time_zone('UTC');
                    $content = $dt->strftime("%FT%TZ");
                } else { 
                	$content = $track_point->$column;
                }   
				my $elt = XML::Twig::Elt->new(
                	$column => $content
				); 
                $elt->paste('last_child', $trkp_elt);
            }
        }
        $trkp_elt->paste('last_child', $trkseg_elt);       
    }
    say "I see a trk";
}

=encoding utf-8

=head1 NAME

    export.pl - Exports data from database into a gpx file

=head1 SYNOPSIS

    export.pl [options] [track id]

         Options:
                 --help         display this help and exit
                 --man          display extensive help

         Examples:
                 export.pl <track id>
                 export.pl --help
                 import.pl --man 

=head1 DESCRIPTION

    Exports data from database into a gpx file.

=head1 AUTHOR

    Albert Schröder <albert.schroeder@ur.de>

=head1 LICENSE

    This library is free software. You can redistribute it and/or modify
        it under the same terms as Perl itself.

=cut
