# $Id: TEA.pm,v 1.01 2001/03/30 17:24:15 ams Exp $
# Copyright 2001 Abhijit Menon-Sen <ams@wiw.org>

package Crypt::TEA;

use strict;
use Carp;
use DynaLoader;
use vars qw( @ISA $VERSION );

@ISA = qw( DynaLoader );
($VERSION) = q$Revision: 1.01 $ =~ /(\d+\.\d+)/;

bootstrap Crypt::TEA $VERSION;

use constant keysize   => 16;
use constant blocksize => 8;

sub new
{
    my ($class, $key, $rounds) = @_;

    croak "Usage: ".__PACKAGE__."->new(\$key [, \$rounds])" unless $key;

    return Crypt::TEA::setup($key, $rounds || 32);
}

sub encrypt
{
    my ($self, $data) = @_;

    croak "Usage: \$tea->encrypt(\$data)" unless ref($self) && $data;
    $self->crypt($data, $data, 0);
}

sub decrypt
{
    my ($self, $data) = @_;

    croak "Usage: \$tea->decrypt(\$data)" unless ref($self) && $data;
    $self->crypt($data, $data, 1);
}

1;

__END__

=head1 NAME

Crypt::TEA - Tiny Encryption Algorithm

=head1 SYNOPSIS

use Crypt::TEA;

$tea = Crypt::TEA->new($key);

$ciphertext = $tea->encrypt($plaintext);

$plaintext  = $tea->decrypt($ciphertext);

=head1 DESCRIPTION

TEA is a 64-bit symmetric block cipher with a 128-bit key and a variable
number of rounds (32 is recommended). It has a low setup time, and
depends on a large number of rounds for security, rather than a complex
algorithm. It was developed by David J. Wheeler and Roger M. Needham,
and is described at
<http://www.ftp.cl.cam.ac.uk/ftp/papers/djw-rmn/djw-rmn-tea.html>.

This module implements TEA encryption. It supports the Crypt::CBC
interface, with the following functions.

=head2 Functions

=over

=item blocksize

Returns the size (in bytes) of the block (8, in this case).

=item keysize

Returns the size (in bytes) of the key (16, in this case).

=item new($key, $rounds)

This creates a new Crypt::TEA object with the specified key. The
optional rounds parameter specifies the number of rounds of encryption
to perform, and defaults to 32.

=item encrypt($data)

Encrypts blocksize() bytes of $data and returns the corresponding
ciphertext.

=item decrypt($data)

Decrypts blocksize() bytes of $data and returns the corresponding
plaintext.

=back

=head1 SEE ALSO

<http://www.vader.brad.ac.uk/tea/tea.shtml>

Crypt::CBC, Crypt::Blowfish, Crypt::DES

=head1 ACKNOWLEDGEMENTS

=over 4

=item Dave Paris, for taking the time to discuss and review the initial
version of this module, making several useful suggestions, and
contributing tests.

=back

=head1 AUTHOR

Abhijit Menon-Sen <ams@wiw.org>

Copyright 2001 Abhijit Menon-Sen. All rights reserved.

This is free software; you may redistribute and/or modify it under the
same terms as Perl itself.
