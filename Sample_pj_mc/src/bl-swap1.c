// safe

#include <assert.h>
#include <anlab_malloc.h>


void swap1(int *a, int *b) {
    int tmp = *a;
    *a = *b;
    *b = tmp;
}

void swap2(int *a, int *b) {
    *a = *a + *b;
    *b = *a - *b;
    *a = *a - *b;
}

void main () {
    int *a, *b, tmp;

    int *i, *j;

    int v1 = 1, v2 = 2;
    

    i = malloc(4);
    j = malloc(4);

    if ((i == 0) || (j == 0)) return;

    *i = v1;
    *j = v2;

    swap1 (i,  j);
	
    //@ assert ((*i == v2) || (*j == v1));    
}
