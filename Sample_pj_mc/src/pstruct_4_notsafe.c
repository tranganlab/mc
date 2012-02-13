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

    struct s **pps1 = &ps1;
    //@ assert ((*pps1)->value == 100);
    
    *pps1 = 0;
    //@ assert (ps1->value == 100);
    // assert ((ps1 != 0) ==> (ps1->value == 100));
}
