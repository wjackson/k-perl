package K;
use Moose;
use namespace::autoclean;
use K::Raw;

has host => (
    is      => 'ro',
    isa     => 'Str',
    default => 'localhost',
);

has port => (
    is      => 'ro',
    isa     => 'Int',
    default => 5000,
);

has user => (
    is        => 'ro',
    isa       => 'Str',
    predicate => 'has_user',
);

has password => (
    is        => 'ro',
    isa       => 'Str',
    predicate => 'has_password',
);

has handle => (
    is         => 'ro',
    isa        => 'Int',
    lazy_build => 1,
);

sub _build_handle {
    my ($self) = @_;

    my $handle = khpu($self->host, $self->port, $self->_credentials);

    confess 'Failed to connect to Q server' if $handle <= 0;

    return $handle;
}

sub _credentials {
    my ($self) = @_;

    return '' if !$self->has_user || !$self->has_password;

    return join ':', $self->user, $self->password;
}

sub cmd {
    my ($self, $cmd) = @_;

    return k($self->handle, $cmd);
}

sub async_cmd {
    my ($self, $cmd) = @_;

    return k(-$self->handle, $cmd);
}

sub DEMOLISH {
    my ($self) = @_;

    kclose($self->handle);
}

__PACKAGE__->meta->make_immutable;
1;

__END__

=pod

=head1 NAME

K - Perl bindings for k (aka q, aka kdb, aka kx)

=head1 SYNOPSIS

    my $k = K->new(
        host     => 'kserver.example.com',
        port     => 5000,
        user     => 'awhitney',
        password => 'kdb4eva',
    );

    $k->cmd( '4 + 4' ); # 8

    $k->cmd( q/"abc"/ ); # [ 'a', 'b', 'c' ]

    $k->cmd( q/`foo`bar!(1;2)/ ); # { foo => 1, bar => 2 }

    $k->cmd( q/2012.03.24D12:13:14.15161728/ ); # '385906394151617280'

    # table
    $k->cmd( q/([] foo: (`a;`b); bar: (`c;`d))/ );
    # {
    #   foo => ['a', 'b'],
    #   bar => ['c', 'd'],
    # }

    # table w/ primary key
    $k->cmd( q/([p: (`a;`b)] foo: (`b;`c); bar: (`d;`e))/ );
    # [
    #   {
    #     p   => ['a', 'b']
    #   }
    #   {
    #     foo => ['b', 'c'],
    #     bar => ['d', 'e'],
    #   },
    # ]

=head1 DESCRIPTION

Connect to a remote K or Q instance.  Execute commands.  Read replies.

C<K> wraps the C library defined by
L<k.h|http://code.kx.com/wsvn/code/kx/kdb%2B/c/c/k.h>  and described here
L<http://code.kx.com/wiki/Cookbook/InterfacingWithC> .

C<K>'s OO interface is a thin layer of sugar on top of L<K::Raw> which mimics
the C library as faithfully as possible.

For now, C<K> returns very simple Perl representations of k values.  For
example, inside k timestamps are 64-bit ints where the value is the number of
nanoseconds since 2001.01.01D00:00:00.000 .  For such values, C<K> returns the
int value as a string (ex: '385906394151617280').  This will probably change.

=head1 SEE ALSO

L<K::Raw>, L<Kx>, L<http://kx.com>

=head1 REPOSITORY

L<http://github.com/wjackson/k-perl>

=head1 AUTHORS

Whitney Jackson C<< <whitney@cpan.org> >>

=head1 COPYRIGHT & LICENSE

    Copyright (c) 2011 Whitney Jackson. All rights reserved This program is
    free software; you can redistribute it and/or modify it under the same
    terms as Perl itself.

=cut
