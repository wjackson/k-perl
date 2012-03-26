use strict;
use warnings;
use Test::More;
use t::QServer;

use ok 'K';

test_qserver {
    my $port = shift;

    my $k = K->new(port => $port);

    is $k->cmd('4 + 4'), 8, 'make an int';

    is_deeply $k->cmd(q/"abc"/), [qw/a b c/], 'make char vector';

    is $k->cmd(q/2012.03.24D12:13:14.15161728/),
       '385906394151617280',
       'timestamp';
};

done_testing;
