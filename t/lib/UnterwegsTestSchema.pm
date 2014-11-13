use utf8;
package # hide from PAUSE
    UnterwegsTestSchema;
 
use Modern::Perl;
use Unterwegs::Schema;
use Path::Class qw(dir file);
use Config::General;


my $attrs = {
    sqlite_version => 3.3,
    add_drop_table => 1,
    no_comments    => 1,
    quote_identifiers => 1,
    sources => ['Track'],
} ;

my $var_dir =  file(__FILE__)->dir->parent->subdir('var');
my $db_file = file( $var_dir, 'unterwegs.db' );

sub get_schema {
    my $dsn    = $ENV{"UNTERWEGS_TEST_SCHEMA_DSN"}
                 || "dbi:SQLite:${db_file}";
    my $dbuser = $ENV{"UNTERWEGS_TEST_SCHEMA_DBUSER"} || '';
    my $dbpass = $ENV{"UNTERWEGS_TEST_SCHEMA_DBPASS"} || '';
 
    return Unterwegs::Schema->connect($dsn, $dbuser, $dbpass,
        {
            quote_names    => 1,
            sqlite_unicode => 1,
        }                                      
    );
}
 
sub init_schema {
    my $self = shift;
    my %args = @_;
 
    my $schema = $self->get_schema;

    $schema->deploy( $attrs );
 
    $self->populate_schema($schema) if $args{populate};
    
    my $config = {
        name => 'Unterwegs Test Suite',
        'Model::UnterwegsDB' => {
            connect_info => $schema->storage->connect_info,
        },
    };
    my $config_file = file( $var_dir, 'unterwegs.conf' );
    Config::General::SaveConfig( $config_file, $config );    
        
    return $schema;
}

sub populate_schema {
    my $self = shift;
    my $schema = shift;
 
    $schema->storage->dbh->do("PRAGMA synchronous = OFF");
 
    $schema->storage->ensure_connected;
 
    # $schema->create_initial_data;
    #$self->create_test_data($schema);
}

sub create_test_data {
 
    my ($self, $schema)=@_;
    my @data;

    my $data = {
    };
    
    $schema->resultset('Track')->create($data);
    
    my $admin = $schema->resultset('User')->create({
        username => 'admin',
        password => 'test',
    });
}

1;
