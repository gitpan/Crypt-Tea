/*
 * $Id: TEA.xs,v 0.92 2001/03/21 09:49:21 ams Exp $
 * Copyright 2001 Abhijit Menon-Sen <ams@wiw.org>
 */

#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#ifndef sv_undef
#define sv_undef PL_sv_undef
#endif

MODULE = Crypt::TEA     PACKAGE = Crypt::TEA    PREFIX = tea_
PROTOTYPES: DISABLE

void
tea_crypt(input, output, ks, rounds, dir)
    char *  input = NO_INIT
    SV *    output
    char *  ks = NO_INIT
    int     rounds
    int     dir
    STRLEN  inlen  = NO_INIT
    STRLEN  outlen = NO_INIT
    STRLEN  kslen  = NO_INIT
    CODE:
    {
        input = SvPV(ST(0), inlen);
        if (inlen != 8)
            croak("input must be 8 bytes long");

        ks = SvPV(ST(2), kslen);

        if (output == &sv_undef)
            output = sv_newmortal();
        outlen = 8;

        if (!SvUPGRADE(output, SVt_PV))
            croak("cannot use output as lvalue");

        tea_crypt((unsigned char *)input,
                  (unsigned char *)SvGROW(output, 8), ks, rounds, dir);

        SvCUR_set(output, outlen);
        *SvEND(output) = '\0';
        SvPOK_only(output);
        SvTAINT(output);
        ST(0) = output;
    }
