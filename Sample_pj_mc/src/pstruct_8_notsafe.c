// unsafe

#include <assert.h>

struct a {
    int value;
};

struct b {
    int key;
    struct a *pa;
};

void foo();

void main()
{
    struct a a1 = {.value = 1};
    foo();

    struct b b1 = {.key = 2, .pa = &a1};
    foo();

    struct b *pb1 = &b1;    
    pb1 -> pa -> value = 100;

    //@ assert (a1.value == 1);
    //@ assert (b1.pa  -> value == 100);
    //@ assert (pb1 -> pa -> value == 100);
}


