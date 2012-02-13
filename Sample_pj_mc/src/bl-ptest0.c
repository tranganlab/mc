// safe

#include <assert.h>
#include <anlab_malloc.h>

void main () {
    int *a, *b, tmp;

    a = malloc(4);
    if (a == 0) return;

    *a = 5;
	
    b = a;

    //@ assert (*b == 5);	
}
