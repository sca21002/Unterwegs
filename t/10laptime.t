use strict;
use warnings;
use Test::More;
use FindBin qw($Bin);
use Path::Tiny;
use lib path($Bin)->parent->child('lib')->stringify;
use UBR::DBIx::Class::Schema::Helper;
use Data::Dumper;

BEGIN { 
    use_ok 'Unterwegs::Schema::Result::LapTime'
}

my $helper = UBR::DBIx::Class::Schema::Helper->new(
    name => 'unterwegs',
    config_dir => path($Bin)->child('etc'),
    schemaclass => 'Unterwegs::Schema',
    model => 'Model::UnterwegsDB',
);
ok(my $schema = $helper->get_schema(), 'got a schema object');

my $rs= $schema->resultset( 'LapTime' )->search( {},
  {
    bind  => [ 491, 491 ]
  }
);

is($rs->count(), 10, '10 hits found');

done_testing();
