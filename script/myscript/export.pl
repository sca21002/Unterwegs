#!/usr/bin/env perl
use utf8;
use Modern::Perl;
use Path::Tiny;
use FindBin qw($Bin);
use lib path($Bin)->parent(2)->child('lib')->stringify;
use Geo::OGR;
use Unterwegs::Helper;
use Data::Dumper;


#my $drivername = 'PostgreSQL';
#my $driver = Geo::OGR::GetDriverByName($drivername);

my $connect_info = Unterwegs::Helper->get_connect_info();
my ($dbname) = $connect_info->{dsn} =~ /dbi:Pg:dbname=(.*)$/;
my $user = $connect_info->{user};
my $password = $connect_info->{password} || '';
my $connectstr = "PG:";
my $update = 1;

say "START";

#my $pg_datasource = Geo::OGR::Driver::Open($connectstr);

#my $pg_datasource = Geo::GDAL::OpenEx(Name => $connectstr, Drivers => ['PostgreSQL']) or
# die "connection faild";

my $pg_datasource = Geo::GDAL::Open(
    Name => 'PG:', 
    Type => 'Vector', 
    Options => {
        dbname => $dbname, user=>$user
    }
);

my $driver = Geo::GDAL::Driver('GPX');

$driver->Copy(Name => 'export.gpx', Src => $pg_datasource, Options => {GPX_USE_EXTENSIONS => 'YES'});

# my $dataset = $driver->Create(Name => 'export.gpx', Options => {GPX_USE_EXTENSIONS => 'YES'});

# my $layer = $pg_datasource->GetLayer('track_points');

# say ref $layer;

# my $layer_new = $dataset->CopyLayer($layer, 'track_points');
