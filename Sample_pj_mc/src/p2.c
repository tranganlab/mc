// safe

#include <assert.h>;

void foo(int **pp, int *py){
    *pp = py;
}

int main(){
    int *q, y = 5;
    q = 0;
    foo(&q, &y);
       
    //@ assert (*q == 5);
    
    return 1;
}

