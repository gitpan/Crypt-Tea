/*
 * $Id: tea.h,v 1.01 2001/03/30 17:24:15 ams Exp $
 * Copyright 2001 Abhijit Menon-Sen <ams@wiw.org>
 */

#include <inttypes.h>
#include <stdlib.h>

struct tea {
    int rounds;
    uint32_t key[4];
};

struct tea *tea_setup(unsigned char *key, int rounds);
void tea_crypt(struct tea *t,
               unsigned char *input, unsigned char *output,
               int decrypt);
