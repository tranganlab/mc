// unsafe

#include <assert.h>

void foo();

struct s {
    int value;
};

void main()
{
    struct s s1 = {.value = 1};
    foo();

    struct s *ps1 = &s1;
    foo();

    ps1->value = 100;
    foo();

    struct s *ps2 = &s1;
    //@ assert (ps2->value == 1);
}
