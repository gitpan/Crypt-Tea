/*
 * $Id: tea.h,v 0.99 2001/03/28 16:36:13 ams Exp $
 * Copyright 2001 Abhijit Menon-Sen <ams@wiw.org>
 */

struct tea {
    int rounds;
    unsigned long int key[4];
};

struct tea *tea_setup(unsigned char *key, int rounds);
void tea_crypt(struct tea *t,
               unsigned char *input, unsigned char *output,
               int decrypt);
