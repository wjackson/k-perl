/*
 * functions for mapping k structs to perl variables
 */
#include "k.h"
#include "kparse.h"

SV* sv_from_k(K k) {
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

    AV* keys   = (AV*) SvRV( sv_from_k( kK(k)[0] ) );
    AV* values = (AV*) SvRV( sv_from_k( kK(k)[1] ) );

    int key_count = av_len(keys) + 1;

    for (i = 0; i < key_count; i++) {
        key = av_fetch(keys, i, 0);
        val = av_fetch(values, i, 0);

        store_ret = hv_store_ent(hv, *key, *val, 0);
        if (store_ret == NULL) {
            croak("Failed to convert k hash entry to perl hash entry");
        }
    }

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

/*
 * vector helpers
 */

SV* bool_vector_from_k(K k) {
    AV *av = newAV();
    int i = 0;

    for (i = 0; i < k->n; i++) {
        av_push(av, newSViv( kG(k)[i]) );
    }

    return (SV*)av;
}

SV* byte_vector_from_k(K k) {
    AV *av = newAV();
    char byte_str[1];
    int i = 0;

    for (i = 0; i < k->n; i++) {
        byte_str[0] = kG(k)[i];
        av_push(av, newSVpvn(byte_str, 1));
    }

    return (SV*)av;
}

/* SV* char_vector_from_k(K k) { */
/*     int i = 0; */
/*     char str[k->n]; */
/*  */
/*     for (i = 0; i < k->n; i++) { */
/*         str[i] = kG(k)[i]; */
/*     } */
/*  */
/*     return newSVpvn(str, k->n); */
/* } */

SV* short_vector_from_k(K k) {
    AV *av = newAV();
    int i = 0;

    for (i = 0; i < k->n; i++) {
        av_push(av, newSViv( kH(k)[i]) );
    }

    return (SV*)av;
}

SV* int_vector_from_k(K k) {
    AV *av = newAV();
    int i = 0;

    for (i = 0; i < k->n; i++) {
        av_push(av, newSViv( kI(k)[i]) );
    }

    return (SV*)av;
}

SV* long_vector_from_k(K k) {
    char buffer[33];

    AV *av = newAV();
    int i = 0;

    for (i = 0; i < k->n; i++) {
        snprintf(buffer, 33, "%Ld", kJ(k)[i]);
        av_push(av, newSVpv(buffer, 0) );
    }

    return (SV*)av;
}

SV* real_vector_from_k(K k) {
    AV *av = newAV();
    int i = 0;

    for (i = 0; i < k->n; i++) {
        av_push(av, newSVnv( kE(k)[i] ) );
    }

    return (SV*)av;
}

SV* float_vector_from_k(K k) {
    AV *av = newAV();
    int i = 0;

    for (i = 0; i < k->n; i++) {
        av_push(av, newSVnv( kF(k)[i] ) );
    }

    return (SV*)av;
}

SV* symbol_vector_from_k(K k) {
    AV *av = newAV();
    int i = 0;

    for (i = 0; i < k->n; i++) {
        av_push(av, newSVpv( kS(k)[i], 0 ) );
    }

    return (SV*)av;
}
