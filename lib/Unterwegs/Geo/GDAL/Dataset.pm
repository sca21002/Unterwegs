use utf8;
package Unterwegs::Geo::GDAL::Dataset;

# ABSTRACT: A set of raster bands or vector layer source

use Geo::GDAL;
use Moose;
use MooseX::AttributeShortcuts;
use Types::Standard qw(Enum HashRef Str);
use Unterwegs::Types qw(GeoGDALDataset);

has 'name' => ( is => 'ro', isa => Str );

has 'access' => ( is => 'ro', isa => Enum[ qw(ReadOnly Update) ] );

has 'type' => ( is => 'ro', isa => Enum[ qw(Any Vector Raster) ] );

has 'options' => ( is => 'ro', isa => HashRef[Str] );

has 'dataset' => (
    lazy => 1,
    builder => 1,
    isa => GeoGDALDataset,
    handles => [qw(GetLayer)],
);

sub _build_dataset {
    my $self = shift;

    return Geo::GDAL::Open(
        Name    => $self->name,
        Access  => $self->access,
        Type    => $self->type,
        Options => $self->options,
    );
}

__PACKAGE__->meta->make_immutable();

1;
