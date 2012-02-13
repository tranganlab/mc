// unsafe

#include <assert.h>

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
	int i, j;
	int v1 = 1, v2 = 2;

	i = v1;
	j = v2;

	swap1 (&i, &j);
        
        //@ assert (i != v2);
}
