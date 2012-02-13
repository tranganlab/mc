// unsafe

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

    int *pfield1 = &(s1.value);
    foo();
 
    int *pfield2 = &(s1.key);
    foo();

    *pfield1 = 10;
    *pfield2 = 20;

    //@ assert (s1.value == 1);
    //@ assert (s1.key == 2);
}
