use utf8;
package Unterwegs::Types;

# ABSTRACT: Types library for Unterwegs specific types 

use strict;
use warnings;
use Type::Library
   -base,
   -declare => qw(GeoGDALDataset);
      use Type::Utils -all;
      use Types::Standard -types;

class_type GeoGDALDataset, {class => 'Geo::GDAL::Dataset'},

1;
