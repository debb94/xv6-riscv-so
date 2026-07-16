#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

int
main(void)
{
    char *argv1[] = { "test_scheduler", "1", 0 };
    char *argv2[] = { "test_scheduler", "2", 0 };
    char *argv3[] = { "test_scheduler", "3", 0 };

    // Proceso 1
    if (fork() == 0) {
        exec("test_scheduler", argv1);
        exit(1);
    }

    pause(20);

    // Proceso 2
    if (fork() == 0) {
        exec("test_scheduler", argv2);
        exit(1);
    }

    pause(20);

    // Proceso 3
    if (fork() == 0) {
        exec("test_scheduler", argv3);
        exit(1);
    }

    wait(0);
    wait(0);
    wait(0);

    printf("Todos los procesos terminaron\n");

    exit(0);
}