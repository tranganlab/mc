// safe

#include <assert.h>

void main () {
    int *a, *b, tmp;

    int i, j;

    int v1, v2;

    i = v1;
    j = v2;

    a = &i;
    *a = 5;
    
    b = &j;
    *b = 5;
    
    //@ assert (i == j);
}
