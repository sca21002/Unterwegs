use utf8;
package Unterwegs::Import::Dest::Pg;

# ABSTRACT: Destination for imported gpx data

use Geo::OGR;
use Moose;
use MooseX::AttributeShortcuts;
use Unterwegs::Types qw(GeoOGRDriver);

has 'driver' => ( 
    is => 'lazy', 
    isa => GeoOGRDriver,
    handles => [qw(Open)]
);    

sub _build_driver {
    my $self = shift;

    my $driver = Geo::OGR::GetDriverByName('PostgreSQL')
        or confess 'PostgreSQL driver not available';
    return $driver;
}

 __PACKAGE__->meta->make_immutable();

1;
