use strict;
use warnings;
use Test::More;
use t::QServer;

use ok 'K::Raw';

test_qserver {
    my $port = shift;

    my $conn =  K::Raw::khpu("localhost", $port, "");
    
    ok $conn > 0, 'connected';

    ok  K::Raw::k($conn, '2 = 2'),              'parse true';
    ok !K::Raw::k($conn, '2 = 3'),              'parse false';
    is  K::Raw::k($conn, '`int$7'),      7,     'parse int';
    is  K::Raw::k($conn, '"c"'),         'c',   'parse char';
    is  K::Raw::k($conn, '`short$12'),   12,    'parse short';
    is  K::Raw::k($conn, '`long$13'),    13,    'parse long';

    my $real = K::Raw::k($conn, '`real$13.7');
    ok $real > 13.699999, 'real lower bound';
    ok $real < 13.700001, 'real upper bound';

    is K::Raw::k($conn, '`float$13.7'), 13.7,  'parse float';
    is K::Raw::k($conn, '`foo'),        'foo', 'parse symbol';

    is K::Raw::k($conn, '2012.03.24D23:25:13.123'),
       '385946713123000000', 'parse timestamp';

    is K::Raw::k($conn, '385946713123000000j'),
       '385946713123000000', 'parse long';

    is K::Raw::k($conn, '`month$3'),   3,    'parse month';
    is K::Raw::k($conn, '2012.03.24'), 4466, 'parse date';
    
    is K::Raw::k($conn, '17D12:13:14.000001234'),
       '1512794000001234', 'parse timespan';

    is K::Raw::k($conn, '`minute$4'),   4,        'parse minute';
    is K::Raw::k($conn, '`second$5'),   5,        'parse second';
    is K::Raw::k($conn, '12:13:14.15'), 43994150, 'parse time';

    my $datetime = K::Raw::k($conn, '2012.03.24T12:13:14.01');
    is sprintf('%.3f', $datetime), '4466.509', 'parse datetime';
};

done_testing;
