// safe

#include <assert.h>

void foo();

void main()
{
    int i = 1;
    foo ();

    int *pi1 = &i;
    foo ();

    int *pi2 = &i;
    foo ();
    
    i = 100;
    //@ assert ((*pi1 == 100) && (*pi2 == 100));   
}
