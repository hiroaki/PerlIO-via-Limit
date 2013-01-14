use strict;
use Test::More tests => 4;

use PerlIO::via::Limit sensitive => "hey!";
is( PerlIO::via::Limit->sensitive, "hey!", 'PerlIO::via::Limit::sensitive');

PerlIO::via::Limit->sensitive(undef);
is( PerlIO::via::Limit->sensitive, undef, 'set PerlIO::via::Limit::sensitive to undef');

PerlIO::via::Limit->sensitive("yahoo!");
is( PerlIO::via::Limit->sensitive, "yahoo!", 'set PerlIO::via::Limit::sensitive to string');

PerlIO::via::Limit->sensitive(sub { die "oops!" });
is( ref(PerlIO::via::Limit->sensitive), 'CODE', 'set PerlIO::via::Limit::sensitive to ref to CODE');
