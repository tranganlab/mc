// safe

#include <assert.h>
#include <anlab_malloc.h>

int a,b;
struct buf {
    int x;
    int y;
};

void g (struct buf *p_){
    struct buf *p;

    p = (struct buf *) p_;

    if (p -> x == 0) {
        //@ assert (0);
    }
}
  
void f() {
    struct buf *p;

    p = malloc(1);
    if (p == 0) return;
    if (p -> x == 0) return;
    g(p);
}


void main(){
    f();
}
