/*
 * $Id: TEA.xs,v 1.01 2001/03/30 17:24:15 ams Exp $
 * Copyright 2001 Abhijit Menon-Sen <ams@wiw.org>
 */

#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#include "tea.h"

#ifndef sv_undef
#define sv_undef PL_sv_undef
#endif

typedef struct tea * Crypt__TEA;

MODULE = Crypt::TEA     PACKAGE = Crypt::TEA    PREFIX = tea_
PROTOTYPES: DISABLE

Crypt__TEA
tea_setup(key, rounds)
    char *  key    = NO_INIT
    int     rounds
    STRLEN  keylen = NO_INIT
    CODE:
    {
        key = SvPV(ST(0), keylen);
        if (keylen != 16)
            croak("key must be 16 bytes long");

        RETVAL = tea_setup((unsigned char *)key, rounds);
    }
    OUTPUT:
        RETVAL

void
tea_DESTROY(t)
    Crypt__TEA t
    CODE: free(t);

void
tea_crypt(t, input, output, decrypt)
    Crypt__TEA t
    char *  input  = NO_INIT
    SV *    output
    int     decrypt
    STRLEN  inlen  = NO_INIT
    STRLEN  outlen = NO_INIT
    CODE:
    {
        input = SvPV(ST(1), inlen);
        if (inlen != 8)
            croak("input must be 8 bytes long");

        if (output == &sv_undef)
            output = sv_newmortal();
        outlen = 8;

        if (SvREADONLY(output) || !SvUPGRADE(output, SVt_PV))
            croak("cannot use output as lvalue");

        tea_crypt(t,
                  (unsigned char *)input,
                  (unsigned char *)SvGROW(output, outlen),
                  decrypt);

        SvCUR_set(output, outlen);
        *SvEND(output) = '\0';
        SvPOK_only(output);
        SvTAINT(output);
        ST(0) = output;
    }
