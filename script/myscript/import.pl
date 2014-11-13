#!/usr/bin/env perl
use utf8;
use Getopt::Long;
use Pod::Usage;
use English qw( -no_match_vars ) ;           # Avoids regex performance penalty
use Acme::ProgressBar;
use Path::Tiny;
use Modern::Perl;
use Unterwegs::Geo::OGR::DataSource::Pg;
use Unterwegs::Geo::OGR::DataSource::GPX;
use Unterwegs::Helper;
use Carp qw(carp croak);
use Data::Dumper;
use Unterwegs::HRM;
use Path::Iterator::Rule;

my $gpx_extension = qr/\.gpx$/;

my $pg_datasource;
my $tour_rs;

sub get_hrm_file {
    my $gpx_file = shift;

    return path($gpx_file->parent, $gpx_file->basename('.gpx') . '.hrm');
}

sub get_datetime {
    my ($year, $month, $day, $hour, $minute, $second, $timezone) = @_;
    return  DateTime->new(
        year => $year,
        month => $month,
        day => $day,
        hour => $hour,
        minute => $minute,
        second => $second,
        time_zone => 'floating',
    );
}

sub import_tour {
    my $dir = shift;

    say "Working on tour: " . $dir->basename;
    my $tour = $tour_rs->create({name => $dir->basename});
    my @gpx_files = $dir->children($gpx_extension);
    foreach my $gpx_file(@gpx_files) {
        import_gpx_file($gpx_file, $tour->tour_id);
    }
}

sub import_gpx_file {
    my $gpx_file = shift;
    my $tour_id  = shift;
    my %track_fid_map;

    say "Importing " . $gpx_file->basename;
    my $hrm_file = get_hrm_file($gpx_file);
    my $hrm = Unterwegs::HRM->new();
    my ($hrdata, $hr_count);
    say "HRM file: " . $hrm_file if $hrm_file->is_file;
    if ($hrm_file->is_file) {
        say "Heat rate file found: $hrm_file";
        my $data = $hrm->read($hrm_file);
        $hrdata = $hrm->get_hrdata_as_href_of_time($data);
        $hr_count = scalar keys  %{$hrdata};
    }

    my $gpx_datasource = Unterwegs::Geo::OGR::DataSource::GPX->new($gpx_file);
   
    my $gps_device 
        = $gpx_file =~ /^20/ ? 'Garmin eTrex Vista HCx' : 'Polar RC3 GPS'; 

    ### import tracks
    my $gpx_tracks =  $gpx_datasource->GetLayerByName('tracks');
    my $pg_tracks  =  $pg_datasource->GetLayerByName('tracks');
    while ( my $gpx_track = $gpx_tracks->GetNextFeature() ) {
        my $pg_track = Geo::OGR::Feature->create($pg_tracks->Schema);
        my $gpx_track_fid = $gpx_track->GetFID();
        $pg_track->SetFrom($gpx_track);
        $pg_track->SetField('src', $gpx_file->basename('.gpx'));
        $pg_track->SetField('tour_id', $tour_id);
        $pg_tracks->CreateFeature($pg_track);
        $track_fid_map{$gpx_track_fid} =  $pg_track->GetFID();
    }

    ### import track points
    my $gpx_track_points    = $gpx_datasource->GetLayerByName('track_points');

    my $track_points_count = $gpx_track_points->GetFeatureCount();
    if ( $track_points_count < 5 ) {
        croak "Not enough track points";
    } 
    if ($hrm_file->is_file) {
        warn("Count of Points in GPX ($track_points_count)" 
                ." and HRM ($hr_count) differ")
                unless $track_points_count == $hr_count;
    }
    
    my $pg_track_points = $pg_datasource->GetLayerByName('track_points');
    progress {
        while ( my $gpx_track_point = $gpx_track_points->GetNextFeature() ) {
            my $pg_track_point
                = Geo::OGR::Feature->create($pg_track_points->Schema);
            $pg_track_point->SetFrom($gpx_track_point);
            $pg_track_point->SetField('desc', $gps_device);
            $pg_track_point->SetField('src', $gpx_file->basename('.gpx'));
            $pg_track_point->SetField(
                'track_fid',
                $track_fid_map{ $gpx_track_point->GetField('track_fid') },
            );
            if ($hrm_file->is_file) {
                my $dt = get_datetime($gpx_track_point->GetField('time'));
                my $timestr = $dt->strftime("%FT%TZ");
                say $timestr;
                if (exists $hrdata->{ $timestr }) {
                    $pg_track_point->SetField('hr', $hrdata->{$timestr}{heart_rate});
                    $pg_track_point->SetField('ele', $hrdata->{$timestr}{altitude} );
                    $pg_track_point->SetField('speed', $hrdata->{$timestr}{speed} );
                } else { 
                    carp "No heart rate data for '$timestr'"; 
                }
            }
            if ($gps_device eq 'Polar RC3 GPS') {
                my $dt = get_datetime($gpx_track_point->GetField('time'));
                $dt->set_time_zone('UTC');
                my $timezone = 100;
                $pg_track_point->SetField('time',
                    $dt->year, $dt->month, $dt->day, $dt->hour, 
                    $dt->minute, $dt->second, $timezone
                );
            }
            $pg_track_points->CreateFeature($pg_track_point);
        }
    };
}


### get options 

my($opt_help, $opt_man, $config_dir);

GetOptions(
    'help!' => \$opt_help,
    'man!'  => \$opt_man,
)
    or pod2usage( "Try '$PROGRAM_NAME --help' for more information." );

pod2usage( -verbose => 1 ) if $opt_help;
pod2usage( -verbose => 2 ) if $opt_man;

### read path of gpx directories

my $gpx_path = shift @ARGV or pod2usage( -verbose => 1 );

$gpx_path = path($gpx_path);

croak("Path to gpx files: $gpx_path doesn't exist") unless $gpx_path->is_dir;

$pg_datasource = Unterwegs::Geo::OGR::DataSource::Pg->new();

my $schema = Unterwegs::Helper::get_schema();
$tour_rs = $schema->resultset('Tour');

### iterator for walking recursivly and searching for gpx files

my $rule = Path::Iterator::Rule->new;
$rule->dir;
my $next = $rule->iter( $gpx_path, {sorted => 1} );

while ( defined( my $dir = $next->() ) ) {
    my $path = path($dir);
    next unless $path->children( qr/$gpx_extension/ );
    import_tour($path);
}

=encoding utf-8

=head1 NAME

    import.pl - Imports data from gpx and hrm files into a database

=head1 SYNOPSIS

    import.pl [options] [base path to gpx files]

         Options:
                 --help         display this help and exit
                 --man          display extensive help

         Examples:
                 import.pl <path to gpx files>
                 import.pl --help
                 import.pl --man 
                                                                                                                  

=head1 DESCRIPTION

    Imports data from into a database.


=head1 AUTHOR

    Albert Schröder <albert.schroeder@ur.de>

=head1 LICENSE

    This library is free software. You can redistribute it and/or modify
        it under the same terms as Perl itself.

=cut

