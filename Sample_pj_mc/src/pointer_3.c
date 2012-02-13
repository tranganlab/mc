// safe

#include <assert.h>

void foo();

void p(int ***pi)
{
    ***pi = 1;
}

void main()
{
    int i = 2;
    foo();    

    int *pi1 = &i;
    foo();

    int **pi2 = &pi1;
    foo();
    
    p(&pi2);
    
    //@ assert (i == 1);
}
