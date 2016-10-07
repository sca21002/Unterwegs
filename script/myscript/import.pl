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
use Unterwegs::HRM;
use Carp qw(carp croak);
use Path::Iterator::Rule;
use Log::Log4perl qw(:easy);
use Log::Log4perl::Util::TimeTracker;
use DateTime::Format::Strptime;
use Data::Dumper;

$Data::Dumper::Maxdepth = 5;

### Logdatei initialisieren

my $logfile = path($Bin)->parent(2)->child('import_gpx.log');

Log::Log4perl->easy_init(
    { level   => $DEBUG,
      file    => ">" . $logfile,
    },
    { level   => $TRACE,
      file    => 'STDOUT',
    },
);

### get options 

my($opt_help, $opt_man);

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

croak("Path to gpx files: $gpx_path doesn't exist") unless $gpx_path->exists;

my $gpx_extension = qr/\.gpx$/;

my $schema = Unterwegs::Helper::get_schema();
my $track_rs = $schema->resultset('Track');
my $tour_rs = $schema->resultset('Tour');

my $timer = Log::Log4perl::Util::TimeTracker->new();

if ($gpx_path->is_dir) {

    ### iterator for walking recursivly and searching for gpx files

    my $rule = Path::Iterator::Rule->new;
    $rule->dir;
    my $next = $rule->iter( $gpx_path, {sorted => 1} );

    while ( defined( my $dir = $next->() ) ) {
        my $path = path($dir);
        next unless $path->children( qr/$gpx_extension/ );
        import_tour($path);
    }
} elsif ($gpx_path->is_file) {


  my $tour_name = shift @ARGV or pod2usage("Name of the Tour is missing");

  my $tour = $tour_rs->find_or_create({name => $tour_name});

  pod2usage("Tour '$tour_name' not found in the database") unless $tour; 

  import_gpx_file($gpx_path, $tour->tour_id);
}

sub import_tour {
    my $dir = shift;
    INFO("Working on tour: ", $dir->basename);
    my $tour = $tour_rs->find_or_create({name => $dir->basename});
    my @gpx_files = $dir->children($gpx_extension);
    foreach my $gpx_file(@gpx_files) {
        import_gpx_file($gpx_file, $tour->tour_id);
    }
    my $msecs = $timer->milliseconds();
    INFO("Elapsed: ", sprintf(
        "%d hr %d min %d sec", $msecs/(3600_000), $msecs/(60_000), $msecs/1000
    ) );  
}

sub get_hrm_file {
    my $gpx_file = shift;

    return path($gpx_file->parent, $gpx_file->basename('.gpx') . '.hrm');
}

sub is_new {
    my $gpx_file = shift;

    my $basename = $gpx_file->basename('.gpx');
    return $track_rs->search({src => $basename})->count < 1;
}

sub trk {
    my($twig, $trk, $cb)= @_;

    my $i = 0;
    my @track_points = map {
            {
                wkb_geometry       => \[
                    sprintf(
                        "ST_SetSRID(ST_MakePoint(%f,%f),%u)",
                        $_->att('lon'), $_->att('lat'), 4326
                    )
                ],
                track_seg_id       => 0,
                track_seg_point_id => $i++, 
                      map { $_->gi => $_->text } $_->children,
            } 
        } $trk->descendants("trkpt");

    $cb->({
        name         => $trk->first_child('name')->text,
        track_points => \@track_points, 
    });
    $twig->purge;
}


sub import_gpx_file {
    my $gpx_file = shift;
    my $tour_id  = shift;

    my $hrdata;
    my $hr_count;

    my $gps_device = $gpx_file->basename =~ /^20/ 
        ? 'Garmin eTrex Vista HCx' : 'Polar RC3 GPS'; 
    
    INFO("\tGPX-File: ", $gpx_file->basename);

    # Polar GPS saves time according to the set clock time
    my $time_zone = $gps_device eq 'Polar RC3 GPS' ? 'Europe/Berlin' : 'UTC'; 

    my $strp = DateTime::Format::Strptime->new(
    	pattern   => '%FT%TZ',
    	locale    => 'de_DE',
    	time_zone => $time_zone,
	);

    unless( is_new($gpx_file) ) {
        INFO("\t\tis already imported!");
        return;
    }    
    INFO("\tImporting ", $gpx_file->basename);
    
    my $hrm_file = get_hrm_file($gpx_file);
    my $hrm = Unterwegs::HRM->new();
    if ($hrm_file->is_file) {
        INFO("\tHeat rate file found: ", $hrm_file->basename);
        my $data = $hrm->read($hrm_file);
        $hrdata = $hrm->get_hrdata_as_href_of_time($data);
        $hr_count = scalar keys  %{$hrdata};
    }

    my $callback = sub {
        my $track = shift;

        INFO("\t\tTrack: ", $track->{name});
        $track->{file} = $gpx_file->basename('.gpx');
        $track->{src} = $gps_device;
        $track->{tour_id} = $tour_id;

        foreach my $track_point ( @{ $track->{track_points} } ) {

            if (my $timestr = $track_point->{time}) {

                if ( exists $hrdata->{ $timestr } ) {
                    @{ $track_point }{ qw(hr ele speed) } 
                        =  @{ $hrdata->{$timestr} }{ qw(heart_rate altitude speed) };
                }
                
                my $dt = $strp->parse_datetime($timestr);
                $dt->set_time_zone('UTC') unless $dt->time_zone->name eq 'UTC';
    		    $track_point->{time} = $dt;            
            }    
        }

        $track_rs->create($track);
    };

    my $twig= new XML::Twig(
        twig_handlers => { 
            trk    => sub{ trk(@_, $callback) }
        }
    );
 
    $twig->parsefile($gpx_file->stringify); 
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

    Imports data from gpx and hrm file into a database.

=head1 AUTHOR

    Albert Schröder <albert.schroeder@ur.de>

=head1 LICENSE

    This library is free software. You can redistribute it and/or modify
        it under the same terms as Perl itself.

=cut
