package K::Raw;
use strict;
use warnings;
use XSLoader;
use Exporter;

our $VERSION = '0.01';
our @ISA     = qw(Exporter);
our @EXPORT  = qw(khpu khpun k kclose);

XSLoader::load('K', $VERSION);

1;

__END__

=pod

=head1 NAME

K::Raw - Perl bindings for K

=head1 DESCRIPTION

C<K> wraps the C library defined by
L<k.h|http://code.kx.com/wsvn/code/kx/kdb%2B/c/c/k.h>  and described here
L<http://code.kx.com/wiki/Cookbook/InterfacingWithC> .

=head1 AUTHORS

Whitney Jackson C<< <whitney@cpan.org> >>

=head1 COPYRIGHT & LICENSE

    Copyright (c) 2011 Whitney Jackson. All rights reserved This program is
    free software; you can redistribute it and/or modify it under the same
    terms as Perl itself.

=cut

