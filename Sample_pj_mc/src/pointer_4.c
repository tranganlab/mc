// unsafe

#include <assert.h>

void foo();

void main()
{
    int i;
    foo();
     
    int *pi1 = &i;
    foo();

    int **pi2 = &pi1;
    //@ assert (**pi2 == i);

    pi1 = 0;
    //@ assert (**pi2 == i);
}
