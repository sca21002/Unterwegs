use utf8;
package Unterwegs::Geo::GDAL::Dataset::Pg;

# ABSTRACT: PostgreSQL database as vector layer source for geo data

use Moose;
    extends('Unterwegs::Geo::GDAL::Dataset');

use Unterwegs::Helper;

has '+access'     => (default => 'Update');
has '+type'       => (default => 'Vector');
has '+name'       => (default => 'PG:');
has '+options'    => (is => 'lazy');


sub _build_options {
    my $self = shift;

    my $connect_info = Unterwegs::Helper->get_connect_info();
    my ($dbname) = $connect_info->{dsn} =~ /dbi:Pg:dbname=(.*)$/;
    my $user = $connect_info->{user};
    my $password = $connect_info->{password} || '';

    my $options = {
        dbname => $dbname, 
        user => $user, 
        password => $password,
    }; 
   
    return $options;
}

__PACKAGE__->meta->make_immutable();

1;
