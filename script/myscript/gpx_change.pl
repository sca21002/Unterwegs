#!/usr/bin/env perl
use utf8;
use Modern::Perl;
use Getopt::Long;
use Pod::Usage;
use English qw( -no_match_vars ) ;           # Avoids regex performance penalty
use FindBin qw($Bin);
use Path::Tiny;
use lib path($Bin)->parent(2)->child('lib')->stringify; 
use Log::Log4perl qw(:easy);
use warnings  qw(FATAL utf8);    # fatalize encoding glitches
use open      qw(:std :utf8);    # undeclared streams in UTF-8

use Geo::Gpx;

use Data::Dumper;

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

croak("Path to gpx files: $gpx_path doesn't exist") unless $gpx_path->is_dir;

my @gpx_files = $gpx_path->children( qr/\.gpx$/ );

my $out_path = path('/media/sca21002/Windows/Users/sca21002/Documents/Polar/out/');

foreach my $gpx_file (@gpx_files) {
    say "Working on '" . $gpx_file->basename . "'."; 
    my $fh = $gpx_file->filehandle("<");
    
    my $gpx = Geo::Gpx->new( input => $fh, use_datetime => 1 );
    my $time = $gpx->time();
    $time->set_year(2015);
    
    my $tracks = $gpx->tracks();
    
    foreach my $track (@$tracks) {
        foreach my $segment (@{$track->{segments}}) {
            foreach my $point (@{$segment->{points}}) {
                say $point->{time};
                $point->{time}->set_year(2015);
            }
        }
     
    
    }
    
    my $gpx_new = Geo::Gpx->new();
    $gpx_new->tracks( $tracks );
    my $xml = $gpx_new->xml( '1.0' );
    
    my $out_basename = $gpx_file->basename;
    $out_basename =~ s/^13/15/;

    my $outfile = $out_path->child( $out_basename );
    
    $outfile->spew_utf8($xml);

    my $hrm_file = $gpx_file;
    $hrm_file =~ s/\.gpx$/\.hrm/;
    $hrm_file = path($hrm_file);
    my $out_hrm_basename = $hrm_file->basename;
    $out_hrm_basename =~ s/^13/15/;
    my $hrm_outfile = $out_path->child($out_hrm_basename);
   
    my $hrm_data = $hrm_file->slurp_utf8;
    $hrm_data =~ s/^Date=2013/Date=2015/m or
        say("Ersetzen 2013 --> 2015 gescheitert für $hrm_file");

    $hrm_outfile->spew_utf8($hrm_data);

}    

=encoding utf-8

=head1 NAME

    gpx_change.pl - Change a gpx files

=head1 SYNOPSIS

    gpx_change.pl [options] [path to gpx files]

         Options:
                 --help         display this help and exit
                 --man          display extensive help

         Examples:
                 gpx_change.pl <path to gpx files>
                 gpx_change.pl --help
                 gpx_change.pl --man 
                                                                                                                  

=head1 DESCRIPTION

    Change gpx files in a directory


=head1 AUTHOR

    Albert Schröder <albert.schroeder@ur.de>

=head1 LICENSE

    This library is free software. You can redistribute it and/or modify
        it under the same terms as Perl itself.

=cut
