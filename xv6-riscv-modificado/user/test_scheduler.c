#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

int main(int argc, char *argv[]) {
    /* int id = 0;

    if(argc > 1) {
        id = atoi(argv[1]);
    }

    printf("Proceso %d iniciado\n", id);
    printf("PID=%d Inicio\n", getpid());

    for(int i = 0; i < 50; i++) {

        if(i % 10 == 0) 
            printf("PID=%d Iteracion=%d\n", getpid(), i);

        for(volatile int j = 0; j < 50000000; j++);
    }

    printf("PID=%d Fin\n",getpid());
    exit(0); */
    int id = atoi(argv[1]);

    printf("Proceso %d INICIO (PID=%d)\n", id, getpid());

    volatile int x = 0;
    for (int i = 0; i < 800000000; i++)
        x++;

    printf("Proceso %d FIN (PID=%d)\n", id, getpid());

    exit(0);
}