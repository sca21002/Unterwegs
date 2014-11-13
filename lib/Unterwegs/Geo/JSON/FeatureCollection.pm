use utf8;
package Unterwegs::Geo::JSON::FeatureCollection;

# ABSTRACT: FeatureCollection with jqGrid attributes

use Moose;
    extends 'Geo::JSON::FeatureCollection';

has 'page' => (
    is => 'rw',
    isa => 'Int',
);

has 'total' => (
    is => 'rw',
    isa => 'Int',
);

has 'records' => (
    is => 'rw',
    isa => 'Int',
);

__PACKAGE__->meta->make_immutable;

1;
