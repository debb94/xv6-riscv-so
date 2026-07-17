
# Sistemas Operativos - Universidad del Valle
- Author: Daniel Bolivar
- Codigo: 2178545-2724

## Repositorio Base Oficial - xv6-riscv
- [https://github.com/mit-pdos/xv6-riscv](https://github.com/mit-pdos/xv6-riscv)

## Ejecucion de los Sistemas operativos xv6-riscv y xv6-riscv-modificado

```bash
#Creacion de las imagenes
docker build -t xv6-dev .

# Ejecucion de xv6-riscv
docker run --name xv6 -it -v "$PWD/xv6-riscv:/workspace" -w /workspace xv6-dev

# Ejecucion de xv6-riscv-modificado
docker run --name xv6-modificado -it -v "$PWD/xv6-riscv-modificado:/workspace" -w /workspace xv6-dev

# ejecutar kernel:
make qemu

# Para xv6-riscv
# docker exec -it dev-xv6 bash -c "make clean && make qemu"

# # Para xv6-riscv-modificado
# docker exec -it dev-xv6-modificado bash -c "make clean && make qemu"
    
```

## Modificaciones realizadas:

1. **Modificacion sobre algoritmo de planificacion** Como primer modificacion he realizado ajustes sobre el scheduler y estructura de procesos para implementar de manera exitosa un algoritmo de planificacion FCFS (First Come First Served). De esta forma poder comparar el comportamiento de ambos sistemas operativos, entiendo que no es el algoritmo mas optimo, pero permite evidenciar de manera optima el funcionamiento o las diferencias entre ambos sistemas operativos.

2. **Modificacion sobre asignacion de memoria** Como segundo modificacion he realizado ajustes sobre el algoritmo de asignacion de memoria para implementar de manera exitosa un algoritmo de planificacion FCFS (First Come First Served). De esta forma poder comparar el comportamiento de ambos sistemas operativos, entiendo que no es el algoritmo mas optimo, pero permite evidenciar de manera optima el funcionamiento o las diferencias entre ambos sistemas operativos.

## Pruebas realizadas:

1. **Prueba sobre planificacion FCFS**

Se realiza pruebas sobre el algoritmo de planificacion FCFS.

``` bash
# Output de xv6 sin modificaciones (Round Robin), al ejecutar: test_launch
    $ test_launch
    Proceso 1 INICIO (PID=5)
    Proceso 2 INICIO (PID=6)
    Proceso 1 FIN (PID=5)
    Proceso 3 INICIO (PID=7)
    Proceso 2 FIN (PID=6)
    Proceso 3 FIN (PID=7)
    Todos los procesos terminaron

# Output de xv6-modificado para evidenciar algoritmo de planificacion FCFS, al ejecutar: test_launch
    $ test_launch
    Proceso 1 INICIO (PID=6)
    Proceso 1 FIN (PID=6)
    Proceso 2 INICIO (PID=7)
    Proceso 2 FIN (PID=7)
    Proceso 3 INICIO (PID=8)
    Proceso 3 FIN (PID=8)
    Todos los procesos terminaron

```

### Analisis de resultados de prueba - SCHEDULER:

Podemos evidenciar de manera explicita las diferencias entre ambos sistemas operativos, el sistema original xv6-riscv (sin modificaciones) implementa un algoritmo de planificacion Round Robin, el cual permite a todos los procesos tener una oportunidad de ejecutarse usando un quantum de tiempo. 

Por otro lado, el sistema operativo xv6-riscv-modificado (con modificaciones) implementa un algoritmo de planificacion FCFS (First Come First Served), permite que el proceso en ejecucion se complete antes de despachar al siguiente.


2. **Prueba sobre asignacion de memoria FCFS**

``` bash
# Output de xv6 sin modificaciones, al ejecutar: test_memory
    =========== TEST MEMORIA (FIFO vs LIFO) ===========
    Paso 1: Agotando la memoria libre del sistema...
    Memoria agotada!

    Paso 2: Liberando 3 paginas (P3, P2, P1)
    Liberando P3
    [FREE ] 0x0000000080024000
    Liberando P2
    [FREE ] 0x0000000080025000
    Liberando P1
    [FREE ] 0x0000000080026000

    Paso 3: Reservando 2 paginas nuevas (D y E)
    Reservando D
    [ALLOC] 0x0000000080026000
    Reservando E
    [ALLOC] 0x0000000080025000
    ===================================================

# Output de xv6-modificado, al ejecutar: test_memory
    =========== TEST MEMORIA (FIFO vs LIFO) ===========
    Paso 1: Agotando la memoria libre del sistema...
    Memoria agotada!

    Paso 2: Liberando 3 paginas (P3, P2, P1)
    Liberando P3
    [FREE ] 0x000000008010a000
    Liberando P2
    [FREE ] 0x00000000800f0000
    Liberando P1
    [FREE ] 0x00000000800f1000

    Paso 3: Reservando 2 paginas nuevas (D y E)
    Reservando D
    [ALLOC] 0x000000008010a000
    Reservando E
    [ALLOC] 0x00000000800f0000
    ===================================================

```

### Analisis de resultados de pruebas - MEMORY ALLOCATION:

Podemos apreciar las diferencias respecto al proceso de asignacion de memoria, en el primer caso podemos ver el algoritmo original de xv6 (SIN MODIFICAR), al implementar un algoritmo de asignacion de memoria LIFO (Last In First Out) podemos apreciar como el ultimo proceso liberado P1 (0x0000000080026000) es el primero en ser reservado de nuevo.

Mientras que en el segundo caso se implementa un algoritmo de asignacion de memoria FIFO (First In First Out) podemos apreciar como el primer proceso liberado P3 (0x000000008010a000) es el primero en ser reservado de nuevo.



## Pasos para ejecutar pruebas:

```bash

# Probar algoritmo de planificacion (Schedule): Ejecuta simplemente en la sh de xv6:

$ test_launch

# Probar algoritmo de asignacion de memoria (Memory Allocation): Ejecuta simplemente en la sh de xv6:

$ test_memory

# ambos programas han sido registrado y estan disponible para su ejecucion al levantar xv6 sin ningun problema.
```
