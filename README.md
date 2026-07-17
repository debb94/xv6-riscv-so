
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
- Como primer modificacion he realizado ajustes sobre el scheduler y estructura de procesos para implementar de manera exitosa 
un algoritmo de planificacion FCFS (First Come First Served). De esta forma poder comparar el comportamiento de ambos sistemas
operativos, entiendo que no es el algoritmo mas optimo, pero permite evidenciar de manera optima el funcionamiento o las diferencias
entre ambos sistemas operativos.