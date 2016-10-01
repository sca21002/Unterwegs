package Unterwegs::Helper;

# ABSTRACT: Helper functions for Unterwegs

use Carp;
use Config::ZOMG;
use DBIx::Class::Helpers::Util qw(normalize_connect_info);
use Path::Tiny;
use Unterwegs::Schema;

sub get_connect_info {

    my $env = $ENV{UNTERWEGS_CONFIG} || $ENV{CATALYST_CONFIG};
    my $config_dir = $env ? path($env) : path(__FILE__)->parent(3); 
    my $config_hash = Config::ZOMG->open(
        name => 'unterwegs',
        path => $config_dir,
    ) or confess "No config file in '$config_dir'";
    
    my $connect_info = $config_hash->{'Model::UnterwegsDB'}{connect_info};
    $connect_info = normalize_connect_info(@$connect_info)
        if (ref $connect_info eq 'ARRAY' );    
    confess "No database connect info" unless  $connect_info;
    return $connect_info;
}


sub get_schema {

    my $connect_info = get_connect_info();
    my $schema = Unterwegs::Schema->connect($connect_info);
    $schema->storage->ensure_connected;
    return $schema;
}

1;
