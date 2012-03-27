#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"
#include <errno.h>
#define NEED_sv_2pv_flags
#include "ppport.h"
#include "k.h"
#include "kparse.h"

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
k_khpun(host, port, credentials, timeout)
    char *host
    int port
    char *credentials
    int timeout
    CODE:
        int i = khpun(host, port, credentials, timeout);
        RETVAL = newSViv(i);
    OUTPUT:
        RETVAL

void
k_kclose(handle)
    int handle
    CODE:
        kclose(handle);

SV*
k_k(handle, kcmd)
    int handle
    char *kcmd
    CODE:
        K resp;
        if (handle > 0) {      // synchronous
            resp = k(handle, kcmd, (K)0);
            RETVAL = sv_from_k(resp);
            r0(resp);
        }
        else if (handle < 0) { // asynchronous
            resp = k(handle, kcmd, (K)0);
            if (resp == NULL) {
                croak("Failed to execute command asynchronously");
            }
            RETVAL = &PL_sv_undef;
        }
        else {
            croak("Attempt to call k on an invalid handle");
        }
    OUTPUT:
        RETVAL
