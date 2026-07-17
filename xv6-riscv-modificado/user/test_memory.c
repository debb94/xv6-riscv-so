#include "kernel/types.h"
#include "user/user.h"

int main(void) {
    printf("\n");
    printf("=========== TEST MEMORIA (FIFO vs LIFO) ===========\n");

    printf("Paso 1: Agotando la memoria libre del sistema...\n");
    // Pedimos memoria hasta que el kernel nos diga que ya no hay (retorna -1)
    while(sbrk(4096) != (char*)-1) {
        // Llenando la memoria...
    }
    printf("Memoria agotada!\n\n");

    // Ahora la lista de páginas libres (freelist) del Kernel está VACIA.
    // Las próximas páginas que liberemos serán las únicas disponibles en la lista.

    trace_memory(1);

    printf("Paso 2: Liberando 3 paginas (P3, P2, P1)\n");
    
    printf("Liberando P3\n");
    sbrk(-4096);
    
    printf("Liberando P2\n");
    sbrk(-4096);
    
    printf("Liberando P1\n");
    sbrk(-4096);

    printf("\nPaso 3: Reservando 2 paginas nuevas (D y E)\n");
    // EXPLICACIÓN:
    // Si tu sistema es FIFO (Cola): D obtendrá P3 (la primera en hacer la fila)
    // Si tu sistema es LIFO (Pila): D obtendrá P1 (la última que se apiló)

    printf("Reservando D\n");
    sbrk(4096);

    printf("Reservando E\n");
    sbrk(4096);

    printf("===================================================\n");

    trace_memory(0);

    exit(0);
}