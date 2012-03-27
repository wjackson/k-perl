/*
 * functions for mapping k structs to perl variables
 */
#include "k.h"
#include "kparse.h"
#include <string.h>

SV* sv_from_k(K k) {
    SV* result;
    if (k->t < 0) {
        result = scalar_from_k(k);
    }
    else if (k->t > 0) {
        result = vector_from_k(k);
    }
    else {
        result = mixed_list_from_k(k);
    }

    return result;
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

        case 128: // error
            croak(k->s);
            break;

        default:
            croak("unrecognized scalar type '%d'\n", k->t);
            break;
    }

    return result;
}

SV* vector_from_k(K k) {
    SV *result = NULL;

    switch (k->t) {

        case KB: // boolean
            result = bool_vector_from_k(k);
            break;

        case KG: // byte
        case KC: // char
            result = byte_vector_from_k(k);
            break;

        case KH: // short
            result = short_vector_from_k(k);
            break;

        case KI: // int
        case KM: // month
        case KD: // date
        case KU: // minute
        case KV: // second
        case KT: // time
            result = int_vector_from_k(k);
            break;

        case KJ: // long
        case KP: // timestamp
        case KN: // timespan
            result = long_vector_from_k(k);
            break;

        case KE: // real
            result = real_vector_from_k(k);
            break;

        case KF: // float
        case KZ: // time *don't use*
            result = float_vector_from_k(k);
            break;

        case KS: // symbol
            result = symbol_vector_from_k(k);
            break;

        case XT: // table or flip
            result = table_from_k(k);
            break;

        case XD: // dict or table w/ primary keys
            result = xd_from_k(k);
            break;

        case 100: // function
            return &PL_sv_undef;
            break;

        case 101: // generic null
            return &PL_sv_undef;
            break;

        case 102: // not sure actually. the q cmd '{:}[]' returns a 102h
            return &PL_sv_undef;
            break;

        default:
            croak("unrecognized vector type '%d'\n", k->t);
            break;
    }

    return newRV_noinc((SV*)result);
}

/*
 * K structs of type XD are either a partitioned table or a dictionary.
 * Dispath accordingly.
 */
SV* xd_from_k(K k) {
    if (kK(k)[0]->t == XT && kK(k)[1]->t == XT) {
        return ptable_from_k(k);
    }
    else if (kK(k)[0]->t == KS) {
        return dict_from_k(k);
    }
    else {
        croak("Unrecognized XD (dictionary) form");
    }
}

SV* ptable_from_k(K k) {
    AV* av = newAV();
    K t0   = kK(k)[0]; // partitioned tables have 2 sub-tables
    K t1   = kK(k)[1];

    av_push(av, newRV_noinc( table_from_k(t0) ) );
    av_push(av, newRV_noinc( table_from_k(t1) ) );

    return (SV*) av;
}

SV* dict_from_k(K k) {
    int i;
    SV **key;
    SV **val;
    HV *hv = newHV();
    HE *store_ret;

    SV* keys_ref = sv_from_k( kK(k)[0] );
    SV* vals_ref = sv_from_k( kK(k)[1] );

    AV* keys = (AV*) SvRV( keys_ref );
    AV* vals = (AV*) SvRV( vals_ref );

    int key_count = av_len(keys) + 1;

    for (i = 0; i < key_count; i++) {
        key = av_fetch(keys, i, 0);
        val = av_fetch(vals, i, 0);

        store_ret = hv_store_ent(hv, *key, *val, 0);
        if (store_ret == NULL) {
            croak("Failed to convert k hash entry to perl hash entry");
        }

        SvREFCNT_inc(*val);
    }

    SvREFCNT_dec(keys_ref);
    SvREFCNT_dec(vals_ref);

    return (SV*)hv;
}

SV* table_from_k(K k) {
    K dict = k->k;
    return dict_from_k(dict);
}

SV* mixed_list_from_k(K k) {
    AV *av = newAV();
    int i = 0;

    for (i = 0; i < k->n; i++) {
        av_push(av, sv_from_k( kK(k)[i] ) );
    }

    return newRV_noinc((SV* )av);
}

/*
 * scalar helpers
 */

SV* bool_from_k(K k) {
    if (k->g == 0) {
        return &PL_sv_undef;
    }

    return newSViv( k->g );
}

SV* char_from_k(K k) {
    if (k->g == 0) {
        return &PL_sv_undef;
    }

    char byte_str[1];
    byte_str[0] = k->g;
    return newSVpvn(byte_str, 1);
}

SV* short_from_k(K k) {
    if (k->h == nh) {
        return &PL_sv_undef;
    }

    if (k->h == wh) {
        return newSVpvn("inf", 3);
    }

    if (k->h == -wh) {
        return newSVpvn("-inf", 4);
    }

    return newSViv(k->h);
}

