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
 
    int **ppi1 = &pi1;
    foo ();

    int **ppi2 = &pi2;
    foo ();
   
    **ppi1 = 100;
    
    //@ assert ((i == 100) && (*pi1 == 100) && (*pi2 == 100) && (**ppi1 == 100) && (**ppi2 == 100));   
}
