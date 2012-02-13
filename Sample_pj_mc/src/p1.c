// safe

#include <assert.h>;

void foo (int **a, int **b){
    *a = *b;
}

int main(){
    int *p, *q;
    p = q = 0;
	
    int x = 3;
    q = &x;
	
    foo(&p, &q);

    //@ assert (*p == 3);

    return 1;
}

