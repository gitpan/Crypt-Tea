/*
 * $Id: tea.h,v 1.10 2001/05/04 07:55:01 ams Exp $
 * Copyright 2001 Abhijit Menon-Sen <ams@wiw.org>
 */

#include <stdlib.h>

#ifdef WIN32
typedef unsigned long uint32_t;
#else
#include <inttypes.h>
#endif

struct tea {
    int rounds;
    uint32_t key[4];
};

struct tea *tea_setup(unsigned char *key, int rounds);
void tea_crypt(struct tea *self,
               unsigned char *input, unsigned char *output,
               int decrypt);
