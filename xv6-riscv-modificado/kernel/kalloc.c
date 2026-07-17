// Physical memory allocator, for user processes,
// kernel stacks, page-table pages,
// and pipe buffers. Allocates whole 4096-byte pages.

#include "types.h"
#include "param.h"
#include "memlayout.h"
#include "spinlock.h"
#include "riscv.h"
#include "defs.h"

void freerange(void *pa_start, void *pa_end);

extern char end[]; // first address after kernel.
                   // defined by kernel.ld.

int trace_memory = 0;

struct run {
  struct run *next;
};

struct {
  struct spinlock lock;
  struct run *freelist;
  struct run *tail; // Daniel Bolivar
} kmem;

void
kinit()
{
  initlock(&kmem.lock, "kmem");
  freerange(end, (void *)PHYSTOP);
}

void
freerange(void *pa_start, void *pa_end)
{
  char *p;
  p = (char *)PGROUNDUP((uint64)pa_start);
  for (; p + PGSIZE <= (char *)pa_end; p += PGSIZE)
    kfree(p);

  // Daniel Bolivar - apuntamos tail al ultimo nodo.
  if(kmem.freelist){
    struct run *r = kmem.freelist;

    while(r->next)
      r = r->next;

    kmem.tail = r;
  }
}

// Free the page of physical memory pointed at by pa,
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(void *pa)
{
  struct run *r;

  if (((uint64)pa % PGSIZE) != 0 || (char *)pa < end || (uint64)pa >= PHYSTOP)
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(pa, 1, PGSIZE);

  r = (struct run *)pa;

  /* Daniel Bolivar 
    - modificamos la forma en como se liberan las paginas y se asignan para FIFO
    - En vez de agregar al inicio de la lista como LIFO, agregamos al final.
  */
  r->next = 0;

  acquire(&kmem.lock);

  if (kmem.freelist == 0){
    kmem.freelist = r;
  }else{
    kmem.tail->next = r;
  }
  kmem.tail = r;

  release(&kmem.lock);

  if (trace_memory) {
    printk("[FREE ] %p\n", pa);
  }
 
  /* antes:

  acquire(&kmem.lock);
  r->next = kmem.freelist;
  kmem.freelist = r; 
  release(&kmem.lock);
  
  */
}

// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void *
kalloc(void)
{
  struct run *r;

  acquire(&kmem.lock);
  r = kmem.freelist;
  if (r){
    kmem.freelist = r->next;

    // imprimir solo para tests
    if (trace_memory && r) {
      printk("[ALLOC] %p\n", r);
    }

  }
  release(&kmem.lock);

  if (r)
    memset((char *)r, 5, PGSIZE); // fill with junk
  return (void *)r;
}
