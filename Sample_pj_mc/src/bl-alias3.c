// safe

#include <assert.h>

int x;

void set (int *x1) {
    x = 0;
    *x1 = 1;
}

void main() {
    x = 0;
    set(&x);
    //@ assert (x == 1);
}
