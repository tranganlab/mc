// unsafe

#include <assert.h>

struct a {
    int value;
};

struct b {
    int key;
    struct a *pa;
};

struct c {
    int key;
    struct b *pb;
};

void foo();

void main()
{
    struct a a1 = {.value = 1};
    foo();

    struct b b1 = {.key = 2, .pa = &a1};
    foo();

    b1.pa -> value = 10;
    foo();

    struct c c1 = {.key = 3, .pb = &b1};
    foo();

    c1.pb -> pa -> value = 100;

    //@ assert (a1.value == 1);
    //@ assert (b1.pa -> value == 10);
    //@ assert (c1.pb -> pa -> value == 100);
}


