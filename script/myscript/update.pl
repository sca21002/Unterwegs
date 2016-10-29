#!/usr/bin/env perl
use utf8;
use Path::Tiny;
use FindBin qw($Bin);
use lib path($Bin)->parent(2)->child('lib')->stringify;
use warnings  qw(FATAL utf8);    # fatalize encoding glitches
use open      qw(:std :utf8);    # undeclared streams in UTF-8
use Modern::Perl;
use Unterwegs::Helper;
my $schema = Unterwegs::Helper::get_schema();
my $track_rs = $schema->resultset('Track');

say $track_rs->count;

my $track = $track_rs->find(449);
say $track->name;

$track->update({
    wkb_geometry => \'(SELECT ST_Multi(ST_MakeLine(track_points.wkb_geometry ORDER BY track_points.ogc_fid)) FROM track_points WHERE track_points.track_id = tracks.ogc_fid)'
});
