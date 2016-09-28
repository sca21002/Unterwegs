use utf8;
package Unterwegs::Geo::GDAL::Dataset::GPX;

# ABSTRACT: GPX file as vector layer ource for geo data

use Moose;
    extends('Unterwegs::Geo::GDAL::Dataset');

use Unterwegs::Helper;


around BUILDARGS => sub {
    my $orig  = shift;
    my $class = shift;

    if ( @_ == 1 && ref $_[0] eq 'Path::Tiny' ) {
        return $class->$orig( name => $_[0]->stringify );
    }
    else {
        return $class->$orig(@_);
    }
};

__PACKAGE__->meta->make_immutable();

1;