SV* int_from_k(K k) {
    if (k->i == ni) {
        return &PL_sv_undef;
    }

    if (k->i == wi) {
        return newSVpvn("inf", 3);
    }

    if (k->i == -wi) {
        return newSVpvn("-inf", 4);
    }

    /* return SvREFCNT_inc(newSViv(k->i)); */
    return newSViv(k->i);
}

SV* long_from_k(K k) {
    if (k->j == nj) {
        return &PL_sv_undef;
    }

    if (k->j == wj) {
        return newSVpvn("inf", 3);
    }

    if (k->j == -wj) {
        return newSVpvn("-inf", 4);
    }

    char buffer[33];
    snprintf(buffer, 33, "%Ld", k->j);
    return newSVpv(buffer, 0);
}

SV* real_from_k(K k) {
    if (isnan(k->e)) {
        return &PL_sv_undef;
    }

    return newSVnv(k->e);
}

SV* float_from_k(K k) {
    if (isnan(k->f)) {
        return &PL_sv_undef;
    }

    return newSVnv(k->f);
}

SV* symbol_from_k(K k) {
    if (strncmp(k->s, "", k->n) == 0) {
        return &PL_sv_undef;
    }

    return newSVpv(k->s, 0);
}

/*
 * vector helpers
 */

SV* bool_vector_from_k(K k) {
    AV *av = newAV();
    int i = 0;

    for (i = 0; i < k->n; i++) {
        if (kG(k)[i] == 0) {
            av_push(av, &PL_sv_undef);
            continue;
        }

        av_push(av, newSViv( kG(k)[i]) );
    }

    return (SV*)av;
}

SV* byte_vector_from_k(K k) {
    AV *av = newAV();
    char byte_str[1];
    int i = 0;

    for (i = 0; i < k->n; i++) {
        if (kG(k)[i] == 0) {
            av_push(av, &PL_sv_undef);
            continue;
        }

        byte_str[0] = kG(k)[i];
        av_push(av, newSVpvn(byte_str, 1));
    }

    return (SV*)av;
}

SV* short_vector_from_k(K k) {
    AV *av = newAV();
    int i = 0;

    for (i = 0; i < k->n; i++) {
        if (kH(k)[i] == nh) {
            av_push(av, &PL_sv_undef);
            continue;
        }

        if (kH(k)[i] == wh) {
            av_push(av, newSVpvn("inf", 3));
            continue;
        }

        if (kH(k)[i] == -wh) {
            av_push(av, newSVpvn("-inf", 4));
            continue;
        }

        av_push(av, newSViv( kH(k)[i]) );
    }

    return (SV*)av;
}

SV* int_vector_from_k(K k) {
    AV *av = newAV();
    int i = 0;

    for (i = 0; i < k->n; i++) {
        if (kI(k)[i] == ni) {
            av_push(av, &PL_sv_undef);
            continue;
        }

        if (kI(k)[i] == wi) {
            av_push(av, newSVpvn("inf", 3));
            continue;
        }

        if (kI(k)[i] == -wi) {
            av_push(av, newSVpvn("-inf", 4));
            continue;
        }

        av_push(av, newSViv( kI(k)[i]) );
    }

    return (SV*)av;
}

SV* long_vector_from_k(K k) {
    char buffer[33];

    AV *av = newAV();
    int i = 0;

    for (i = 0; i < k->n; i++) {
        if (kJ(k)[i] == nj) {
            av_push(av, &PL_sv_undef);
            continue;
        }

        if (kJ(k)[i] == wj) {
            av_push(av, newSVpvn("inf", 3));
            continue;
        }

        if (kJ(k)[i] == -wj) {
            av_push(av, newSVpvn("-inf", 4));
            continue;
        }

        snprintf(buffer, 33, "%Ld", kJ(k)[i]);
        av_push(av, newSVpv(buffer, 0) );
    }

    return (SV*)av;
}

SV* real_vector_from_k(K k) {
    AV *av = newAV();
    int i = 0;

    for (i = 0; i < k->n; i++) {
        if (isnan( kE(k)[i] )) {
            av_push(av, &PL_sv_undef);
            continue;
        }

        av_push(av, newSVnv( kE(k)[i] ) );
    }

    return (SV*)av;
}

SV* float_vector_from_k(K k) {
    AV *av = newAV();
    int i = 0;

    for (i = 0; i < k->n; i++) {
        if (isnan( kF(k)[i] )) {
            av_push(av, &PL_sv_undef);
            continue;
        }

        av_push(av, newSVnv( kF(k)[i] ) );
    }

    return (SV*)av;
}

SV* symbol_vector_from_k(K k) {
    AV *av = newAV();
    int i = 0;
    char *sym = NULL;

    for (i = 0; i < k->n; i++) {
        sym = kS(k)[i];

        if (strncmp(sym, "", strlen(sym)) == 0) {
            av_push(av, &PL_sv_undef);
            continue;
        }

        av_push(av, newSVpv( kS(k)[i], 0 ) );
    }

    return (SV*)av;
}
