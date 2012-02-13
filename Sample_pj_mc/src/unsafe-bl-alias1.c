// unsafe

#include <assert.h>
#include <anlab_malloc.h>

int *x;
int *y;

void main(){
    x = malloc (1);
    y = malloc (1);
    if ((x != 0) && (y != 0)){
        *x = 0;
        y = x;
        *y = 5;
        //@ assert (*x != 5);
    }
}
