package K::Raw;
use strict;
use warnings;
use XSLoader;
use Exporter;

our $VERSION = '0.04';
our @ISA     = qw(Exporter);
our @EXPORT  = qw(khpu khpun k kclose);

XSLoader::load('K', $VERSION);

1;

__END__

=pod

=head1 NAME

K::Raw - Low-level Perl bindings for k (aka q, aka kdb, aka kx)

=head1 DESCRIPTION

C<K::Raw> wraps the C library defined by
L<k.h|http://code.kx.com/wsvn/code/kx/kdb%2B/c/c/k.h>  and described here
L<http://code.kx.com/wiki/Cookbook/InterfacingWithC> .

=head1 SYNOPSIS

    use K::Raw;

    my $handle = khpu("localhost", $port, "");

    k($handle, '4 + 4'); # 8

    k($handle, q/"abc"/); # [ 'a', 'b', 'c' ]

    k($handle, q/`foo`bar!(1;2)/); # { foo => 1, bar => 2 }

    k($handle, q/2012.03.24D12:13:14.15161728/); # '385906394151617280'

    kclose($handle);

=head1 SUBS

=head2 khpu

=head2 khpun

=head2 k

=head2 kclose

=head1 SEE ALSO

L<K>, L<Kx>, L<http://kx.com>

=head1 REPOSITORY

L<http://github.com/wjackson/k-perl>

=head1 AUTHORS

Whitney Jackson C<< <whitney@cpan.org> >>

=head1 COPYRIGHT & LICENSE

    Copyright (c) 2011 Whitney Jackson. All rights reserved This program is
    free software; you can redistribute it and/or modify it under the same
    terms as Perl itself.

=cut
