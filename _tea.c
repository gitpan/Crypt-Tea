/*
 * $Id: _tea.c,v 0.96 2001/03/25 19:26:31 ams Exp $
 * Copyright 2001 Abhijit Menon-Sen <ams@wiw.org>
 */

/* Endian-independent byte <-> long conversions. */

#define c2l(c, l)  (l  = (unsigned long)*c++,       \
                    l |= (unsigned long)*c++ <<  8, \
                    l |= (unsigned long)*c++ << 16, \
                    l |= (unsigned long)*c++ << 24)

#define l2c(l, c)  (*c++ = (unsigned char)(l       & 0xff), \
                    *c++ = (unsigned char)(l >>  8 & 0xff), \
                    *c++ = (unsigned char)(l >> 16 & 0xff), \
                    *c++ = (unsigned char)(l >> 24 & 0xff))

/* TEA is a 64-bit symmetric block cipher with a 128-bit key, developed
   by David J. Wheeler and Roger M. Needham, and described in their
   paper at <URL:http://www.cl.cam.ac.uk/ftp/users/djw3/tea.ps>.

   This implementation is based on their code in
   <URL:http://www.cl.cam.ac.uk/ftp/users/djw3/xtea.ps> */

void tea_crypt(unsigned char *input, unsigned char *output,
               unsigned char *key, int rounds, int decrypt)
{
    int i;
    unsigned long int k[4], y, z, sum = 0,
        delta = 0x9E3779B9; /* 2^31*(sqrt(5)-1) */

    /* 64 bit input */
    c2l(input, y);
    c2l(input, z);

    /* 128 bit key */
    c2l(key, k[0]);
    c2l(key, k[1]);
    c2l(key, k[2]);
    c2l(key, k[3]);

    if (decrypt == 0) {
        for (i = 0; i < rounds; i++) {
            y += ((z << 4 ^ z >> 5) + z) ^ (sum + k[sum & 3]);
            sum += delta;
            z += ((y << 4 ^ y >> 5) + y) ^ (sum + k[sum >> 11 & 3]);
        }
    } else {
        sum = delta * rounds;
        for (i = 0; i < rounds; i++) {
            z -= ((y << 4 ^ y >> 5) + y) ^ (sum + k[sum >> 11 & 3]);
            sum -= delta;
            y -= ((z << 4 ^ z >> 5) + z) ^ (sum + k[sum & 3]);
        }

    }

    l2c(y, output);
    l2c(z, output);
}
