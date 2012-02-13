// safe

#include <assert.h>

struct s {
    int value;
    int key;
};

void foo();

void main()
{
    struct s s1 = {.value = 1, .key = 2};
    foo();

    int *pfield = &(s1.value);
    foo();

    *pfield = 10;

    //@ assert (s1.value == 10);
}
