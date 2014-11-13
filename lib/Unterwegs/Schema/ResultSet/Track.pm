package Unterwegs::Schema::ResultSet::Track;
 
use Moose;
use namespace::autoclean;
use MooseX::NonMoose;
    extends 'DBIx::Class::ResultSet';

use Data::Dumper;
use Unterwegs::Geo::JSON::FeatureCollection;



# ABSTRACT: Unterwegs::Schema::ResultSet::Track
 
sub BUILDARGS { $_[2] }
 
sub search_with_len {
    my $self = shift;
    my $cond = shift || {};
   
    return $self->search(
        $cond,
        {   
            '+select' => [ 
                \'ST_Length(Geography(wkb_geometry))/1000',
                \'ST_AsGeoJSON(wkb_geometry)',
            ],
            '+as'     => [qw( len geojson_geometry ) ],      
        },
    );
}

sub as_feature_collection {
    my $self = shift;

    my @feature_objects;
    while (my $row = $self->next) {
        my $ft = $row->as_feature_object;
        push @feature_objects, $ft;
    }
    return Unterwegs::Geo::JSON::FeatureCollection->new({
        features => \@feature_objects,
    });
}

__PACKAGE__->meta->make_immutable;
 
1;
