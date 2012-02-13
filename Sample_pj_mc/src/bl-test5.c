// safe

#include <assert.h>
#include <anlab_malloc.h>

void main () {
    int *x, *y ;

    x = malloc (1);
    y = malloc (1);

    if ((x == 0) || (y == 0)) return;

    *x = 7;

    y = x;

    //@ assert (*x < 10);
}
