//#include <slab.h>

/* Create pseudo function "malloc" */
int anlab_random();
void *malloc(int i)
{
    if (anlab_random()){
        char a;
        return &a; 
    } else{
        return 0;
    }
}

void *malloc_array(int i)
{
    if (anlab_random()){
        char new_memory[0];
        return new_memory;
    } else{
        return 0;
    }
}

//typedef gfp_t flag_type;
/*void *kmalloc(int i, pbus_alloc_flags_t flag)
{
    char new_memory[0];
    return new_memory;

}*/

/*
void *kmalloc(size_t i, gfp_t flag)
{
    char a;//new_memory[0];
    return &a;//new_memory;

}
*/
