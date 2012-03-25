#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"
#include <errno.h>
#define NEED_sv_2pv_flags
#include "ppport.h"
#include "k.h"

SV* bool_from_k(K k) {
    return newSViv( k->g );
}

SV* char_from_k(K k) {
    char byte_str[1];
    byte_str[0] = k->g;
    return newSVpvn(byte_str, 1);
}

SV* short_from_k(K k) {
    return newSViv(k->h);
}

SV* int_from_k(K k) {
    return newSViv(k->i);
}

SV* long_from_k(K k) {
    char buffer[33];
    snprintf(buffer, 33, "%Ld", k->j);
    return newSVpv(buffer, 0);
}

SV* real_from_k(K k) {
    return newSVnv(k->e);
}

SV* float_from_k(K k) {
    return newSVnv(k->f);
}

SV* symbol_from_k(K k) {
    return newSVpv(k->s, 0);
}

SV* scalar_from_k(K k) {
    SV *result = NULL;

    switch (- k->t) {

        case KB: // boolean
            result = bool_from_k(k);
            break;

        case KG: // byte
        case KC: // char
            result = char_from_k(k);
            break;

        case KH: // short
            result = short_from_k(k);
            break;

        case KI: // int
        case KM: // month
        case KD: // date
        case KU: // minute
        case KV: // second
        case KT: // time
            result = int_from_k(k);
            break;

        case KJ: // long
        case KP: // timestamp
        case KN: // timespan
            result = long_from_k(k);
            break;

        case KE: // real
            result = real_from_k(k);
            break;

        case KF: // float
        case KZ: // time *don't use*
            result = float_from_k(k);
            break;

        case KS: // symbol
            result = symbol_from_k(k);
            break;

        default:
            croak("unrecognized type '%d'\n", k->t);
            break;
    }

    return result;
}

SV* vector_from_k(K k) {
    return newSViv(7);
}

SV* mixed_list_from_k(K k) {
    return newSViv(7);
}

SV* k_to_sv_ptr(K k) {
    // printf("k_to_sv_ptr\n");

    if (k->t < 0) {
        return scalar_from_k(k);
    }
    else if (k->t > 0) {
        return vector_from_k(k);
    }
    else {
        return mixed_list_from_k(k);
    }
}

MODULE = K   PACKAGE = K::Raw   PREFIX = k_
PROTOTYPES: DISABLE

SV*
k_khpu(host, port, credentials)
    char *host
    int port
    char *credentials
    CODE:
        int i = khpu(host, port, credentials);
        RETVAL = newSViv(i);
    OUTPUT:
        RETVAL

SV*
k_k(conn, kcmd)
    int conn
    char *kcmd
    CODE:
        K resp = k(conn, kcmd, (K)0);
        RETVAL = k_to_sv_ptr(resp);
    OUTPUT:
        RETVAL
