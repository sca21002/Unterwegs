use utf8;
package Unterwegs::Types;

# ABSTRACT: Types library for Unterwegs specific types 

use strict;
use warnings;
use Type::Library
   -base,
   -declare => qw();
      use Type::Utils -all;
      use Types::Standard -types;

1;
