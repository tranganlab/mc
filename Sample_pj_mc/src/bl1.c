// unsafe

#include <assert.h>
#include <anlab_malloc.h>

int *x;
int *y;

void main(){
    x = malloc(1);
    y = malloc(1);

    *x = 0;
    //@ assert (*x == 0);

    y = x;
    foo();

    *y = 5;
    //@ assert (*x == 5);        
}
