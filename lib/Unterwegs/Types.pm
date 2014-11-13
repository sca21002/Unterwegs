package Unterwegs::Types;

# ABSTRACT: Combining Class for types libraries

use parent 'MooseX::Types::Combine';       
  
__PACKAGE__->provide_types_from( qw(
    MooseX::Types::Moose
    Unterwegs::Types::Unterwegs
));

1;
