package Unterwegs::Helper;

# ABSTRACT: Helper functions for Unterwegs

use Carp;
use Config::ZOMG;
use DBIx::Class::Helpers::Util qw(normalize_connect_info);
use Path::Tiny;
use Unterwegs::Schema;

sub get_connect_info {

    my $config_dir = path(__FILE__)->parent(3); 
    my $config_hash = Config::ZOMG->open(
        name => 'unterwegs',
        path => $config_dir,
    ) or confess "No config file in '$config_dir'";
    
    my $connect_info = $config_hash->{'Model::UnterwegsDB'}{connect_info};
    confess "No database connect info" unless  $connect_info;
    return normalize_connect_info(@$connect_info);
}


sub get_schema {

    my $connect_info = get_connect_info();
    my $schema = Unterwegs::Schema->connect($connect_info);
    $schema->storage->ensure_connected;
    return $schema;
}

1;
