package Unterwegs::Schema::ResultSet::LapTime;
 
use Moose;
use namespace::autoclean;
use MooseX::NonMoose;
    extends 'DBIx::Class::ResultSet';

use Data::Dumper;

# ABSTRACT: Unterwegs::Schema::ResultSet::LapTime
 
sub BUILDARGS { $_[2] }
 
sub get_laptime {
    my ($self, $track_id) = @_;

    return $self->search( {},
        {
          bind  => [ $track_id, $track_id ]
        }
    );
}



__PACKAGE__->meta->make_immutable;
 
1;
