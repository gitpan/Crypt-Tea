/*
 * $Id: tea.h,v 1.00 2001/03/30 16:31:45 ams Exp $
 * Copyright 2001 Abhijit Menon-Sen <ams@wiw.org>
 */

#include <inttypes.h>
#include <stdlib.h>

struct tea {
    int rounds;
    u_int32_t key[4];
};

struct tea *tea_setup(unsigned char *key, int rounds);
void tea_crypt(struct tea *t,
               unsigned char *input, unsigned char *output,
               int decrypt);
