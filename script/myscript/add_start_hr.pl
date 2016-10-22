#!/usr/bin/env perl
use utf8;
use Path::Tiny;
use FindBin qw($Bin);
use lib path($Bin)->parent(2)->child('lib')->stringify;
use warnings  qw(FATAL utf8);    # fatalize encoding glitches
use open      qw(:std :utf8);    # undeclared streams in UTF-8
use Modern::Perl;
use Carp qw(carp croak);
use Path::Iterator::Rule;
use Unterwegs::HRM;
use Unterwegs::Helper;
use DateTime::Format::Strptime;
use Data::Dumper;

my $hrm_path = shift @ARGV or die "no path to hrm files given!";

$hrm_path = path($hrm_path);

croak("Path to hrm files '$hrm_path' doesn't exist") unless $hrm_path->exists;

my $hrm_extension = qr/\.hrm$/;

my $schema = Unterwegs::Helper::get_schema();
my $track_rs = $schema->resultset('Track');

### iterator for walking recursivly and searching for gpx files

my $rule = Path::Iterator::Rule->new;
$rule->dir;
my $next = $rule->iter( $hrm_path, {sorted => 1} );

while ( defined( my $dir = $next->() ) ) {
    my $path = path($dir);
    next unless $path->children( qr/$hrm_extension/ );
    process_dir($path);
}

sub process_dir {
    my $dir = shift;
    
    say "Working on '", $dir->basename, "'";
    my @hrm_files = $dir->children($hrm_extension);
    foreach my $hrm_file (@hrm_files) {
        process_hrm($hrm_file);
    }
}

sub process_hrm {
    my $hrm_file = shift;

    my $strp_hrm_date = new DateTime::Format::Strptime(
        pattern     => '%Y%m%d-%H:%M:%S.%1N',
        locale      => 'de_DE',
    	time_zone => 'Europe/Berlin',
        on_error    => 'croak',
    );

    my $hrm = Unterwegs::HRM->new();
    say "\tHeat rate file found: ", $hrm_file->basename;
    my $data   = $hrm->read($hrm_file);
    my $date   = $strp_hrm_date->parse_datetime(
        $data->{params}{Date} . '-' . $data->{params}{StartTime}
    );
    say "Date: ", $data->{params}{StartTime};
    say "Date: ", $date; 
    $date->set_time_zone('UTC');
    my $length = $data->{params}{Length};

    my ($file) = $hrm_file->basename =~ /(.*)$hrm_extension/; 
    my $track_hrm  = $track_rs->search({file => $file});
    my $track_cnt  = $track_hrm->count;
    if ($track_cnt > 1) {
        say $hrm_file->basename, " $track_cnt hits found";
    } elsif ($track_cnt == 0) {
        say $hrm_file->basename, " no hit found";
    } else {
        say $hrm_file->basename, " can be processed";
        my $track = $track_hrm->single;
        #        $track->update({
        #            start_hr    => $date,
        #            duration_hr => $length,
        #        });         
    }
}
