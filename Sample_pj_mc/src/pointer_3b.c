// safe

#include <assert.h>

void p1(int ***pi)
{
    ***pi = 1;
}

void p2 (int **pi)
{
    p1 (&pi);
}

void p3 (int *pi)
{
    p2 (&pi);
}

void main()
{
    int i = 2;

    p3 (&i);    

    //@ assert (i == 1);
}
