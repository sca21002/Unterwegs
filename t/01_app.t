#!/usr/bin/env perl
use Modern::Perl;
use utf8;
use Path::Class qw(dir file);
use FindBin qw($Bin);
use lib dir($Bin, 'lib')->stringify,
        dir($Bin)->parent->subdir('lib')->stringify; 
use UnterwegsTestSchema;
use Test::More;
use Data::Dumper;
use HTTP::Cookies;

BEGIN {
    use_ok ('HTTP::Request::Common') or exit;
}

ok( my $schema = UnterwegsTestSchema->init_schema(populate => 1),
    'created a test schema object' );

$ENV{CATALYST_CONFIG} = file($Bin, qw(var unterwegs.conf));
 
use_ok( 'Catalyst::Test', 'Unterwegs' );
 
done_testing();

