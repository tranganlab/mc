// safe

#include <assert.h>;

int * f(int *a, int *b) {
    if (*a > *b) return a;
    else return b;
}

int main(int x, int y){
    int *p = 0, *q = 0;

    p = &x;
    q = &y;
	
    //if ((f(p,q) == p) && (&x != &y)){
    if (f(p,q) == p){
        //@ assert (x > y);
    }
    else {
        // @ assert (x <= y);
    }

    return 1;
}
