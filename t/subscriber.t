use strict;
use warnings;
use feature 'say';
use Time::HiRes;
use Data::Dumper;

use K::Raw;

my $handle = khpu("localhost", 6010, "");

k($handle, ".u.sub[`;`]");

my $NANOS_PER_SEC     = 1_000_000_000;
my $EPOCH_OFFSET_SECS = 946684800;
my $EPOCH_OFFSET_NANO = $EPOCH_OFFSET_SECS * $NANOS_PER_SEC;

while (my $recv = K::Raw::listen($handle)) {
    my $t = Time::HiRes::time;
    # print Dumper($recv);

    # [ 'upd', 'table', { dictionary of update} ]
    my (undef, $table, $values) = @{ $recv };

    # use Data::Dumper;
    # say Dumper($values);

    # my $epoch_time_nano = $values->{time}->[0] + $EPOCH_OFFSET_NANO;
    # my $epoch_time_secs = $epoch_time_nano / $NANOS_PER_SEC;

    my $k_latency = $t - $values->{time}->[0];

    say "$$> $table: $values->{time}->[0] | $t (latency: $k_latency)";

    # say Dumper($values);
}

# my $recv = K::Raw::listen($handle);
# use Data::Dumper;
# print Dumper($recv);

# sleep 5;

kclose($handle);

# use Test::More;
# use t::QServer;
#
# test_qserver {
#     my $port = shift;
#
#     use_ok 'K';
#
#     my $k = K->new(port => $port);
#
#     is $k->cmd('4 + 4'), 8, 'make an int';
#
#     is_deeply $k->cmd(q/"abc"/), [qw/a b c/], 'make char vector';
#
#     is $k->cmd(q/2012.03.24D12:13:14.15161728/),
#        '385906394151617280',
#        'timestamp';
# };
#
# END { done_testing; }
