// safe

#include <assert.h>
#include <anlab_malloc.h>

struct FOO {
    int data;
    int flag;
};


int foo (){
    return 0;
}

int main(){
    int skip;
    struct FOO *x, *y;

    x = malloc(1);
    y = malloc(1);

    if ((x == 0) || (y == 0)) {return 1;}

    x->data = 1;

    foo();

    y = x;

    foo();

    y -> data = 0;

    foo ();
    
    //@ assert (x -> data == 0);
    return 1;
}

