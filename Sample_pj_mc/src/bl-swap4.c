// unsafe

#include <assert.h>
#include <anlab_malloc.h>

void main () {
    int *a, *b, tmp;

    int *i, *j;

    int v1 = 1, v2 = 2;
    

    i = malloc(4);
    j = malloc(4);
    if ((i == 0) || (j == 0)) return;

    *i = v1;
    *j = v2;
	
    a = i;
    b = j;
	
    tmp = *a;
    *a = *b;
    *b = tmp;
	
    a = i;
    b = j;
	
    tmp = *a;
    *a = *b;
    *b = tmp;

    //@ assert ((*i == v2) && (*j == v1));    
}

