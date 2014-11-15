use utf8;
package Unterwegs::Geo::OGR::DataSource::Pg;

# ABSTRACT: PostgreSQL database as datasource for geo data

use Moose;
    extends('Unterwegs::Geo::OGR::DataSource');

use Unterwegs::Helper;

has '+connectstr' => (is => 'lazy');
has '+drivername' => (default => 'PostgreSQL');
has '+update'     => (default => 1);

sub _build_connectstr {
    my $self = shift;

    my $connect_info = Unterwegs::Helper->get_connect_info();
    my ($dbname) = $connect_info->{dsn} =~ /dbi:Pg:dbname=(.*)$/;
    my $user = $connect_info->{user};
    my $password = $connect_info->{password} || '';
    return "Pg:dbname='$dbname' user='$user' password='$password'";
}

__PACKAGE__->meta->make_immutable();

1;
