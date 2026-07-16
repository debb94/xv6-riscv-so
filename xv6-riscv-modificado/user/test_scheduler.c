#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

int main(int argc, char *argv[]) {
    int id = atoi(argv[1]);

    printf("Proceso %d INICIO (PID=%d)\n", id, getpid());

    volatile int x = 0;
    for (int i = 0; i < 800000000; i++)
        x++;

    printf("Proceso %d FIN (PID=%d)\n", id, getpid());

    exit(0);
}