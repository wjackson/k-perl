use strict;
use warnings;
use Test::More;
use Test::Exception;
use t::QServer;

use ok 'K::Raw';

test_qserver {
    my $port = shift;

    my $handle = khpu("localhost", $port, "");
    
    ok $handle > 0, 'connected';

    scalar_tests($handle);

    vector_tests($handle);

    mixed_list_tests($handle);

    dict_test($handle);

    table_test($handle);

    kclose($handle);
};

sub scalar_tests {
    my ($handle) = @_;

    ok  k($handle, '2 = 2'), 'parse true';
    ok !k($handle, '2 = 3'), 'parse false';

    is k($handle, '`int$7'),    7,   'parse int';
    is k($handle, '"c"'),       'c', 'parse char';
    is k($handle, '`short$12'), 12,  'parse short';
    is k($handle, '`long$13'),  13,  'parse long';

    my $real = k($handle, '`real$13.7');
    ok $real > 13.699999, 'real lower bound';
    ok $real < 13.700001, 'real upper bound';

    is k($handle, '`float$13.7'), 13.7,  'parse float';
    is k($handle, '`foo'),        'foo', 'parse symbol';

    is k($handle, '2012.03.24D23:25:13.123'),
       '385946713123000000', 'parse timestamp';

    is k($handle, '385946713123000000j'),
       '385946713123000000', 'parse long';

    is k($handle, '`month$3'),   3,    'parse month';
    is k($handle, '2012.03.24'), 4466, 'parse date';
    
    is k($handle, '17D12:13:14.000001234'),
       '1512794000001234', 'parse timespan';

    is k($handle, '`minute$4'),   4,        'parse minute';
    is k($handle, '`second$5'),   5,        'parse second';
    is k($handle, '12:13:14.15'), 43994150, 'parse time';

    my $datetime = k($handle, '2012.03.24T12:13:14.01');
    is sprintf('%.3f', $datetime), '4466.509', 'parse datetime';

    throws_ok { k($handle, 'does_not_exist') } qr/^does_not_exist at/,
        'croaked properly on error';

    # XXX: test nulls
}

sub vector_tests {
    my ($handle) = @_;

    is_deeply k($handle, '(0b;1b;0b)'), [0, 1, 0],   'parse bool vector';

    is_deeply k($handle, '"abc"'),      [qw(a b c)], 'parse char vector';

    is_deeply k($handle, '(7h;8h;9h)'), [7, 8, 9],   'parse short vector';

    is_deeply k($handle, '(7i;8i;9i)'), [7, 8, 9],   'parse int vector';

    is_deeply k($handle, '(7j;8j;9j)'), [qw(7 8 9)], 'parse long vector';

    is_deeply k($handle, '(7e;8e;9e)'), [7, 8, 9],   'parse real vector';

    is_deeply k($handle, '(7f;8f;9f)'), [7, 8, 9],   'parse float vector';

    is_deeply k($handle, '(`a;`b;`c)'), [qw(a b c)], 'parse symbol vector';
}

sub mixed_list_tests {
    my ($handle) = @_;

    is_deeply k($handle, '(1b;8i;9j)'), [1, 8, 9], 'parse mixed list of nums';

    is_deeply
        k($handle, '((1e;2i;(3f;4j));"x")'),
        [
            [
                1,
                2,
                [3,4],
            ],
            'x',
        ],
        'parse complex mixed list';
}

sub dict_test {
    my ($handle) = @_;

    # dictionary
    is_deeply
        k($handle, '`foo`bar!(1;2)'),
        {
            foo => 1,
            bar => 2,
        },
        'parse dictionary';

    # one key dictionary
    is_deeply
        k($handle, '`foo!1'),
        1,
        'parse dictionary with one val';

    is_deeply
        k($handle, '`foo`bar!((1;2);(3;4))'),
        {
            foo => [ 1, 2],
            bar => [ 3, 4 ],
        },
        'parse dictionary w/ list values';
}

sub table_test {
    my ($handle) = @_;

    # table
    is_deeply
        k($handle, '([] grr: (`aaa;`bbb;`ccc); bla: (`xxx;`yyy;`zzz))'),
        {
            grr => [qw(aaa bbb ccc)],
            bla => [qw(xxx yyy zzz)],
        },
        'parse table';

    is_deeply
        k($handle, '([] hah: `symbol$(`aaa;`bbb;`ccc))'),
        {
            hah => [qw(aaa bbb ccc)],
        },
        'parse single column table';

    # table w/ primary key
    is_deeply
        k($handle, '([p: (`a;`b); q: (`c;`d) ] foo: (`aaa;`bbb); bar: (`ccc;`ddd))'),
        [
            {
                p => [qw(a b)],
                q => [qw(c d)],
            },
            {
                foo => [qw(aaa bbb)],
                bar => [qw(ccc ddd)],
            }
        ],
        'parse table w/ primary key';
}

done_testing;
