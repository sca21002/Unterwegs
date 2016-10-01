use strict;
use warnings;

use Unterwegs;
use Plack::Builder;
use Plack::Middleware::CrossOrigin;

my $app = Unterwegs->apply_default_middlewares(Unterwegs->psgi_app);
builder {
    enable 'CrossOrigin', origins => '*';
    $app;
};

