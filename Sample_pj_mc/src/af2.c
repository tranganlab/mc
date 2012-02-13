// safe

#include <assert.h>

void foo(int *x, int *y) {
    if (*x > *y) {
        *x = *y - *x;
            //@ assert(*x < 0);
    }
}

int main(){
    int a=2,b=1;
    int *p1,*p2;
    p1 = &a;
    p2 = &b;
    if (p1 == p2) {foo(p1,p2);}
    //@ assert (a > b);
    //@ assert (*p1 > *p2);
    return 1;
}
