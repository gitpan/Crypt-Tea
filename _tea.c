/*
 * $Id: _tea.c,v 0.99 2001/03/28 16:36:13 ams Exp $
 * Copyright 2001 Abhijit Menon-Sen <ams@wiw.org>
 */

#include <stdlib.h>
#include "tea.h"

/* Endian-independent byte <-> long conversions. */

#define c2l(c, l)  (l  = (unsigned long)*c++,        \
                    l |= (unsigned long)*c++ <<  8,  \
                    l |= (unsigned long)*c++ << 16,  \
                    l |= (unsigned long)*c++ << 24)

#define l2c(l, c)  (*c++ = (unsigned char)(l      ), \
                    *c++ = (unsigned char)(l >>  8), \
                    *c++ = (unsigned char)(l >> 16), \
                    *c++ = (unsigned char)(l >> 24))

/* TEA is a 64-bit symmetric block cipher with a 128-bit key, developed
   by David J. Wheeler and Roger M. Needham, and described in their
   paper at <URL:http://www.cl.cam.ac.uk/ftp/users/djw3/tea.ps>.

   This implementation is based on their code in
   <URL:http://www.cl.cam.ac.uk/ftp/users/djw3/xtea.ps> */

struct tea *tea_setup(unsigned char *key, int rounds)
{
    struct tea *t = calloc(1, sizeof(struct tea));

    if (t) {
        t->rounds = rounds;

        c2l(key, t->key[0]);
        c2l(key, t->key[1]);
        c2l(key, t->key[2]);
        c2l(key, t->key[3]);
    }

    return t;
}

void tea_crypt(struct tea *t,
               unsigned char *input, unsigned char *output,
               int decrypt)
{
    int i, rounds;
    unsigned long int delta = 0x9E3779B9, /* 2^31*(sqrt(5)-1) */
                      *k, y, z, sum = 0;

    k = t->key;
    rounds = t->rounds;

    c2l(input, y);
    c2l(input, z);

    if (decrypt) {
        sum = delta * rounds;
        for (i = 0; i < rounds; i++) {
            z -= ((y << 4 ^ y >> 5) + y) ^ (sum + k[sum >> 11 & 3]);
            sum -= delta;
            y -= ((z << 4 ^ z >> 5) + z) ^ (sum + k[sum & 3]);
        }
    } else {
        for (i = 0; i < rounds; i++) {
            y += ((z << 4 ^ z >> 5) + z) ^ (sum + k[sum & 3]);
            sum += delta;
            z += ((y << 4 ^ y >> 5) + y) ^ (sum + k[sum >> 11 & 3]);
        }
    }

    l2c(y, output);
    l2c(z, output);
}
