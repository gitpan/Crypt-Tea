/*
 * $Id: _tea.c,v 1.07 2001/04/19 07:01:32 ams Exp $
 * Copyright 2001 Abhijit Menon-Sen <ams@wiw.org>
 */

#include "tea.h"

/* Endian-independent byte <-> long conversions. */
#define strtonl(s) (uint32_t)(*(s)|*(s+1)<<8|*(s+2)<<16|*(s+3)<<24)

#define nltostr(l, s) \
    do {                                    \
        *(s  )=(unsigned char)((l)      );  \
        *(s+1)=(unsigned char)((l) >>  8);  \
        *(s+2)=(unsigned char)((l) >> 16);  \
        *(s+3)=(unsigned char)((l) >> 24);  \
    } while (0)

/* TEA is a 64-bit symmetric block cipher with a 128-bit key, developed
   by David J. Wheeler and Roger M. Needham, and described in their
   paper at <URL:http://www.cl.cam.ac.uk/ftp/users/djw3/tea.ps>.

   This implementation is based on their code in
   <URL:http://www.cl.cam.ac.uk/ftp/users/djw3/xtea.ps> */

struct tea *tea_setup(unsigned char *key, int rounds)
{
    struct tea *t = malloc(sizeof(struct tea));

    if (t) {
        t->rounds = rounds;

        t->key[0] = strtonl(key);
        t->key[1] = strtonl(key+4);
        t->key[2] = strtonl(key+8);
        t->key[3] = strtonl(key+12);
    }

    return t;
}

void tea_crypt(struct tea *t,
               unsigned char *input, unsigned char *output,
               int decrypt)
{
    int i, rounds;
    uint32_t delta = 0x9E3779B9, /* 2^31*(sqrt(5)-1) */
             *k, y, z, sum = 0;

    k = t->key;
    rounds = t->rounds;

    y = strtonl(input);
    z = strtonl(input+4);

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

    nltostr(y, output);
    nltostr(z, output+4);
}
