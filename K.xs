#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"
#include <errno.h>
#define NEED_sv_2pv_flags
#include "ppport.h"
#include <xs_object_magic.h>
#include "k.h"

char* hi() {
    return "hi there\n";
}

MODULE = K::Raw	PACKAGE = K::Raw   PREFIX = k_
PROTOTYPES: DISABLE

void
k_hi()
    CODE:
        printf( hi() );
