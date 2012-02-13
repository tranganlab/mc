// safe

#include <assert.h>;

int *x;
int *y;

int set( int *a) {
    return *a;
}

void main(){
    int x, y;
    x = 4;
    y = 5;

    if (set(&x) < set(&y)) {
        //@ assert(y >= 4);
    }
}
        
