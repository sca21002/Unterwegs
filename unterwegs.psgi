use strict;
use warnings;

use Unterwegs;
use Plack::Builder;

my $app = Unterwegs->apply_default_middlewares(Unterwegs->psgi_app);
builder {
    # enable 'Debug', panels => [ qw(Response DBITrace Memory Timer DBIC::QueryLog) ];
    enable 'CrossOrigin', origins => '*', headers => '*';
    $app;
};

