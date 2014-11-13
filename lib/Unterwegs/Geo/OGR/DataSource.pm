use utf8;
package Unterwegs::Geo::OGR::DataSource;

# ABSTRACT: Destination for imported gpx data

use Geo::OGR;
use Moose;
use MooseX::AttributeShortcuts;
use Unterwegs::Types qw(Bool GeoOGRDataSource GeoOGRDriver Str);

has 'connectstr' => ( is => 'ro', isa => Str);

has 'drivername' => ( is => 'ro', isa => Str );

has 'update' => ( is => 'ro', isa => Bool );

has 'driver' => ( 
    is => 'lazy', 
    isa => GeoOGRDriver,
);

has 'datasource' => (
    is => 'lazy',
    isa => GeoOGRDataSource,
    handles => [qw(GetLayerByName Layers)],
);

sub _build_datasource {
    my $self = shift;

    return $self->driver->Open($self->connectstr, $self->update);
}

sub _build_driver {
    my $self = shift;

    my $driver = Geo::OGR::GetDriverByName($self->drivername)
        or confess "Driver '" . $self->drivername ."' not available";
    return $driver;
}


 __PACKAGE__->meta->make_immutable();

1;
