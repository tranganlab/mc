// unsafe

#include <assert.h>

int *x;
int *y;

void set( int *x) {
    *x = 1;
}

void main(){
    int x;
    
    x = 0;
    y = &x;
    set(&x);

    //@ assert (*y == 0);
}
