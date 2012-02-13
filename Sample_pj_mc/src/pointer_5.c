// safe

#include <assert.h>

void foo();

void main()
{
    int i = 1;
    foo ();

    int *pi1 = &i;
    foo ();

    int **pi2 = &pi1;
    //@ assert (*pi1 == i);
    //@ assert (**pi2 == i);

    *pi2 = 0;
    //@ assert (pi1 == 0);
}    
