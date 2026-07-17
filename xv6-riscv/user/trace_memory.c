#include "kernel/types.h"
#include "user/user.h"

int main(int argc, char *argv[]) {

    if(strcmp(argv[1], "1") == 0)
        trace_memory(1);
    else
        trace_memory(0);

    exit(0);
}