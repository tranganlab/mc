// safe

#include <assert.h>;

void foo(int **pp, int **pa)
{
    *pp = *pa;
}

int main()
{
    int k = 1;
    int *a;
    a = &k;

    int *pi;
    pi = 0;

    foo(&pi, &a);
    
    //@ assert (*pi == 1);

    return 1;
}
