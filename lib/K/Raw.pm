package K::Raw;
use strict;
use warnings;
use XSLoader;

our $VERSION = '0.01';

XSLoader::load('K', $VERSION);

1;

__END__

=pod

=head1 NAME

K::Raw - Perl bindings for K

=head1 DESCRIPTION

K bindings

=head1 AUTHORS

Whitney Jackson C<< <whitney@cpan.org> >>

=head1 COPYRIGHT & LICENSE

    Copyright (c) 2011 Whitney Jackson. All rights reserved This program is
    free software; you can redistribute it and/or modify it under the same
    terms as Perl itself.

=cut

