/*
 * $Id: tea.h,v 0.92 2001/03/21 09:49:21 ams Exp $
 * Copyright 2001 Abhijit Menon-Sen <ams@wiw.org>
 */

void tea_crypt(unsigned char *input, unsigned char *output,
               unsigned char *key, int rounds, int decrypt);
