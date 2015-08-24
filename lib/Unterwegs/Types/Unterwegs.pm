use utf8;
package Unterwegs::Types::Unterwegs;

# ABSTRACT: Types library for Unterwegs specific types 

use strict;
use warnings;
use Carp qw(confess);

# predeclare our own types
use MooseX::Types -declare => [ qw(
    GeoOGRDataSource
    GeoOGRDriver
) ];

use MooseX::Types::Moose qw(
    Bool
    Str
);

class_type GeoOGRDataSource, {class => 'Geo::OGR::DataSource'},
class_type GeoOGRDriver, {class => 'Geo::OGR::Driver'};

1;
