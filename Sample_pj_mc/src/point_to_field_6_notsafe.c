// unsafe

#include <assert.h>

struct s {
    int value;
    struct s *next;
};

void foo();

void main()
{
    struct s s1 = {.value = 1, .next = 0};
    foo();

    struct s **pfield2 = &(s1.next);
    foo();

    *pfield2 = &s1;
    foo();

    (*pfield2) -> value = 100;
    foo();
    
    (*pfield2) -> next = 0;

    //@ assert (s1.value == 100);
    //@ assert (s1.next -> value == 100);
}
