use utf8;
package Unterwegs::Geo::OGR::DataSource::GPX;

# ABSTRACT: GPX file as datasource for geo data

use Moose;
    extends('Unterwegs::Geo::OGR::DataSource');

use Unterwegs::Helper;

has '+connectstr'  => (required => 1);
has '+drivername' => (default => 'GPX');
has '+update'     => (default => 0);

around BUILDARGS => sub {
    my $orig  = shift;
    my $class = shift;

    if ( @_ == 1 && ref $_[0] eq 'Path::Tiny' ) {
        return $class->$orig( connectstr => $_[0]->stringify );
    }
    else {
        return $class->$orig(@_);
    }
};

__PACKAGE__->meta->make_immutable();

1;
