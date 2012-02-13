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

    int ***pppi1 = &ppi1;
    foo ();
   
    ***pppi1 = 99;

    //@ assert ((i == 99) && (*pi1 == 99) && (*pi2 == 99) && (**ppi1 == 99) && (***pppi1 == 99));   
}
