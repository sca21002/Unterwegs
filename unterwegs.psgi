use strict;
use warnings;

use Unterwegs;

my $app = Unterwegs->apply_default_middlewares(Unterwegs->psgi_app);
$app;

