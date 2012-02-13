// unsafe

#include <assert.h>
#include <anlab_malloc.h>

void main () {
    int *i, *j , *a, *b;

    i = malloc(1);
    if (i == 0) return;
	
    *i = 0;

    a = i;
	
    *a = 6;

    b = i;
	
    *b = 7;

    //@ assert (*i == 0);
}
