
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
_entry:
        # set up a stack for C.
        # stack0 is declared in start.c,
        # with a 4096-byte stack per CPU.
        # sp = stack0 + ((hartid + 1) * 4096)
        la sp, stack0
    80000000:	0000a117          	auipc	sp,0xa
    80000004:	18813103          	ld	sp,392(sp) # 8000a188 <_GLOBAL_OFFSET_TABLE_+0x8>
        li a0, 1024*4
    80000008:	6505                	lui	a0,0x1
        csrr a1, mhartid
    8000000a:	f14025f3          	csrr	a1,mhartid
        addi a1, a1, 1
    8000000e:	0585                	addi	a1,a1,1
        mul a0, a0, a1
    80000010:	02b50533          	mul	a0,a0,a1
        add sp, sp, a0
    80000014:	912a                	add	sp,sp,a0
        # jump to start() in start.c
        call start
    80000016:	03e000ef          	jal	80000054 <start>

000000008000001a <spin>:
spin:
        j spin
    8000001a:	a001                	j	8000001a <spin>

000000008000001c <timerinit>:
}

// ask each hart to generate timer interrupts.
void
timerinit()
{
    8000001c:	1141                	addi	sp,sp,-16
    8000001e:	e422                	sd	s0,8(sp)
    80000020:	0800                	addi	s0,sp,16
static inline uint64
r_menvcfg()
{
  uint64 x;
  // asm volatile("csrr %0, menvcfg" : "=r" (x) );
  asm volatile("csrr %0, 0x30a" : "=r"(x));
    80000022:	30a027f3          	csrr	a5,0x30a
  // enable the sstc extension (i.e. stimecmp).
  w_menvcfg(r_menvcfg() | (1L << 63));
    80000026:	577d                	li	a4,-1
    80000028:	177e                	slli	a4,a4,0x3f
    8000002a:	8fd9                	or	a5,a5,a4

static inline void
w_menvcfg(uint64 x)
{
  // asm volatile("csrw menvcfg, %0" : : "r" (x));
  asm volatile("csrw 0x30a, %0" : : "r"(x));
    8000002c:	30a79073          	csrw	0x30a,a5

static inline uint64
r_mcounteren()
{
  uint64 x;
  asm volatile("csrr %0, mcounteren" : "=r"(x));
    80000030:	306027f3          	csrr	a5,mcounteren

  // allow supervisor to use stimecmp and time.
  w_mcounteren(r_mcounteren() | 2);
    80000034:	0027e793          	ori	a5,a5,2
  asm volatile("csrw mcounteren, %0" : : "r"(x));
    80000038:	30679073          	csrw	mcounteren,a5
// machine-mode cycle counter
static inline uint64
r_time()
{
  uint64 x;
  asm volatile("csrr %0, time" : "=r"(x));
    8000003c:	c01027f3          	rdtime	a5

  // ask for the very first timer interrupt.
  w_stimecmp(r_time() + 1000000);
    80000040:	000f4737          	lui	a4,0xf4
    80000044:	24070713          	addi	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    80000048:	97ba                	add	a5,a5,a4
  asm volatile("csrw 0x14d, %0" : : "r"(x));
    8000004a:	14d79073          	csrw	stimecmp,a5
}
    8000004e:	6422                	ld	s0,8(sp)
    80000050:	0141                	addi	sp,sp,16
    80000052:	8082                	ret

0000000080000054 <start>:
{
    80000054:	1141                	addi	sp,sp,-16
    80000056:	e406                	sd	ra,8(sp)
    80000058:	e022                	sd	s0,0(sp)
    8000005a:	0800                	addi	s0,sp,16
  asm volatile("csrr %0, mstatus" : "=r"(x));
    8000005c:	300027f3          	csrr	a5,mstatus
  x &= ~MSTATUS_MPP_MASK;
    80000060:	7779                	lui	a4,0xffffe
    80000062:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffdb327>
    80000066:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    80000068:	6705                	lui	a4,0x1
    8000006a:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    8000006e:	8fd9                	or	a5,a5,a4
  asm volatile("csrw mstatus, %0" : : "r"(x));
    80000070:	30079073          	csrw	mstatus,a5
  asm volatile("csrw mepc, %0" : : "r"(x));
    80000074:	00001797          	auipc	a5,0x1
    80000078:	d9e78793          	addi	a5,a5,-610 # 80000e12 <main>
    8000007c:	34179073          	csrw	mepc,a5
  asm volatile("csrw satp, %0" : : "r"(x));
    80000080:	4781                	li	a5,0
    80000082:	18079073          	csrw	satp,a5
  asm volatile("csrw medeleg, %0" : : "r"(x));
    80000086:	67c1                	lui	a5,0x10
    80000088:	17fd                	addi	a5,a5,-1 # ffff <_entry-0x7fff0001>
    8000008a:	30279073          	csrw	medeleg,a5
  asm volatile("csrw mideleg, %0" : : "r"(x));
    8000008e:	30379073          	csrw	mideleg,a5
  asm volatile("csrr %0, sie" : "=r"(x));
    80000092:	104027f3          	csrr	a5,sie
  w_sie(r_sie() | SIE_SEIE | SIE_STIE);
    80000096:	2207e793          	ori	a5,a5,544
  asm volatile("csrw sie, %0" : : "r"(x));
    8000009a:	10479073          	csrw	sie,a5
  asm volatile("csrw pmpaddr0, %0" : : "r"(x));
    8000009e:	57fd                	li	a5,-1
    800000a0:	83a9                	srli	a5,a5,0xa
    800000a2:	3b079073          	csrw	pmpaddr0,a5
  asm volatile("csrw pmpcfg0, %0" : : "r"(x));
    800000a6:	47bd                	li	a5,15
    800000a8:	3a079073          	csrw	pmpcfg0,a5
  timerinit();
    800000ac:	f71ff0ef          	jal	8000001c <timerinit>
  asm volatile("csrr %0, mhartid" : "=r"(x));
    800000b0:	f14027f3          	csrr	a5,mhartid
  w_tp(id);
    800000b4:	2781                	sext.w	a5,a5
}

static inline void
w_tp(uint64 x)
{
  asm volatile("mv tp, %0" : : "r"(x));
    800000b6:	823e                	mv	tp,a5
  asm volatile("mret");
    800000b8:	30200073          	mret
}
    800000bc:	60a2                	ld	ra,8(sp)
    800000be:	6402                	ld	s0,0(sp)
    800000c0:	0141                	addi	sp,sp,16
    800000c2:	8082                	ret

00000000800000c4 <consolewrite>:
// user write() system calls to the console go here.
// uses sleep() and UART interrupts.
//
int
consolewrite(int user_src, uint64 src, int n)
{
    800000c4:	7119                	addi	sp,sp,-128
    800000c6:	fc86                	sd	ra,120(sp)
    800000c8:	f8a2                	sd	s0,112(sp)
    800000ca:	f4a6                	sd	s1,104(sp)
    800000cc:	0100                	addi	s0,sp,128
  char buf[32]; // move batches from user space to uart.
  int i = 0;

  while (i < n) {
    800000ce:	06c05a63          	blez	a2,80000142 <consolewrite+0x7e>
    800000d2:	f0ca                	sd	s2,96(sp)
    800000d4:	ecce                	sd	s3,88(sp)
    800000d6:	e8d2                	sd	s4,80(sp)
    800000d8:	e4d6                	sd	s5,72(sp)
    800000da:	e0da                	sd	s6,64(sp)
    800000dc:	fc5e                	sd	s7,56(sp)
    800000de:	f862                	sd	s8,48(sp)
    800000e0:	f466                	sd	s9,40(sp)
    800000e2:	8aaa                	mv	s5,a0
    800000e4:	8b2e                	mv	s6,a1
    800000e6:	8a32                	mv	s4,a2
  int i = 0;
    800000e8:	4481                	li	s1,0
    int nn = sizeof(buf);
    if (nn > n - i)
    800000ea:	02000c13          	li	s8,32
    800000ee:	02000c93          	li	s9,32
      nn = n - i;
    if (either_copyin(buf, user_src, src + i, nn) == -1)
    800000f2:	5bfd                	li	s7,-1
    800000f4:	a035                	j	80000120 <consolewrite+0x5c>
    if (nn > n - i)
    800000f6:	0009099b          	sext.w	s3,s2
    if (either_copyin(buf, user_src, src + i, nn) == -1)
    800000fa:	86ce                	mv	a3,s3
    800000fc:	01648633          	add	a2,s1,s6
    80000100:	85d6                	mv	a1,s5
    80000102:	f8040513          	addi	a0,s0,-128
    80000106:	14e020ef          	jal	80002254 <either_copyin>
    8000010a:	03750e63          	beq	a0,s7,80000146 <consolewrite+0x82>
      break;
    uartwrite(buf, nn);
    8000010e:	85ce                	mv	a1,s3
    80000110:	f8040513          	addi	a0,s0,-128
    80000114:	778000ef          	jal	8000088c <uartwrite>
    i += nn;
    80000118:	009904bb          	addw	s1,s2,s1
  while (i < n) {
    8000011c:	0144da63          	bge	s1,s4,80000130 <consolewrite+0x6c>
    if (nn > n - i)
    80000120:	409a093b          	subw	s2,s4,s1
    80000124:	0009079b          	sext.w	a5,s2
    80000128:	fcfc57e3          	bge	s8,a5,800000f6 <consolewrite+0x32>
    8000012c:	8966                	mv	s2,s9
    8000012e:	b7e1                	j	800000f6 <consolewrite+0x32>
    80000130:	7906                	ld	s2,96(sp)
    80000132:	69e6                	ld	s3,88(sp)
    80000134:	6a46                	ld	s4,80(sp)
    80000136:	6aa6                	ld	s5,72(sp)
    80000138:	6b06                	ld	s6,64(sp)
    8000013a:	7be2                	ld	s7,56(sp)
    8000013c:	7c42                	ld	s8,48(sp)
    8000013e:	7ca2                	ld	s9,40(sp)
    80000140:	a819                	j	80000156 <consolewrite+0x92>
  int i = 0;
    80000142:	4481                	li	s1,0
    80000144:	a809                	j	80000156 <consolewrite+0x92>
    80000146:	7906                	ld	s2,96(sp)
    80000148:	69e6                	ld	s3,88(sp)
    8000014a:	6a46                	ld	s4,80(sp)
    8000014c:	6aa6                	ld	s5,72(sp)
    8000014e:	6b06                	ld	s6,64(sp)
    80000150:	7be2                	ld	s7,56(sp)
    80000152:	7c42                	ld	s8,48(sp)
    80000154:	7ca2                	ld	s9,40(sp)
  }

  return i;
}
    80000156:	8526                	mv	a0,s1
    80000158:	70e6                	ld	ra,120(sp)
    8000015a:	7446                	ld	s0,112(sp)
    8000015c:	74a6                	ld	s1,104(sp)
    8000015e:	6109                	addi	sp,sp,128
    80000160:	8082                	ret

0000000080000162 <consoleread>:
// user_dst indicates whether dst is a user
// or kernel address.
//
int
consoleread(int user_dst, uint64 dst, int n)
{
    80000162:	711d                	addi	sp,sp,-96
    80000164:	ec86                	sd	ra,88(sp)
    80000166:	e8a2                	sd	s0,80(sp)
    80000168:	e4a6                	sd	s1,72(sp)
    8000016a:	e0ca                	sd	s2,64(sp)
    8000016c:	fc4e                	sd	s3,56(sp)
    8000016e:	f852                	sd	s4,48(sp)
    80000170:	f456                	sd	s5,40(sp)
    80000172:	f05a                	sd	s6,32(sp)
    80000174:	1080                	addi	s0,sp,96
    80000176:	8aaa                	mv	s5,a0
    80000178:	8a2e                	mv	s4,a1
    8000017a:	89b2                	mv	s3,a2
  uint target;
  int c;
  char cbuf;

  target = n;
    8000017c:	00060b1b          	sext.w	s6,a2
  acquire(&cons.lock);
    80000180:	00012517          	auipc	a0,0x12
    80000184:	05050513          	addi	a0,a0,80 # 800121d0 <cons>
    80000188:	225000ef          	jal	80000bac <acquire>
  while (n > 0) {
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while (cons.r == cons.w) {
    8000018c:	00012497          	auipc	s1,0x12
    80000190:	04448493          	addi	s1,s1,68 # 800121d0 <cons>
      if (killed(myproc())) {
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    80000194:	00012917          	auipc	s2,0x12
    80000198:	0d490913          	addi	s2,s2,212 # 80012268 <cons+0x98>
  while (n > 0) {
    8000019c:	0b305d63          	blez	s3,80000256 <consoleread+0xf4>
    while (cons.r == cons.w) {
    800001a0:	0984a783          	lw	a5,152(s1)
    800001a4:	09c4a703          	lw	a4,156(s1)
    800001a8:	0af71263          	bne	a4,a5,8000024c <consoleread+0xea>
      if (killed(myproc())) {
    800001ac:	6f8010ef          	jal	800018a4 <myproc>
    800001b0:	737010ef          	jal	800020e6 <killed>
    800001b4:	e12d                	bnez	a0,80000216 <consoleread+0xb4>
      sleep(&cons.r, &cons.lock);
    800001b6:	85a6                	mv	a1,s1
    800001b8:	854a                	mv	a0,s2
    800001ba:	4f5010ef          	jal	80001eae <sleep>
    while (cons.r == cons.w) {
    800001be:	0984a783          	lw	a5,152(s1)
    800001c2:	09c4a703          	lw	a4,156(s1)
    800001c6:	fef703e3          	beq	a4,a5,800001ac <consoleread+0x4a>
    800001ca:	ec5e                	sd	s7,24(sp)
    }

    c = cons.buf[cons.r++ % INPUT_BUF_SIZE];
    800001cc:	00012717          	auipc	a4,0x12
    800001d0:	00470713          	addi	a4,a4,4 # 800121d0 <cons>
    800001d4:	0017869b          	addiw	a3,a5,1
    800001d8:	08d72c23          	sw	a3,152(a4)
    800001dc:	07f7f693          	andi	a3,a5,127
    800001e0:	9736                	add	a4,a4,a3
    800001e2:	01874703          	lbu	a4,24(a4)
    800001e6:	00070b9b          	sext.w	s7,a4

    if (c == C('D')) { // end-of-file
    800001ea:	4691                	li	a3,4
    800001ec:	04db8663          	beq	s7,a3,80000238 <consoleread+0xd6>
      }
      break;
    }

    // copy the input byte to the user-space buffer.
    cbuf = c;
    800001f0:	fae407a3          	sb	a4,-81(s0)
    if (either_copyout(user_dst, dst, &cbuf, 1) == -1)
    800001f4:	4685                	li	a3,1
    800001f6:	faf40613          	addi	a2,s0,-81
    800001fa:	85d2                	mv	a1,s4
    800001fc:	8556                	mv	a0,s5
    800001fe:	00c020ef          	jal	8000220a <either_copyout>
    80000202:	57fd                	li	a5,-1
    80000204:	04f50863          	beq	a0,a5,80000254 <consoleread+0xf2>
      break;

    dst++;
    80000208:	0a05                	addi	s4,s4,1
    --n;
    8000020a:	39fd                	addiw	s3,s3,-1

    if (c == '\n') {
    8000020c:	47a9                	li	a5,10
    8000020e:	04fb8d63          	beq	s7,a5,80000268 <consoleread+0x106>
    80000212:	6be2                	ld	s7,24(sp)
    80000214:	b761                	j	8000019c <consoleread+0x3a>
        release(&cons.lock);
    80000216:	00012517          	auipc	a0,0x12
    8000021a:	fba50513          	addi	a0,a0,-70 # 800121d0 <cons>
    8000021e:	223000ef          	jal	80000c40 <release>
        return -1;
    80000222:	557d                	li	a0,-1
    }
  }
  release(&cons.lock);

  return target - n;
}
    80000224:	60e6                	ld	ra,88(sp)
    80000226:	6446                	ld	s0,80(sp)
    80000228:	64a6                	ld	s1,72(sp)
    8000022a:	6906                	ld	s2,64(sp)
    8000022c:	79e2                	ld	s3,56(sp)
    8000022e:	7a42                	ld	s4,48(sp)
    80000230:	7aa2                	ld	s5,40(sp)
    80000232:	7b02                	ld	s6,32(sp)
    80000234:	6125                	addi	sp,sp,96
    80000236:	8082                	ret
      if (n < target) {
    80000238:	0009871b          	sext.w	a4,s3
    8000023c:	01677a63          	bgeu	a4,s6,80000250 <consoleread+0xee>
        cons.r--;
    80000240:	00012717          	auipc	a4,0x12
    80000244:	02f72423          	sw	a5,40(a4) # 80012268 <cons+0x98>
    80000248:	6be2                	ld	s7,24(sp)
    8000024a:	a031                	j	80000256 <consoleread+0xf4>
    8000024c:	ec5e                	sd	s7,24(sp)
    8000024e:	bfbd                	j	800001cc <consoleread+0x6a>
    80000250:	6be2                	ld	s7,24(sp)
    80000252:	a011                	j	80000256 <consoleread+0xf4>
    80000254:	6be2                	ld	s7,24(sp)
  release(&cons.lock);
    80000256:	00012517          	auipc	a0,0x12
    8000025a:	f7a50513          	addi	a0,a0,-134 # 800121d0 <cons>
    8000025e:	1e3000ef          	jal	80000c40 <release>
  return target - n;
    80000262:	413b053b          	subw	a0,s6,s3
    80000266:	bf7d                	j	80000224 <consoleread+0xc2>
    80000268:	6be2                	ld	s7,24(sp)
    8000026a:	b7f5                	j	80000256 <consoleread+0xf4>

000000008000026c <consputc>:
{
    8000026c:	1141                	addi	sp,sp,-16
    8000026e:	e406                	sd	ra,8(sp)
    80000270:	e022                	sd	s0,0(sp)
    80000272:	0800                	addi	s0,sp,16
  if (c == BACKSPACE) {
    80000274:	10000793          	li	a5,256
    80000278:	00f50863          	beq	a0,a5,80000288 <consputc+0x1c>
    uartputc_sync(c);
    8000027c:	6a4000ef          	jal	80000920 <uartputc_sync>
}
    80000280:	60a2                	ld	ra,8(sp)
    80000282:	6402                	ld	s0,0(sp)
    80000284:	0141                	addi	sp,sp,16
    80000286:	8082                	ret
    uartputc_sync('\b');
    80000288:	4521                	li	a0,8
    8000028a:	696000ef          	jal	80000920 <uartputc_sync>
    uartputc_sync(' ');
    8000028e:	02000513          	li	a0,32
    80000292:	68e000ef          	jal	80000920 <uartputc_sync>
    uartputc_sync('\b');
    80000296:	4521                	li	a0,8
    80000298:	688000ef          	jal	80000920 <uartputc_sync>
    8000029c:	b7d5                	j	80000280 <consputc+0x14>

000000008000029e <consoleintr>:
// do erase/kill processing, append to cons.buf,
// wake up consoleread() if a whole line has arrived.
//
void
consoleintr(int c)
{
    8000029e:	1101                	addi	sp,sp,-32
    800002a0:	ec06                	sd	ra,24(sp)
    800002a2:	e822                	sd	s0,16(sp)
    800002a4:	e426                	sd	s1,8(sp)
    800002a6:	1000                	addi	s0,sp,32
    800002a8:	84aa                	mv	s1,a0
  acquire(&cons.lock);
    800002aa:	00012517          	auipc	a0,0x12
    800002ae:	f2650513          	addi	a0,a0,-218 # 800121d0 <cons>
    800002b2:	0fb000ef          	jal	80000bac <acquire>

  switch (c) {
    800002b6:	47d5                	li	a5,21
    800002b8:	08f48f63          	beq	s1,a5,80000356 <consoleintr+0xb8>
    800002bc:	0297c563          	blt	a5,s1,800002e6 <consoleintr+0x48>
    800002c0:	47a1                	li	a5,8
    800002c2:	0ef48463          	beq	s1,a5,800003aa <consoleintr+0x10c>
    800002c6:	47c1                	li	a5,16
    800002c8:	10f49563          	bne	s1,a5,800003d2 <consoleintr+0x134>
  case C('P'): // Print process list.
    procdump();
    800002cc:	7d3010ef          	jal	8000229e <procdump>
      }
    }
    break;
  }

  release(&cons.lock);
    800002d0:	00012517          	auipc	a0,0x12
    800002d4:	f0050513          	addi	a0,a0,-256 # 800121d0 <cons>
    800002d8:	169000ef          	jal	80000c40 <release>
}
    800002dc:	60e2                	ld	ra,24(sp)
    800002de:	6442                	ld	s0,16(sp)
    800002e0:	64a2                	ld	s1,8(sp)
    800002e2:	6105                	addi	sp,sp,32
    800002e4:	8082                	ret
  switch (c) {
    800002e6:	07f00793          	li	a5,127
    800002ea:	0cf48063          	beq	s1,a5,800003aa <consoleintr+0x10c>
    if (c != 0 && cons.e - cons.r < INPUT_BUF_SIZE) {
    800002ee:	00012717          	auipc	a4,0x12
    800002f2:	ee270713          	addi	a4,a4,-286 # 800121d0 <cons>
    800002f6:	0a072783          	lw	a5,160(a4)
    800002fa:	09872703          	lw	a4,152(a4)
    800002fe:	9f99                	subw	a5,a5,a4
    80000300:	07f00713          	li	a4,127
    80000304:	fcf766e3          	bltu	a4,a5,800002d0 <consoleintr+0x32>
      c = (c == '\r') ? '\n' : c;
    80000308:	47b5                	li	a5,13
    8000030a:	0cf48763          	beq	s1,a5,800003d8 <consoleintr+0x13a>
      consputc(c);
    8000030e:	8526                	mv	a0,s1
    80000310:	f5dff0ef          	jal	8000026c <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    80000314:	00012797          	auipc	a5,0x12
    80000318:	ebc78793          	addi	a5,a5,-324 # 800121d0 <cons>
    8000031c:	0a07a683          	lw	a3,160(a5)
    80000320:	0016871b          	addiw	a4,a3,1
    80000324:	0007061b          	sext.w	a2,a4
    80000328:	0ae7a023          	sw	a4,160(a5)
    8000032c:	07f6f693          	andi	a3,a3,127
    80000330:	97b6                	add	a5,a5,a3
    80000332:	00978c23          	sb	s1,24(a5)
      if (c == '\n' || c == C('D') || cons.e - cons.r == INPUT_BUF_SIZE) {
    80000336:	47a9                	li	a5,10
    80000338:	0cf48563          	beq	s1,a5,80000402 <consoleintr+0x164>
    8000033c:	4791                	li	a5,4
    8000033e:	0cf48263          	beq	s1,a5,80000402 <consoleintr+0x164>
    80000342:	00012797          	auipc	a5,0x12
    80000346:	f267a783          	lw	a5,-218(a5) # 80012268 <cons+0x98>
    8000034a:	9f1d                	subw	a4,a4,a5
    8000034c:	08000793          	li	a5,128
    80000350:	f8f710e3          	bne	a4,a5,800002d0 <consoleintr+0x32>
    80000354:	a07d                	j	80000402 <consoleintr+0x164>
    80000356:	e04a                	sd	s2,0(sp)
    while (cons.e != cons.w &&
    80000358:	00012717          	auipc	a4,0x12
    8000035c:	e7870713          	addi	a4,a4,-392 # 800121d0 <cons>
    80000360:	0a072783          	lw	a5,160(a4)
    80000364:	09c72703          	lw	a4,156(a4)
           cons.buf[(cons.e - 1) % INPUT_BUF_SIZE] != '\n') {
    80000368:	00012497          	auipc	s1,0x12
    8000036c:	e6848493          	addi	s1,s1,-408 # 800121d0 <cons>
    while (cons.e != cons.w &&
    80000370:	4929                	li	s2,10
    80000372:	02f70863          	beq	a4,a5,800003a2 <consoleintr+0x104>
           cons.buf[(cons.e - 1) % INPUT_BUF_SIZE] != '\n') {
    80000376:	37fd                	addiw	a5,a5,-1
    80000378:	07f7f713          	andi	a4,a5,127
    8000037c:	9726                	add	a4,a4,s1
    while (cons.e != cons.w &&
    8000037e:	01874703          	lbu	a4,24(a4)
    80000382:	03270263          	beq	a4,s2,800003a6 <consoleintr+0x108>
      cons.e--;
    80000386:	0af4a023          	sw	a5,160(s1)
      consputc(BACKSPACE);
    8000038a:	10000513          	li	a0,256
    8000038e:	edfff0ef          	jal	8000026c <consputc>
    while (cons.e != cons.w &&
    80000392:	0a04a783          	lw	a5,160(s1)
    80000396:	09c4a703          	lw	a4,156(s1)
    8000039a:	fcf71ee3          	bne	a4,a5,80000376 <consoleintr+0xd8>
    8000039e:	6902                	ld	s2,0(sp)
    800003a0:	bf05                	j	800002d0 <consoleintr+0x32>
    800003a2:	6902                	ld	s2,0(sp)
    800003a4:	b735                	j	800002d0 <consoleintr+0x32>
    800003a6:	6902                	ld	s2,0(sp)
    800003a8:	b725                	j	800002d0 <consoleintr+0x32>
    if (cons.e != cons.w) {
    800003aa:	00012717          	auipc	a4,0x12
    800003ae:	e2670713          	addi	a4,a4,-474 # 800121d0 <cons>
    800003b2:	0a072783          	lw	a5,160(a4)
    800003b6:	09c72703          	lw	a4,156(a4)
    800003ba:	f0f70be3          	beq	a4,a5,800002d0 <consoleintr+0x32>
      cons.e--;
    800003be:	37fd                	addiw	a5,a5,-1
    800003c0:	00012717          	auipc	a4,0x12
    800003c4:	eaf72823          	sw	a5,-336(a4) # 80012270 <cons+0xa0>
      consputc(BACKSPACE);
    800003c8:	10000513          	li	a0,256
    800003cc:	ea1ff0ef          	jal	8000026c <consputc>
    800003d0:	b701                	j	800002d0 <consoleintr+0x32>
    if (c != 0 && cons.e - cons.r < INPUT_BUF_SIZE) {
    800003d2:	ee048fe3          	beqz	s1,800002d0 <consoleintr+0x32>
    800003d6:	bf21                	j	800002ee <consoleintr+0x50>
      consputc(c);
    800003d8:	4529                	li	a0,10
    800003da:	e93ff0ef          	jal	8000026c <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    800003de:	00012797          	auipc	a5,0x12
    800003e2:	df278793          	addi	a5,a5,-526 # 800121d0 <cons>
    800003e6:	0a07a703          	lw	a4,160(a5)
    800003ea:	0017069b          	addiw	a3,a4,1
    800003ee:	0006861b          	sext.w	a2,a3
    800003f2:	0ad7a023          	sw	a3,160(a5)
    800003f6:	07f77713          	andi	a4,a4,127
    800003fa:	97ba                	add	a5,a5,a4
    800003fc:	4729                	li	a4,10
    800003fe:	00e78c23          	sb	a4,24(a5)
        cons.w = cons.e;
    80000402:	00012797          	auipc	a5,0x12
    80000406:	e6c7a523          	sw	a2,-406(a5) # 8001226c <cons+0x9c>
        wakeup(&cons.r);
    8000040a:	00012517          	auipc	a0,0x12
    8000040e:	e5e50513          	addi	a0,a0,-418 # 80012268 <cons+0x98>
    80000412:	2e9010ef          	jal	80001efa <wakeup>
    80000416:	bd6d                	j	800002d0 <consoleintr+0x32>

0000000080000418 <consoleinit>:

void
consoleinit(void)
{
    80000418:	1141                	addi	sp,sp,-16
    8000041a:	e406                	sd	ra,8(sp)
    8000041c:	e022                	sd	s0,0(sp)
    8000041e:	0800                	addi	s0,sp,16
  initlock(&cons.lock, "cons");
    80000420:	00007597          	auipc	a1,0x7
    80000424:	be058593          	addi	a1,a1,-1056 # 80007000 <etext>
    80000428:	00012517          	auipc	a0,0x12
    8000042c:	da850513          	addi	a0,a0,-600 # 800121d0 <cons>
    80000430:	6fc000ef          	jal	80000b2c <initlock>

  uartinit();
    80000434:	400000ef          	jal	80000834 <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    80000438:	00022797          	auipc	a5,0x22
    8000043c:	f0878793          	addi	a5,a5,-248 # 80022340 <devsw>
    80000440:	00000717          	auipc	a4,0x0
    80000444:	d2270713          	addi	a4,a4,-734 # 80000162 <consoleread>
    80000448:	eb98                	sd	a4,16(a5)
  devsw[CONSOLE].write = consolewrite;
    8000044a:	00000717          	auipc	a4,0x0
    8000044e:	c7a70713          	addi	a4,a4,-902 # 800000c4 <consolewrite>
    80000452:	ef98                	sd	a4,24(a5)
}
    80000454:	60a2                	ld	ra,8(sp)
    80000456:	6402                	ld	s0,0(sp)
    80000458:	0141                	addi	sp,sp,16
    8000045a:	8082                	ret

000000008000045c <printint>:

static char digits[] = "0123456789abcdef";

static void
printint(long long xx, int base, int sign)
{
    8000045c:	7139                	addi	sp,sp,-64
    8000045e:	fc06                	sd	ra,56(sp)
    80000460:	f822                	sd	s0,48(sp)
    80000462:	0080                	addi	s0,sp,64
  char buf[20];
  int i;
  unsigned long long x;

  if (sign && (sign = (xx < 0)))
    80000464:	c219                	beqz	a2,8000046a <printint+0xe>
    80000466:	08054063          	bltz	a0,800004e6 <printint+0x8a>
    x = -xx;
  else
    x = xx;
    8000046a:	4881                	li	a7,0
    8000046c:	fc840693          	addi	a3,s0,-56

  i = 0;
    80000470:	4781                	li	a5,0
  do {
    buf[i++] = digits[x % base];
    80000472:	00007617          	auipc	a2,0x7
    80000476:	29e60613          	addi	a2,a2,670 # 80007710 <digits>
    8000047a:	883e                	mv	a6,a5
    8000047c:	2785                	addiw	a5,a5,1
    8000047e:	02b57733          	remu	a4,a0,a1
    80000482:	9732                	add	a4,a4,a2
    80000484:	00074703          	lbu	a4,0(a4)
    80000488:	00e68023          	sb	a4,0(a3)
  } while ((x /= base) != 0);
    8000048c:	872a                	mv	a4,a0
    8000048e:	02b55533          	divu	a0,a0,a1
    80000492:	0685                	addi	a3,a3,1
    80000494:	feb773e3          	bgeu	a4,a1,8000047a <printint+0x1e>

  if (sign)
    80000498:	00088a63          	beqz	a7,800004ac <printint+0x50>
    buf[i++] = '-';
    8000049c:	1781                	addi	a5,a5,-32
    8000049e:	97a2                	add	a5,a5,s0
    800004a0:	02d00713          	li	a4,45
    800004a4:	fee78423          	sb	a4,-24(a5)
    800004a8:	0028079b          	addiw	a5,a6,2

  while (--i >= 0)
    800004ac:	02f05963          	blez	a5,800004de <printint+0x82>
    800004b0:	f426                	sd	s1,40(sp)
    800004b2:	f04a                	sd	s2,32(sp)
    800004b4:	fc840713          	addi	a4,s0,-56
    800004b8:	00f704b3          	add	s1,a4,a5
    800004bc:	fff70913          	addi	s2,a4,-1
    800004c0:	993e                	add	s2,s2,a5
    800004c2:	37fd                	addiw	a5,a5,-1
    800004c4:	1782                	slli	a5,a5,0x20
    800004c6:	9381                	srli	a5,a5,0x20
    800004c8:	40f90933          	sub	s2,s2,a5
    consputc(buf[i]);
    800004cc:	fff4c503          	lbu	a0,-1(s1)
    800004d0:	d9dff0ef          	jal	8000026c <consputc>
  while (--i >= 0)
    800004d4:	14fd                	addi	s1,s1,-1
    800004d6:	ff249be3          	bne	s1,s2,800004cc <printint+0x70>
    800004da:	74a2                	ld	s1,40(sp)
    800004dc:	7902                	ld	s2,32(sp)
}
    800004de:	70e2                	ld	ra,56(sp)
    800004e0:	7442                	ld	s0,48(sp)
    800004e2:	6121                	addi	sp,sp,64
    800004e4:	8082                	ret
    x = -xx;
    800004e6:	40a00533          	neg	a0,a0
  if (sign && (sign = (xx < 0)))
    800004ea:	4885                	li	a7,1
    x = -xx;
    800004ec:	b741                	j	8000046c <printint+0x10>

00000000800004ee <printk>:
}

// Print to the console.
int
printk(char *fmt, ...)
{
    800004ee:	7131                	addi	sp,sp,-192
    800004f0:	fc86                	sd	ra,120(sp)
    800004f2:	f8a2                	sd	s0,112(sp)
    800004f4:	e8d2                	sd	s4,80(sp)
    800004f6:	0100                	addi	s0,sp,128
    800004f8:	8a2a                	mv	s4,a0
    800004fa:	e40c                	sd	a1,8(s0)
    800004fc:	e810                	sd	a2,16(s0)
    800004fe:	ec14                	sd	a3,24(s0)
    80000500:	f018                	sd	a4,32(s0)
    80000502:	f41c                	sd	a5,40(s0)
    80000504:	03043823          	sd	a6,48(s0)
    80000508:	03143c23          	sd	a7,56(s0)
  va_list ap;
  int i, cx, c0, c1, c2;
  char *s;

  if (panicking == 0)
    8000050c:	0000a797          	auipc	a5,0xa
    80000510:	c987a783          	lw	a5,-872(a5) # 8000a1a4 <panicking>
    80000514:	c3a1                	beqz	a5,80000554 <printk+0x66>
    acquire(&pr.lock);

  va_start(ap, fmt);
    80000516:	00840793          	addi	a5,s0,8
    8000051a:	f8f43423          	sd	a5,-120(s0)
  for (i = 0; (cx = fmt[i] & 0xff) != 0; i++) {
    8000051e:	000a4503          	lbu	a0,0(s4)
    80000522:	28050763          	beqz	a0,800007b0 <printk+0x2c2>
    80000526:	f4a6                	sd	s1,104(sp)
    80000528:	f0ca                	sd	s2,96(sp)
    8000052a:	ecce                	sd	s3,88(sp)
    8000052c:	e4d6                	sd	s5,72(sp)
    8000052e:	e0da                	sd	s6,64(sp)
    80000530:	f862                	sd	s8,48(sp)
    80000532:	f466                	sd	s9,40(sp)
    80000534:	f06a                	sd	s10,32(sp)
    80000536:	ec6e                	sd	s11,24(sp)
    80000538:	4981                	li	s3,0
    if (cx != '%') {
    8000053a:	02500a93          	li	s5,37
    c1 = c2 = 0;
    if (c0)
      c1 = fmt[i + 1] & 0xff;
    if (c1)
      c2 = fmt[i + 2] & 0xff;
    if (c0 == 'd') {
    8000053e:	06400b13          	li	s6,100
      printint(va_arg(ap, int), 10, 1);
    } else if (c0 == 'l' && c1 == 'd') {
    80000542:	06c00c13          	li	s8,108
      printint(va_arg(ap, uint64), 10, 1);
      i += 1;
    } else if (c0 == 'l' && c1 == 'l' && c2 == 'd') {
      printint(va_arg(ap, uint64), 10, 1);
      i += 2;
    } else if (c0 == 'u') {
    80000546:	07500c93          	li	s9,117
      printint(va_arg(ap, uint64), 10, 0);
      i += 1;
    } else if (c0 == 'l' && c1 == 'l' && c2 == 'u') {
      printint(va_arg(ap, uint64), 10, 0);
      i += 2;
    } else if (c0 == 'x') {
    8000054a:	07800d13          	li	s10,120
      printint(va_arg(ap, uint64), 16, 0);
      i += 1;
    } else if (c0 == 'l' && c1 == 'l' && c2 == 'x') {
      printint(va_arg(ap, uint64), 16, 0);
      i += 2;
    } else if (c0 == 'p') {
    8000054e:	07000d93          	li	s11,112
    80000552:	a01d                	j	80000578 <printk+0x8a>
    acquire(&pr.lock);
    80000554:	00012517          	auipc	a0,0x12
    80000558:	d2450513          	addi	a0,a0,-732 # 80012278 <pr>
    8000055c:	650000ef          	jal	80000bac <acquire>
    80000560:	bf5d                	j	80000516 <printk+0x28>
      consputc(cx);
    80000562:	d0bff0ef          	jal	8000026c <consputc>
      continue;
    80000566:	84ce                	mv	s1,s3
  for (i = 0; (cx = fmt[i] & 0xff) != 0; i++) {
    80000568:	0014899b          	addiw	s3,s1,1
    8000056c:	013a07b3          	add	a5,s4,s3
    80000570:	0007c503          	lbu	a0,0(a5)
    80000574:	20050b63          	beqz	a0,8000078a <printk+0x29c>
    if (cx != '%') {
    80000578:	ff5515e3          	bne	a0,s5,80000562 <printk+0x74>
    i++;
    8000057c:	0019849b          	addiw	s1,s3,1
    c0 = fmt[i + 0] & 0xff;
    80000580:	009a07b3          	add	a5,s4,s1
    80000584:	0007c903          	lbu	s2,0(a5)
    if (c0)
    80000588:	20090b63          	beqz	s2,8000079e <printk+0x2b0>
      c1 = fmt[i + 1] & 0xff;
    8000058c:	0017c783          	lbu	a5,1(a5)
    c1 = c2 = 0;
    80000590:	86be                	mv	a3,a5
    if (c1)
    80000592:	c789                	beqz	a5,8000059c <printk+0xae>
      c2 = fmt[i + 2] & 0xff;
    80000594:	009a0733          	add	a4,s4,s1
    80000598:	00274683          	lbu	a3,2(a4)
    if (c0 == 'd') {
    8000059c:	03690963          	beq	s2,s6,800005ce <printk+0xe0>
    } else if (c0 == 'l' && c1 == 'd') {
    800005a0:	05890363          	beq	s2,s8,800005e6 <printk+0xf8>
    } else if (c0 == 'u') {
    800005a4:	0d990663          	beq	s2,s9,80000670 <printk+0x182>
    } else if (c0 == 'x') {
    800005a8:	11a90d63          	beq	s2,s10,800006c2 <printk+0x1d4>
    } else if (c0 == 'p') {
    800005ac:	15b90663          	beq	s2,s11,800006f8 <printk+0x20a>
      printptr(va_arg(ap, uint64));
    } else if (c0 == 'c') {
    800005b0:	06300793          	li	a5,99
    800005b4:	18f90563          	beq	s2,a5,8000073e <printk+0x250>
      consputc(va_arg(ap, uint));
    } else if (c0 == 's') {
    800005b8:	07300793          	li	a5,115
    800005bc:	18f90b63          	beq	s2,a5,80000752 <printk+0x264>
      if ((s = va_arg(ap, char *)) == 0)
        s = "(null)";
      for (; *s; s++)
        consputc(*s);
    } else if (c0 == '%') {
    800005c0:	03591b63          	bne	s2,s5,800005f6 <printk+0x108>
      consputc('%');
    800005c4:	02500513          	li	a0,37
    800005c8:	ca5ff0ef          	jal	8000026c <consputc>
    800005cc:	bf71                	j	80000568 <printk+0x7a>
      printint(va_arg(ap, int), 10, 1);
    800005ce:	f8843783          	ld	a5,-120(s0)
    800005d2:	00878713          	addi	a4,a5,8
    800005d6:	f8e43423          	sd	a4,-120(s0)
    800005da:	4605                	li	a2,1
    800005dc:	45a9                	li	a1,10
    800005de:	4388                	lw	a0,0(a5)
    800005e0:	e7dff0ef          	jal	8000045c <printint>
    800005e4:	b751                	j	80000568 <printk+0x7a>
    } else if (c0 == 'l' && c1 == 'd') {
    800005e6:	01678f63          	beq	a5,s6,80000604 <printk+0x116>
    } else if (c0 == 'l' && c1 == 'l' && c2 == 'd') {
    800005ea:	03878b63          	beq	a5,s8,80000620 <printk+0x132>
    } else if (c0 == 'l' && c1 == 'u') {
    800005ee:	09978e63          	beq	a5,s9,8000068a <printk+0x19c>
    } else if (c0 == 'l' && c1 == 'x') {
    800005f2:	0fa78563          	beq	a5,s10,800006dc <printk+0x1ee>
    } else if (c0 == 0) {
      break;
    } else {
      // Print unknown % sequence to draw attention.
      consputc('%');
    800005f6:	8556                	mv	a0,s5
    800005f8:	c75ff0ef          	jal	8000026c <consputc>
      consputc(c0);
    800005fc:	854a                	mv	a0,s2
    800005fe:	c6fff0ef          	jal	8000026c <consputc>
    80000602:	b79d                	j	80000568 <printk+0x7a>
      printint(va_arg(ap, uint64), 10, 1);
    80000604:	f8843783          	ld	a5,-120(s0)
    80000608:	00878713          	addi	a4,a5,8
    8000060c:	f8e43423          	sd	a4,-120(s0)
    80000610:	4605                	li	a2,1
    80000612:	45a9                	li	a1,10
    80000614:	6388                	ld	a0,0(a5)
    80000616:	e47ff0ef          	jal	8000045c <printint>
      i += 1;
    8000061a:	0029849b          	addiw	s1,s3,2
    8000061e:	b7a9                	j	80000568 <printk+0x7a>
    } else if (c0 == 'l' && c1 == 'l' && c2 == 'd') {
    80000620:	06400793          	li	a5,100
    80000624:	02f68863          	beq	a3,a5,80000654 <printk+0x166>
    } else if (c0 == 'l' && c1 == 'l' && c2 == 'u') {
    80000628:	07500793          	li	a5,117
    8000062c:	06f68d63          	beq	a3,a5,800006a6 <printk+0x1b8>
    } else if (c0 == 'l' && c1 == 'l' && c2 == 'x') {
    80000630:	07800793          	li	a5,120
    80000634:	fcf691e3          	bne	a3,a5,800005f6 <printk+0x108>
      printint(va_arg(ap, uint64), 16, 0);
    80000638:	f8843783          	ld	a5,-120(s0)
    8000063c:	00878713          	addi	a4,a5,8
    80000640:	f8e43423          	sd	a4,-120(s0)
    80000644:	4601                	li	a2,0
    80000646:	45c1                	li	a1,16
    80000648:	6388                	ld	a0,0(a5)
    8000064a:	e13ff0ef          	jal	8000045c <printint>
      i += 2;
    8000064e:	0039849b          	addiw	s1,s3,3
    80000652:	bf19                	j	80000568 <printk+0x7a>
      printint(va_arg(ap, uint64), 10, 1);
    80000654:	f8843783          	ld	a5,-120(s0)
    80000658:	00878713          	addi	a4,a5,8
    8000065c:	f8e43423          	sd	a4,-120(s0)
    80000660:	4605                	li	a2,1
    80000662:	45a9                	li	a1,10
    80000664:	6388                	ld	a0,0(a5)
    80000666:	df7ff0ef          	jal	8000045c <printint>
      i += 2;
    8000066a:	0039849b          	addiw	s1,s3,3
    8000066e:	bded                	j	80000568 <printk+0x7a>
      printint(va_arg(ap, uint32), 10, 0);
    80000670:	f8843783          	ld	a5,-120(s0)
    80000674:	00878713          	addi	a4,a5,8
    80000678:	f8e43423          	sd	a4,-120(s0)
    8000067c:	4601                	li	a2,0
    8000067e:	45a9                	li	a1,10
    80000680:	0007e503          	lwu	a0,0(a5)
    80000684:	dd9ff0ef          	jal	8000045c <printint>
    80000688:	b5c5                	j	80000568 <printk+0x7a>
      printint(va_arg(ap, uint64), 10, 0);
    8000068a:	f8843783          	ld	a5,-120(s0)
    8000068e:	00878713          	addi	a4,a5,8
    80000692:	f8e43423          	sd	a4,-120(s0)
    80000696:	4601                	li	a2,0
    80000698:	45a9                	li	a1,10
    8000069a:	6388                	ld	a0,0(a5)
    8000069c:	dc1ff0ef          	jal	8000045c <printint>
      i += 1;
    800006a0:	0029849b          	addiw	s1,s3,2
    800006a4:	b5d1                	j	80000568 <printk+0x7a>
      printint(va_arg(ap, uint64), 10, 0);
    800006a6:	f8843783          	ld	a5,-120(s0)
    800006aa:	00878713          	addi	a4,a5,8
    800006ae:	f8e43423          	sd	a4,-120(s0)
    800006b2:	4601                	li	a2,0
    800006b4:	45a9                	li	a1,10
    800006b6:	6388                	ld	a0,0(a5)
    800006b8:	da5ff0ef          	jal	8000045c <printint>
      i += 2;
    800006bc:	0039849b          	addiw	s1,s3,3
    800006c0:	b565                	j	80000568 <printk+0x7a>
      printint(va_arg(ap, uint32), 16, 0);
    800006c2:	f8843783          	ld	a5,-120(s0)
    800006c6:	00878713          	addi	a4,a5,8
    800006ca:	f8e43423          	sd	a4,-120(s0)
    800006ce:	4601                	li	a2,0
    800006d0:	45c1                	li	a1,16
    800006d2:	0007e503          	lwu	a0,0(a5)
    800006d6:	d87ff0ef          	jal	8000045c <printint>
    800006da:	b579                	j	80000568 <printk+0x7a>
      printint(va_arg(ap, uint64), 16, 0);
    800006dc:	f8843783          	ld	a5,-120(s0)
    800006e0:	00878713          	addi	a4,a5,8
    800006e4:	f8e43423          	sd	a4,-120(s0)
    800006e8:	4601                	li	a2,0
    800006ea:	45c1                	li	a1,16
    800006ec:	6388                	ld	a0,0(a5)
    800006ee:	d6fff0ef          	jal	8000045c <printint>
      i += 1;
    800006f2:	0029849b          	addiw	s1,s3,2
    800006f6:	bd8d                	j	80000568 <printk+0x7a>
    800006f8:	fc5e                	sd	s7,56(sp)
      printptr(va_arg(ap, uint64));
    800006fa:	f8843783          	ld	a5,-120(s0)
    800006fe:	00878713          	addi	a4,a5,8
    80000702:	f8e43423          	sd	a4,-120(s0)
    80000706:	0007b983          	ld	s3,0(a5)
  consputc('0');
    8000070a:	03000513          	li	a0,48
    8000070e:	b5fff0ef          	jal	8000026c <consputc>
  consputc('x');
    80000712:	07800513          	li	a0,120
    80000716:	b57ff0ef          	jal	8000026c <consputc>
    8000071a:	4941                	li	s2,16
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    8000071c:	00007b97          	auipc	s7,0x7
    80000720:	ff4b8b93          	addi	s7,s7,-12 # 80007710 <digits>
    80000724:	03c9d793          	srli	a5,s3,0x3c
    80000728:	97de                	add	a5,a5,s7
    8000072a:	0007c503          	lbu	a0,0(a5)
    8000072e:	b3fff0ef          	jal	8000026c <consputc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    80000732:	0992                	slli	s3,s3,0x4
    80000734:	397d                	addiw	s2,s2,-1
    80000736:	fe0917e3          	bnez	s2,80000724 <printk+0x236>
    8000073a:	7be2                	ld	s7,56(sp)
    8000073c:	b535                	j	80000568 <printk+0x7a>
      consputc(va_arg(ap, uint));
    8000073e:	f8843783          	ld	a5,-120(s0)
    80000742:	00878713          	addi	a4,a5,8
    80000746:	f8e43423          	sd	a4,-120(s0)
    8000074a:	4388                	lw	a0,0(a5)
    8000074c:	b21ff0ef          	jal	8000026c <consputc>
    80000750:	bd21                	j	80000568 <printk+0x7a>
      if ((s = va_arg(ap, char *)) == 0)
    80000752:	f8843783          	ld	a5,-120(s0)
    80000756:	00878713          	addi	a4,a5,8
    8000075a:	f8e43423          	sd	a4,-120(s0)
    8000075e:	0007b903          	ld	s2,0(a5)
    80000762:	00090d63          	beqz	s2,8000077c <printk+0x28e>
      for (; *s; s++)
    80000766:	00094503          	lbu	a0,0(s2)
    8000076a:	de050fe3          	beqz	a0,80000568 <printk+0x7a>
        consputc(*s);
    8000076e:	affff0ef          	jal	8000026c <consputc>
      for (; *s; s++)
    80000772:	0905                	addi	s2,s2,1
    80000774:	00094503          	lbu	a0,0(s2)
    80000778:	f97d                	bnez	a0,8000076e <printk+0x280>
    8000077a:	b3fd                	j	80000568 <printk+0x7a>
        s = "(null)";
    8000077c:	00007917          	auipc	s2,0x7
    80000780:	88c90913          	addi	s2,s2,-1908 # 80007008 <etext+0x8>
      for (; *s; s++)
    80000784:	02800513          	li	a0,40
    80000788:	b7dd                	j	8000076e <printk+0x280>
    8000078a:	74a6                	ld	s1,104(sp)
    8000078c:	7906                	ld	s2,96(sp)
    8000078e:	69e6                	ld	s3,88(sp)
    80000790:	6aa6                	ld	s5,72(sp)
    80000792:	6b06                	ld	s6,64(sp)
    80000794:	7c42                	ld	s8,48(sp)
    80000796:	7ca2                	ld	s9,40(sp)
    80000798:	7d02                	ld	s10,32(sp)
    8000079a:	6de2                	ld	s11,24(sp)
    8000079c:	a811                	j	800007b0 <printk+0x2c2>
    8000079e:	74a6                	ld	s1,104(sp)
    800007a0:	7906                	ld	s2,96(sp)
    800007a2:	69e6                	ld	s3,88(sp)
    800007a4:	6aa6                	ld	s5,72(sp)
    800007a6:	6b06                	ld	s6,64(sp)
    800007a8:	7c42                	ld	s8,48(sp)
    800007aa:	7ca2                	ld	s9,40(sp)
    800007ac:	7d02                	ld	s10,32(sp)
    800007ae:	6de2                	ld	s11,24(sp)
    }
  }
  va_end(ap);

  if (panicking == 0)
    800007b0:	0000a797          	auipc	a5,0xa
    800007b4:	9f47a783          	lw	a5,-1548(a5) # 8000a1a4 <panicking>
    800007b8:	c799                	beqz	a5,800007c6 <printk+0x2d8>
    release(&pr.lock);

  return 0;
}
    800007ba:	4501                	li	a0,0
    800007bc:	70e6                	ld	ra,120(sp)
    800007be:	7446                	ld	s0,112(sp)
    800007c0:	6a46                	ld	s4,80(sp)
    800007c2:	6129                	addi	sp,sp,192
    800007c4:	8082                	ret
    release(&pr.lock);
    800007c6:	00012517          	auipc	a0,0x12
    800007ca:	ab250513          	addi	a0,a0,-1358 # 80012278 <pr>
    800007ce:	472000ef          	jal	80000c40 <release>
  return 0;
    800007d2:	b7e5                	j	800007ba <printk+0x2cc>

00000000800007d4 <panic>:

void
panic(char *s)
{
    800007d4:	1101                	addi	sp,sp,-32
    800007d6:	ec06                	sd	ra,24(sp)
    800007d8:	e822                	sd	s0,16(sp)
    800007da:	e426                	sd	s1,8(sp)
    800007dc:	e04a                	sd	s2,0(sp)
    800007de:	1000                	addi	s0,sp,32
    800007e0:	84aa                	mv	s1,a0
  panicking = 1;
    800007e2:	4905                	li	s2,1
    800007e4:	0000a797          	auipc	a5,0xa
    800007e8:	9d27a023          	sw	s2,-1600(a5) # 8000a1a4 <panicking>
  printk("panic: ");
    800007ec:	00007517          	auipc	a0,0x7
    800007f0:	82c50513          	addi	a0,a0,-2004 # 80007018 <etext+0x18>
    800007f4:	cfbff0ef          	jal	800004ee <printk>
  printk("%s\n", s);
    800007f8:	85a6                	mv	a1,s1
    800007fa:	00007517          	auipc	a0,0x7
    800007fe:	82650513          	addi	a0,a0,-2010 # 80007020 <etext+0x20>
    80000802:	cedff0ef          	jal	800004ee <printk>
  panicked = 1; // freeze uart output from other CPUs
    80000806:	0000a797          	auipc	a5,0xa
    8000080a:	9927ad23          	sw	s2,-1638(a5) # 8000a1a0 <panicked>
  for (;;)
    8000080e:	a001                	j	8000080e <panic+0x3a>

0000000080000810 <printkinit>:
    ;
}

void
printkinit(void)
{
    80000810:	1141                	addi	sp,sp,-16
    80000812:	e406                	sd	ra,8(sp)
    80000814:	e022                	sd	s0,0(sp)
    80000816:	0800                	addi	s0,sp,16
  initlock(&pr.lock, "pr");
    80000818:	00007597          	auipc	a1,0x7
    8000081c:	81058593          	addi	a1,a1,-2032 # 80007028 <etext+0x28>
    80000820:	00012517          	auipc	a0,0x12
    80000824:	a5850513          	addi	a0,a0,-1448 # 80012278 <pr>
    80000828:	304000ef          	jal	80000b2c <initlock>
}
    8000082c:	60a2                	ld	ra,8(sp)
    8000082e:	6402                	ld	s0,0(sp)
    80000830:	0141                	addi	sp,sp,16
    80000832:	8082                	ret

0000000080000834 <uartinit>:
extern volatile int panicking; // from printk.c
extern volatile int panicked;  // from printk.c

void
uartinit(void)
{
    80000834:	1141                	addi	sp,sp,-16
    80000836:	e406                	sd	ra,8(sp)
    80000838:	e022                	sd	s0,0(sp)
    8000083a:	0800                	addi	s0,sp,16
  // disable interrupts.
  WriteReg(IER, 0x00);
    8000083c:	100007b7          	lui	a5,0x10000
    80000840:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>

  // special mode to set baud rate.
  WriteReg(LCR, LCR_BAUD_LATCH);
    80000844:	10000737          	lui	a4,0x10000
    80000848:	f8000693          	li	a3,-128
    8000084c:	00d701a3          	sb	a3,3(a4) # 10000003 <_entry-0x6ffffffd>

  // LSB for baud rate of 38.4K.
  WriteReg(0, 0x03);
    80000850:	468d                	li	a3,3
    80000852:	10000637          	lui	a2,0x10000
    80000856:	00d60023          	sb	a3,0(a2) # 10000000 <_entry-0x70000000>

  // MSB for baud rate of 38.4K.
  WriteReg(1, 0x00);
    8000085a:	000780a3          	sb	zero,1(a5)

  // leave set-baud mode,
  // and set word length to 8 bits, no parity.
  WriteReg(LCR, LCR_EIGHT_BITS);
    8000085e:	00d701a3          	sb	a3,3(a4)

  // reset and enable FIFOs.
  WriteReg(FCR, FCR_FIFO_ENABLE | FCR_FIFO_CLEAR);
    80000862:	10000737          	lui	a4,0x10000
    80000866:	461d                	li	a2,7
    80000868:	00c70123          	sb	a2,2(a4) # 10000002 <_entry-0x6ffffffe>

  // enable transmit and receive interrupts.
  WriteReg(IER, IER_TX_ENABLE | IER_RX_ENABLE);
    8000086c:	00d780a3          	sb	a3,1(a5)

  initlock(&tx_lock, "uart");
    80000870:	00006597          	auipc	a1,0x6
    80000874:	7c058593          	addi	a1,a1,1984 # 80007030 <etext+0x30>
    80000878:	00012517          	auipc	a0,0x12
    8000087c:	a1850513          	addi	a0,a0,-1512 # 80012290 <tx_lock>
    80000880:	2ac000ef          	jal	80000b2c <initlock>
}
    80000884:	60a2                	ld	ra,8(sp)
    80000886:	6402                	ld	s0,0(sp)
    80000888:	0141                	addi	sp,sp,16
    8000088a:	8082                	ret

000000008000088c <uartwrite>:
// transmit buf[] to the uart. it blocks if the
// uart is busy, so it cannot be called from
// interrupts, only from write() system calls.
void
uartwrite(char buf[], int n)
{
    8000088c:	715d                	addi	sp,sp,-80
    8000088e:	e486                	sd	ra,72(sp)
    80000890:	e0a2                	sd	s0,64(sp)
    80000892:	fc26                	sd	s1,56(sp)
    80000894:	ec56                	sd	s5,24(sp)
    80000896:	0880                	addi	s0,sp,80
    80000898:	8aaa                	mv	s5,a0
    8000089a:	84ae                	mv	s1,a1
  acquire(&tx_lock);
    8000089c:	00012517          	auipc	a0,0x12
    800008a0:	9f450513          	addi	a0,a0,-1548 # 80012290 <tx_lock>
    800008a4:	308000ef          	jal	80000bac <acquire>

  int i = 0;
  while (i < n) {
    800008a8:	06905063          	blez	s1,80000908 <uartwrite+0x7c>
    800008ac:	f84a                	sd	s2,48(sp)
    800008ae:	f44e                	sd	s3,40(sp)
    800008b0:	f052                	sd	s4,32(sp)
    800008b2:	e85a                	sd	s6,16(sp)
    800008b4:	e45e                	sd	s7,8(sp)
    800008b6:	8a56                	mv	s4,s5
    800008b8:	9aa6                	add	s5,s5,s1
    while (tx_busy != 0) {
    800008ba:	0000a497          	auipc	s1,0xa
    800008be:	8f248493          	addi	s1,s1,-1806 # 8000a1ac <tx_busy>
      // wait for a UART transmit-complete interrupt
      // to set tx_busy to 0.
      sleep(&tx_chan, &tx_lock);
    800008c2:	00012997          	auipc	s3,0x12
    800008c6:	9ce98993          	addi	s3,s3,-1586 # 80012290 <tx_lock>
    800008ca:	0000a917          	auipc	s2,0xa
    800008ce:	8de90913          	addi	s2,s2,-1826 # 8000a1a8 <tx_chan>
    }

    WriteReg(THR, buf[i]);
    800008d2:	10000bb7          	lui	s7,0x10000
    i += 1;
    tx_busy = 1;
    800008d6:	4b05                	li	s6,1
    800008d8:	a005                	j	800008f8 <uartwrite+0x6c>
      sleep(&tx_chan, &tx_lock);
    800008da:	85ce                	mv	a1,s3
    800008dc:	854a                	mv	a0,s2
    800008de:	5d0010ef          	jal	80001eae <sleep>
    while (tx_busy != 0) {
    800008e2:	409c                	lw	a5,0(s1)
    800008e4:	fbfd                	bnez	a5,800008da <uartwrite+0x4e>
    WriteReg(THR, buf[i]);
    800008e6:	000a4783          	lbu	a5,0(s4)
    800008ea:	00fb8023          	sb	a5,0(s7) # 10000000 <_entry-0x70000000>
    tx_busy = 1;
    800008ee:	0164a023          	sw	s6,0(s1)
  while (i < n) {
    800008f2:	0a05                	addi	s4,s4,1
    800008f4:	015a0563          	beq	s4,s5,800008fe <uartwrite+0x72>
    while (tx_busy != 0) {
    800008f8:	409c                	lw	a5,0(s1)
    800008fa:	f3e5                	bnez	a5,800008da <uartwrite+0x4e>
    800008fc:	b7ed                	j	800008e6 <uartwrite+0x5a>
    800008fe:	7942                	ld	s2,48(sp)
    80000900:	79a2                	ld	s3,40(sp)
    80000902:	7a02                	ld	s4,32(sp)
    80000904:	6b42                	ld	s6,16(sp)
    80000906:	6ba2                	ld	s7,8(sp)
  }

  release(&tx_lock);
    80000908:	00012517          	auipc	a0,0x12
    8000090c:	98850513          	addi	a0,a0,-1656 # 80012290 <tx_lock>
    80000910:	330000ef          	jal	80000c40 <release>
}
    80000914:	60a6                	ld	ra,72(sp)
    80000916:	6406                	ld	s0,64(sp)
    80000918:	74e2                	ld	s1,56(sp)
    8000091a:	6ae2                	ld	s5,24(sp)
    8000091c:	6161                	addi	sp,sp,80
    8000091e:	8082                	ret

0000000080000920 <uartputc_sync>:
// interrupts, for use by kernel printk() and
// to echo characters. it spins waiting for the uart's
// output register to be empty.
void
uartputc_sync(int c)
{
    80000920:	1101                	addi	sp,sp,-32
    80000922:	ec06                	sd	ra,24(sp)
    80000924:	e822                	sd	s0,16(sp)
    80000926:	e426                	sd	s1,8(sp)
    80000928:	1000                	addi	s0,sp,32
    8000092a:	84aa                	mv	s1,a0
  if (panicking == 0)
    8000092c:	0000a797          	auipc	a5,0xa
    80000930:	8787a783          	lw	a5,-1928(a5) # 8000a1a4 <panicking>
    80000934:	cf95                	beqz	a5,80000970 <uartputc_sync+0x50>
    push_off();

  if (panicked) {
    80000936:	0000a797          	auipc	a5,0xa
    8000093a:	86a7a783          	lw	a5,-1942(a5) # 8000a1a0 <panicked>
    8000093e:	ef85                	bnez	a5,80000976 <uartputc_sync+0x56>
    for (;;)
      ;
  }

  // wait for UART to set Transmit Holding Empty in LSR.
  while ((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    80000940:	10000737          	lui	a4,0x10000
    80000944:	0715                	addi	a4,a4,5 # 10000005 <_entry-0x6ffffffb>
    80000946:	00074783          	lbu	a5,0(a4)
    8000094a:	0207f793          	andi	a5,a5,32
    8000094e:	dfe5                	beqz	a5,80000946 <uartputc_sync+0x26>
    ;
  WriteReg(THR, c);
    80000950:	0ff4f513          	zext.b	a0,s1
    80000954:	100007b7          	lui	a5,0x10000
    80000958:	00a78023          	sb	a0,0(a5) # 10000000 <_entry-0x70000000>

  if (panicking == 0)
    8000095c:	0000a797          	auipc	a5,0xa
    80000960:	8487a783          	lw	a5,-1976(a5) # 8000a1a4 <panicking>
    80000964:	cb91                	beqz	a5,80000978 <uartputc_sync+0x58>
    pop_off();
}
    80000966:	60e2                	ld	ra,24(sp)
    80000968:	6442                	ld	s0,16(sp)
    8000096a:	64a2                	ld	s1,8(sp)
    8000096c:	6105                	addi	sp,sp,32
    8000096e:	8082                	ret
    push_off();
    80000970:	1fc000ef          	jal	80000b6c <push_off>
    80000974:	b7c9                	j	80000936 <uartputc_sync+0x16>
    for (;;)
    80000976:	a001                	j	80000976 <uartputc_sync+0x56>
    pop_off();
    80000978:	274000ef          	jal	80000bec <pop_off>
}
    8000097c:	b7ed                	j	80000966 <uartputc_sync+0x46>

000000008000097e <uartintr>:
// handle a uart interrupt, raised because input has
// arrived, or the uart is ready for more output, or
// both. called from devintr().
void
uartintr(void)
{
    8000097e:	1101                	addi	sp,sp,-32
    80000980:	ec06                	sd	ra,24(sp)
    80000982:	e822                	sd	s0,16(sp)
    80000984:	e426                	sd	s1,8(sp)
    80000986:	e04a                	sd	s2,0(sp)
    80000988:	1000                	addi	s0,sp,32
  ReadReg(ISR); // acknowledge the interrupt
    8000098a:	100007b7          	lui	a5,0x10000
    8000098e:	0789                	addi	a5,a5,2 # 10000002 <_entry-0x6ffffffe>
    80000990:	0007c783          	lbu	a5,0(a5)

  acquire(&tx_lock);
    80000994:	00012517          	auipc	a0,0x12
    80000998:	8fc50513          	addi	a0,a0,-1796 # 80012290 <tx_lock>
    8000099c:	210000ef          	jal	80000bac <acquire>
  if (ReadReg(LSR) & LSR_TX_IDLE) {
    800009a0:	100007b7          	lui	a5,0x10000
    800009a4:	0795                	addi	a5,a5,5 # 10000005 <_entry-0x6ffffffb>
    800009a6:	0007c783          	lbu	a5,0(a5)
    800009aa:	0207f793          	andi	a5,a5,32
    800009ae:	e78d                	bnez	a5,800009d8 <uartintr+0x5a>
    // UART finished transmitting; wake up sending thread.
    tx_busy = 0;
    wakeup(&tx_chan);
  }
  release(&tx_lock);
    800009b0:	00012517          	auipc	a0,0x12
    800009b4:	8e050513          	addi	a0,a0,-1824 # 80012290 <tx_lock>
    800009b8:	288000ef          	jal	80000c40 <release>
  if (ReadReg(LSR) & LSR_RX_READY) {
    800009bc:	100004b7          	lui	s1,0x10000
    800009c0:	0495                	addi	s1,s1,5 # 10000005 <_entry-0x6ffffffb>
    return ReadReg(RHR);
    800009c2:	10000937          	lui	s2,0x10000
  if (ReadReg(LSR) & LSR_RX_READY) {
    800009c6:	0004c783          	lbu	a5,0(s1)
    800009ca:	8b85                	andi	a5,a5,1
    800009cc:	c38d                	beqz	a5,800009ee <uartintr+0x70>
    return ReadReg(RHR);
    800009ce:	00094503          	lbu	a0,0(s2) # 10000000 <_entry-0x70000000>
  // read and process incoming characters, if any.
  while (1) {
    int c = uartgetc();
    if (c == -1)
      break;
    consoleintr(c);
    800009d2:	8cdff0ef          	jal	8000029e <consoleintr>
  while (1) {
    800009d6:	bfc5                	j	800009c6 <uartintr+0x48>
    tx_busy = 0;
    800009d8:	00009797          	auipc	a5,0x9
    800009dc:	7c07aa23          	sw	zero,2004(a5) # 8000a1ac <tx_busy>
    wakeup(&tx_chan);
    800009e0:	00009517          	auipc	a0,0x9
    800009e4:	7c850513          	addi	a0,a0,1992 # 8000a1a8 <tx_chan>
    800009e8:	512010ef          	jal	80001efa <wakeup>
    800009ec:	b7d1                	j	800009b0 <uartintr+0x32>
  }
}
    800009ee:	60e2                	ld	ra,24(sp)
    800009f0:	6442                	ld	s0,16(sp)
    800009f2:	64a2                	ld	s1,8(sp)
    800009f4:	6902                	ld	s2,0(sp)
    800009f6:	6105                	addi	sp,sp,32
    800009f8:	8082                	ret

00000000800009fa <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(void *pa)
{
    800009fa:	1101                	addi	sp,sp,-32
    800009fc:	ec06                	sd	ra,24(sp)
    800009fe:	e822                	sd	s0,16(sp)
    80000a00:	e426                	sd	s1,8(sp)
    80000a02:	e04a                	sd	s2,0(sp)
    80000a04:	1000                	addi	s0,sp,32
  struct run *r;

  if (((uint64)pa % PGSIZE) != 0 || (char *)pa < end || (uint64)pa >= PHYSTOP)
    80000a06:	03451793          	slli	a5,a0,0x34
    80000a0a:	e7a9                	bnez	a5,80000a54 <kfree+0x5a>
    80000a0c:	84aa                	mv	s1,a0
    80000a0e:	00023797          	auipc	a5,0x23
    80000a12:	aca78793          	addi	a5,a5,-1334 # 800234d8 <end>
    80000a16:	02f56f63          	bltu	a0,a5,80000a54 <kfree+0x5a>
    80000a1a:	47c5                	li	a5,17
    80000a1c:	07ee                	slli	a5,a5,0x1b
    80000a1e:	02f57b63          	bgeu	a0,a5,80000a54 <kfree+0x5a>
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(pa, 1, PGSIZE);
    80000a22:	6605                	lui	a2,0x1
    80000a24:	4585                	li	a1,1
    80000a26:	252000ef          	jal	80000c78 <memset>

  r = (struct run *)pa;

  acquire(&kmem.lock);
    80000a2a:	00012917          	auipc	s2,0x12
    80000a2e:	87e90913          	addi	s2,s2,-1922 # 800122a8 <kmem>
    80000a32:	854a                	mv	a0,s2
    80000a34:	178000ef          	jal	80000bac <acquire>
  r->next = kmem.freelist;
    80000a38:	01893783          	ld	a5,24(s2)
    80000a3c:	e09c                	sd	a5,0(s1)
  kmem.freelist = r;
    80000a3e:	00993c23          	sd	s1,24(s2)
  release(&kmem.lock);
    80000a42:	854a                	mv	a0,s2
    80000a44:	1fc000ef          	jal	80000c40 <release>
}
    80000a48:	60e2                	ld	ra,24(sp)
    80000a4a:	6442                	ld	s0,16(sp)
    80000a4c:	64a2                	ld	s1,8(sp)
    80000a4e:	6902                	ld	s2,0(sp)
    80000a50:	6105                	addi	sp,sp,32
    80000a52:	8082                	ret
    panic("kfree");
    80000a54:	00006517          	auipc	a0,0x6
    80000a58:	5e450513          	addi	a0,a0,1508 # 80007038 <etext+0x38>
    80000a5c:	d79ff0ef          	jal	800007d4 <panic>

0000000080000a60 <freerange>:
{
    80000a60:	7179                	addi	sp,sp,-48
    80000a62:	f406                	sd	ra,40(sp)
    80000a64:	f022                	sd	s0,32(sp)
    80000a66:	ec26                	sd	s1,24(sp)
    80000a68:	1800                	addi	s0,sp,48
  p = (char *)PGROUNDUP((uint64)pa_start);
    80000a6a:	6785                	lui	a5,0x1
    80000a6c:	fff78713          	addi	a4,a5,-1 # fff <_entry-0x7ffff001>
    80000a70:	00e504b3          	add	s1,a0,a4
    80000a74:	777d                	lui	a4,0xfffff
    80000a76:	8cf9                	and	s1,s1,a4
  for (; p + PGSIZE <= (char *)pa_end; p += PGSIZE)
    80000a78:	94be                	add	s1,s1,a5
    80000a7a:	0295e263          	bltu	a1,s1,80000a9e <freerange+0x3e>
    80000a7e:	e84a                	sd	s2,16(sp)
    80000a80:	e44e                	sd	s3,8(sp)
    80000a82:	e052                	sd	s4,0(sp)
    80000a84:	892e                	mv	s2,a1
    kfree(p);
    80000a86:	7a7d                	lui	s4,0xfffff
  for (; p + PGSIZE <= (char *)pa_end; p += PGSIZE)
    80000a88:	6985                	lui	s3,0x1
    kfree(p);
    80000a8a:	01448533          	add	a0,s1,s4
    80000a8e:	f6dff0ef          	jal	800009fa <kfree>
  for (; p + PGSIZE <= (char *)pa_end; p += PGSIZE)
    80000a92:	94ce                	add	s1,s1,s3
    80000a94:	fe997be3          	bgeu	s2,s1,80000a8a <freerange+0x2a>
    80000a98:	6942                	ld	s2,16(sp)
    80000a9a:	69a2                	ld	s3,8(sp)
    80000a9c:	6a02                	ld	s4,0(sp)
}
    80000a9e:	70a2                	ld	ra,40(sp)
    80000aa0:	7402                	ld	s0,32(sp)
    80000aa2:	64e2                	ld	s1,24(sp)
    80000aa4:	6145                	addi	sp,sp,48
    80000aa6:	8082                	ret

0000000080000aa8 <kinit>:
{
    80000aa8:	1141                	addi	sp,sp,-16
    80000aaa:	e406                	sd	ra,8(sp)
    80000aac:	e022                	sd	s0,0(sp)
    80000aae:	0800                	addi	s0,sp,16
  initlock(&kmem.lock, "kmem");
    80000ab0:	00006597          	auipc	a1,0x6
    80000ab4:	59058593          	addi	a1,a1,1424 # 80007040 <etext+0x40>
    80000ab8:	00011517          	auipc	a0,0x11
    80000abc:	7f050513          	addi	a0,a0,2032 # 800122a8 <kmem>
    80000ac0:	06c000ef          	jal	80000b2c <initlock>
  freerange(end, (void *)PHYSTOP);
    80000ac4:	45c5                	li	a1,17
    80000ac6:	05ee                	slli	a1,a1,0x1b
    80000ac8:	00023517          	auipc	a0,0x23
    80000acc:	a1050513          	addi	a0,a0,-1520 # 800234d8 <end>
    80000ad0:	f91ff0ef          	jal	80000a60 <freerange>
}
    80000ad4:	60a2                	ld	ra,8(sp)
    80000ad6:	6402                	ld	s0,0(sp)
    80000ad8:	0141                	addi	sp,sp,16
    80000ada:	8082                	ret

0000000080000adc <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void *
kalloc(void)
{
    80000adc:	1101                	addi	sp,sp,-32
    80000ade:	ec06                	sd	ra,24(sp)
    80000ae0:	e822                	sd	s0,16(sp)
    80000ae2:	e426                	sd	s1,8(sp)
    80000ae4:	1000                	addi	s0,sp,32
  struct run *r;

  acquire(&kmem.lock);
    80000ae6:	00011497          	auipc	s1,0x11
    80000aea:	7c248493          	addi	s1,s1,1986 # 800122a8 <kmem>
    80000aee:	8526                	mv	a0,s1
    80000af0:	0bc000ef          	jal	80000bac <acquire>
  r = kmem.freelist;
    80000af4:	6c84                	ld	s1,24(s1)
  if (r)
    80000af6:	c485                	beqz	s1,80000b1e <kalloc+0x42>
    kmem.freelist = r->next;
    80000af8:	609c                	ld	a5,0(s1)
    80000afa:	00011517          	auipc	a0,0x11
    80000afe:	7ae50513          	addi	a0,a0,1966 # 800122a8 <kmem>
    80000b02:	ed1c                	sd	a5,24(a0)
  release(&kmem.lock);
    80000b04:	13c000ef          	jal	80000c40 <release>

  if (r)
    memset((char *)r, 5, PGSIZE); // fill with junk
    80000b08:	6605                	lui	a2,0x1
    80000b0a:	4595                	li	a1,5
    80000b0c:	8526                	mv	a0,s1
    80000b0e:	16a000ef          	jal	80000c78 <memset>
  return (void *)r;
}
    80000b12:	8526                	mv	a0,s1
    80000b14:	60e2                	ld	ra,24(sp)
    80000b16:	6442                	ld	s0,16(sp)
    80000b18:	64a2                	ld	s1,8(sp)
    80000b1a:	6105                	addi	sp,sp,32
    80000b1c:	8082                	ret
  release(&kmem.lock);
    80000b1e:	00011517          	auipc	a0,0x11
    80000b22:	78a50513          	addi	a0,a0,1930 # 800122a8 <kmem>
    80000b26:	11a000ef          	jal	80000c40 <release>
  if (r)
    80000b2a:	b7e5                	j	80000b12 <kalloc+0x36>

0000000080000b2c <initlock>:
#include "proc.h"
#include "defs.h"

void
initlock(struct spinlock *lk, char *name)
{
    80000b2c:	1141                	addi	sp,sp,-16
    80000b2e:	e422                	sd	s0,8(sp)
    80000b30:	0800                	addi	s0,sp,16
  lk->name = name;
    80000b32:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    80000b34:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    80000b38:	00053823          	sd	zero,16(a0)
}
    80000b3c:	6422                	ld	s0,8(sp)
    80000b3e:	0141                	addi	sp,sp,16
    80000b40:	8082                	ret

0000000080000b42 <holding>:
// Interrupts must be off.
int
holding(struct spinlock *lk)
{
  int r;
  r = (lk->locked && lk->cpu == mycpu());
    80000b42:	411c                	lw	a5,0(a0)
    80000b44:	e399                	bnez	a5,80000b4a <holding+0x8>
    80000b46:	4501                	li	a0,0
  return r;
}
    80000b48:	8082                	ret
{
    80000b4a:	1101                	addi	sp,sp,-32
    80000b4c:	ec06                	sd	ra,24(sp)
    80000b4e:	e822                	sd	s0,16(sp)
    80000b50:	e426                	sd	s1,8(sp)
    80000b52:	1000                	addi	s0,sp,32
  r = (lk->locked && lk->cpu == mycpu());
    80000b54:	6904                	ld	s1,16(a0)
    80000b56:	533000ef          	jal	80001888 <mycpu>
    80000b5a:	40a48533          	sub	a0,s1,a0
    80000b5e:	00153513          	seqz	a0,a0
}
    80000b62:	60e2                	ld	ra,24(sp)
    80000b64:	6442                	ld	s0,16(sp)
    80000b66:	64a2                	ld	s1,8(sp)
    80000b68:	6105                	addi	sp,sp,32
    80000b6a:	8082                	ret

0000000080000b6c <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    80000b6c:	1101                	addi	sp,sp,-32
    80000b6e:	ec06                	sd	ra,24(sp)
    80000b70:	e822                	sd	s0,16(sp)
    80000b72:	e426                	sd	s1,8(sp)
    80000b74:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r"(x));
    80000b76:	100024f3          	csrr	s1,sstatus
    80000b7a:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80000b7e:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r"(x));
    80000b80:	10079073          	csrw	sstatus,a5

  // disable interrupts to prevent an involuntary context
  // switch while using mycpu().
  intr_off();

  if (mycpu()->noff == 0)
    80000b84:	505000ef          	jal	80001888 <mycpu>
    80000b88:	5d3c                	lw	a5,120(a0)
    80000b8a:	cb99                	beqz	a5,80000ba0 <push_off+0x34>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000b8c:	4fd000ef          	jal	80001888 <mycpu>
    80000b90:	5d3c                	lw	a5,120(a0)
    80000b92:	2785                	addiw	a5,a5,1
    80000b94:	dd3c                	sw	a5,120(a0)
}
    80000b96:	60e2                	ld	ra,24(sp)
    80000b98:	6442                	ld	s0,16(sp)
    80000b9a:	64a2                	ld	s1,8(sp)
    80000b9c:	6105                	addi	sp,sp,32
    80000b9e:	8082                	ret
    mycpu()->intena = old;
    80000ba0:	4e9000ef          	jal	80001888 <mycpu>
  return (x & SSTATUS_SIE) != 0;
    80000ba4:	8085                	srli	s1,s1,0x1
    80000ba6:	8885                	andi	s1,s1,1
    80000ba8:	dd64                	sw	s1,124(a0)
    80000baa:	b7cd                	j	80000b8c <push_off+0x20>

0000000080000bac <acquire>:
{
    80000bac:	1101                	addi	sp,sp,-32
    80000bae:	ec06                	sd	ra,24(sp)
    80000bb0:	e822                	sd	s0,16(sp)
    80000bb2:	e426                	sd	s1,8(sp)
    80000bb4:	1000                	addi	s0,sp,32
    80000bb6:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    80000bb8:	fb5ff0ef          	jal	80000b6c <push_off>
  if (holding(lk))
    80000bbc:	8526                	mv	a0,s1
    80000bbe:	f85ff0ef          	jal	80000b42 <holding>
  while (__atomic_exchange_n(&lk->locked, 1, __ATOMIC_ACQUIRE) != 0)
    80000bc2:	4705                	li	a4,1
  if (holding(lk))
    80000bc4:	ed11                	bnez	a0,80000be0 <acquire+0x34>
  while (__atomic_exchange_n(&lk->locked, 1, __ATOMIC_ACQUIRE) != 0)
    80000bc6:	87ba                	mv	a5,a4
    80000bc8:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    80000bcc:	2781                	sext.w	a5,a5
    80000bce:	ffe5                	bnez	a5,80000bc6 <acquire+0x1a>
  lk->cpu = mycpu();
    80000bd0:	4b9000ef          	jal	80001888 <mycpu>
    80000bd4:	e888                	sd	a0,16(s1)
}
    80000bd6:	60e2                	ld	ra,24(sp)
    80000bd8:	6442                	ld	s0,16(sp)
    80000bda:	64a2                	ld	s1,8(sp)
    80000bdc:	6105                	addi	sp,sp,32
    80000bde:	8082                	ret
    panic("acquire");
    80000be0:	00006517          	auipc	a0,0x6
    80000be4:	46850513          	addi	a0,a0,1128 # 80007048 <etext+0x48>
    80000be8:	bedff0ef          	jal	800007d4 <panic>

0000000080000bec <pop_off>:

void
pop_off(void)
{
    80000bec:	1141                	addi	sp,sp,-16
    80000bee:	e406                	sd	ra,8(sp)
    80000bf0:	e022                	sd	s0,0(sp)
    80000bf2:	0800                	addi	s0,sp,16
  struct cpu *c = mycpu();
    80000bf4:	495000ef          	jal	80001888 <mycpu>
  asm volatile("csrr %0, sstatus" : "=r"(x));
    80000bf8:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80000bfc:	8b89                	andi	a5,a5,2
  if (intr_get())
    80000bfe:	e78d                	bnez	a5,80000c28 <pop_off+0x3c>
    panic("pop_off - interruptible");
  if (c->noff < 1)
    80000c00:	5d3c                	lw	a5,120(a0)
    80000c02:	02f05963          	blez	a5,80000c34 <pop_off+0x48>
    panic("pop_off");
  c->noff -= 1;
    80000c06:	37fd                	addiw	a5,a5,-1
    80000c08:	0007871b          	sext.w	a4,a5
    80000c0c:	dd3c                	sw	a5,120(a0)
  if (c->noff == 0 && c->intena)
    80000c0e:	eb09                	bnez	a4,80000c20 <pop_off+0x34>
    80000c10:	5d7c                	lw	a5,124(a0)
    80000c12:	c799                	beqz	a5,80000c20 <pop_off+0x34>
  asm volatile("csrr %0, sstatus" : "=r"(x));
    80000c14:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80000c18:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r"(x));
    80000c1c:	10079073          	csrw	sstatus,a5
    intr_on();
}
    80000c20:	60a2                	ld	ra,8(sp)
    80000c22:	6402                	ld	s0,0(sp)
    80000c24:	0141                	addi	sp,sp,16
    80000c26:	8082                	ret
    panic("pop_off - interruptible");
    80000c28:	00006517          	auipc	a0,0x6
    80000c2c:	42850513          	addi	a0,a0,1064 # 80007050 <etext+0x50>
    80000c30:	ba5ff0ef          	jal	800007d4 <panic>
    panic("pop_off");
    80000c34:	00006517          	auipc	a0,0x6
    80000c38:	43450513          	addi	a0,a0,1076 # 80007068 <etext+0x68>
    80000c3c:	b99ff0ef          	jal	800007d4 <panic>

0000000080000c40 <release>:
{
    80000c40:	1101                	addi	sp,sp,-32
    80000c42:	ec06                	sd	ra,24(sp)
    80000c44:	e822                	sd	s0,16(sp)
    80000c46:	e426                	sd	s1,8(sp)
    80000c48:	1000                	addi	s0,sp,32
    80000c4a:	84aa                	mv	s1,a0
  if (!holding(lk))
    80000c4c:	ef7ff0ef          	jal	80000b42 <holding>
    80000c50:	cd11                	beqz	a0,80000c6c <release+0x2c>
  lk->cpu = 0;
    80000c52:	0004b823          	sd	zero,16(s1)
  __atomic_store_n(&lk->locked, 0, __ATOMIC_RELEASE);
    80000c56:	0310000f          	fence	rw,w
    80000c5a:	0004a023          	sw	zero,0(s1)
  pop_off();
    80000c5e:	f8fff0ef          	jal	80000bec <pop_off>
}
    80000c62:	60e2                	ld	ra,24(sp)
    80000c64:	6442                	ld	s0,16(sp)
    80000c66:	64a2                	ld	s1,8(sp)
    80000c68:	6105                	addi	sp,sp,32
    80000c6a:	8082                	ret
    panic("release");
    80000c6c:	00006517          	auipc	a0,0x6
    80000c70:	40450513          	addi	a0,a0,1028 # 80007070 <etext+0x70>
    80000c74:	b61ff0ef          	jal	800007d4 <panic>

0000000080000c78 <memset>:
#include "types.h"

void *
memset(void *dst, int c, uint n)
{
    80000c78:	1141                	addi	sp,sp,-16
    80000c7a:	e422                	sd	s0,8(sp)
    80000c7c:	0800                	addi	s0,sp,16
  char *cdst = (char *)dst;
  int i;
  for (i = 0; i < n; i++) {
    80000c7e:	ca19                	beqz	a2,80000c94 <memset+0x1c>
    80000c80:	87aa                	mv	a5,a0
    80000c82:	1602                	slli	a2,a2,0x20
    80000c84:	9201                	srli	a2,a2,0x20
    80000c86:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
    80000c8a:	00b78023          	sb	a1,0(a5)
  for (i = 0; i < n; i++) {
    80000c8e:	0785                	addi	a5,a5,1
    80000c90:	fee79de3          	bne	a5,a4,80000c8a <memset+0x12>
  }
  return dst;
}
    80000c94:	6422                	ld	s0,8(sp)
    80000c96:	0141                	addi	sp,sp,16
    80000c98:	8082                	ret

0000000080000c9a <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    80000c9a:	1141                	addi	sp,sp,-16
    80000c9c:	e422                	sd	s0,8(sp)
    80000c9e:	0800                	addi	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while (n-- > 0) {
    80000ca0:	ca05                	beqz	a2,80000cd0 <memcmp+0x36>
    80000ca2:	fff6069b          	addiw	a3,a2,-1 # fff <_entry-0x7ffff001>
    80000ca6:	1682                	slli	a3,a3,0x20
    80000ca8:	9281                	srli	a3,a3,0x20
    80000caa:	0685                	addi	a3,a3,1
    80000cac:	96aa                	add	a3,a3,a0
    if (*s1 != *s2)
    80000cae:	00054783          	lbu	a5,0(a0)
    80000cb2:	0005c703          	lbu	a4,0(a1)
    80000cb6:	00e79863          	bne	a5,a4,80000cc6 <memcmp+0x2c>
      return *s1 - *s2;
    s1++, s2++;
    80000cba:	0505                	addi	a0,a0,1
    80000cbc:	0585                	addi	a1,a1,1
  while (n-- > 0) {
    80000cbe:	fed518e3          	bne	a0,a3,80000cae <memcmp+0x14>
  }

  return 0;
    80000cc2:	4501                	li	a0,0
    80000cc4:	a019                	j	80000cca <memcmp+0x30>
      return *s1 - *s2;
    80000cc6:	40e7853b          	subw	a0,a5,a4
}
    80000cca:	6422                	ld	s0,8(sp)
    80000ccc:	0141                	addi	sp,sp,16
    80000cce:	8082                	ret
  return 0;
    80000cd0:	4501                	li	a0,0
    80000cd2:	bfe5                	j	80000cca <memcmp+0x30>

0000000080000cd4 <memmove>:

void *
memmove(void *dst, const void *src, uint n)
{
    80000cd4:	1141                	addi	sp,sp,-16
    80000cd6:	e422                	sd	s0,8(sp)
    80000cd8:	0800                	addi	s0,sp,16
  const char *s;
  char *d;

  if (n == 0)
    80000cda:	c205                	beqz	a2,80000cfa <memmove+0x26>
    return dst;

  s = src;
  d = dst;
  if (s < d && s + n > d) {
    80000cdc:	02a5e263          	bltu	a1,a0,80000d00 <memmove+0x2c>
    s += n;
    d += n;
    while (n-- > 0)
      *--d = *--s;
  } else
    while (n-- > 0)
    80000ce0:	1602                	slli	a2,a2,0x20
    80000ce2:	9201                	srli	a2,a2,0x20
    80000ce4:	00c587b3          	add	a5,a1,a2
{
    80000ce8:	872a                	mv	a4,a0
      *d++ = *s++;
    80000cea:	0585                	addi	a1,a1,1
    80000cec:	0705                	addi	a4,a4,1 # fffffffffffff001 <end+0xffffffff7ffdbb29>
    80000cee:	fff5c683          	lbu	a3,-1(a1)
    80000cf2:	fed70fa3          	sb	a3,-1(a4)
    while (n-- > 0)
    80000cf6:	feb79ae3          	bne	a5,a1,80000cea <memmove+0x16>

  return dst;
}
    80000cfa:	6422                	ld	s0,8(sp)
    80000cfc:	0141                	addi	sp,sp,16
    80000cfe:	8082                	ret
  if (s < d && s + n > d) {
    80000d00:	02061693          	slli	a3,a2,0x20
    80000d04:	9281                	srli	a3,a3,0x20
    80000d06:	00d58733          	add	a4,a1,a3
    80000d0a:	fce57be3          	bgeu	a0,a4,80000ce0 <memmove+0xc>
    d += n;
    80000d0e:	96aa                	add	a3,a3,a0
    while (n-- > 0)
    80000d10:	fff6079b          	addiw	a5,a2,-1
    80000d14:	1782                	slli	a5,a5,0x20
    80000d16:	9381                	srli	a5,a5,0x20
    80000d18:	fff7c793          	not	a5,a5
    80000d1c:	97ba                	add	a5,a5,a4
      *--d = *--s;
    80000d1e:	177d                	addi	a4,a4,-1
    80000d20:	16fd                	addi	a3,a3,-1
    80000d22:	00074603          	lbu	a2,0(a4)
    80000d26:	00c68023          	sb	a2,0(a3)
    while (n-- > 0)
    80000d2a:	fef71ae3          	bne	a4,a5,80000d1e <memmove+0x4a>
    80000d2e:	b7f1                	j	80000cfa <memmove+0x26>

0000000080000d30 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void *
memcpy(void *dst, const void *src, uint n)
{
    80000d30:	1141                	addi	sp,sp,-16
    80000d32:	e406                	sd	ra,8(sp)
    80000d34:	e022                	sd	s0,0(sp)
    80000d36:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    80000d38:	f9dff0ef          	jal	80000cd4 <memmove>
}
    80000d3c:	60a2                	ld	ra,8(sp)
    80000d3e:	6402                	ld	s0,0(sp)
    80000d40:	0141                	addi	sp,sp,16
    80000d42:	8082                	ret

0000000080000d44 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    80000d44:	1141                	addi	sp,sp,-16
    80000d46:	e422                	sd	s0,8(sp)
    80000d48:	0800                	addi	s0,sp,16
  while (n > 0 && *p && *p == *q)
    80000d4a:	ce11                	beqz	a2,80000d66 <strncmp+0x22>
    80000d4c:	00054783          	lbu	a5,0(a0)
    80000d50:	cf89                	beqz	a5,80000d6a <strncmp+0x26>
    80000d52:	0005c703          	lbu	a4,0(a1)
    80000d56:	00f71a63          	bne	a4,a5,80000d6a <strncmp+0x26>
    n--, p++, q++;
    80000d5a:	367d                	addiw	a2,a2,-1
    80000d5c:	0505                	addi	a0,a0,1
    80000d5e:	0585                	addi	a1,a1,1
  while (n > 0 && *p && *p == *q)
    80000d60:	f675                	bnez	a2,80000d4c <strncmp+0x8>
  if (n == 0)
    return 0;
    80000d62:	4501                	li	a0,0
    80000d64:	a801                	j	80000d74 <strncmp+0x30>
    80000d66:	4501                	li	a0,0
    80000d68:	a031                	j	80000d74 <strncmp+0x30>
  return (uchar)*p - (uchar)*q;
    80000d6a:	00054503          	lbu	a0,0(a0)
    80000d6e:	0005c783          	lbu	a5,0(a1)
    80000d72:	9d1d                	subw	a0,a0,a5
}
    80000d74:	6422                	ld	s0,8(sp)
    80000d76:	0141                	addi	sp,sp,16
    80000d78:	8082                	ret

0000000080000d7a <strncpy>:

char *
strncpy(char *s, const char *t, int n)
{
    80000d7a:	1141                	addi	sp,sp,-16
    80000d7c:	e422                	sd	s0,8(sp)
    80000d7e:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while (n-- > 0 && (*s++ = *t++) != 0)
    80000d80:	87aa                	mv	a5,a0
    80000d82:	86b2                	mv	a3,a2
    80000d84:	367d                	addiw	a2,a2,-1
    80000d86:	02d05563          	blez	a3,80000db0 <strncpy+0x36>
    80000d8a:	0785                	addi	a5,a5,1
    80000d8c:	0005c703          	lbu	a4,0(a1)
    80000d90:	fee78fa3          	sb	a4,-1(a5)
    80000d94:	0585                	addi	a1,a1,1
    80000d96:	f775                	bnez	a4,80000d82 <strncpy+0x8>
    ;
  while (n-- > 0)
    80000d98:	873e                	mv	a4,a5
    80000d9a:	9fb5                	addw	a5,a5,a3
    80000d9c:	37fd                	addiw	a5,a5,-1
    80000d9e:	00c05963          	blez	a2,80000db0 <strncpy+0x36>
    *s++ = 0;
    80000da2:	0705                	addi	a4,a4,1
    80000da4:	fe070fa3          	sb	zero,-1(a4)
  while (n-- > 0)
    80000da8:	40e786bb          	subw	a3,a5,a4
    80000dac:	fed04be3          	bgtz	a3,80000da2 <strncpy+0x28>
  return os;
}
    80000db0:	6422                	ld	s0,8(sp)
    80000db2:	0141                	addi	sp,sp,16
    80000db4:	8082                	ret

0000000080000db6 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char *
safestrcpy(char *s, const char *t, int n)
{
    80000db6:	1141                	addi	sp,sp,-16
    80000db8:	e422                	sd	s0,8(sp)
    80000dba:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  if (n <= 0)
    80000dbc:	02c05363          	blez	a2,80000de2 <safestrcpy+0x2c>
    80000dc0:	fff6069b          	addiw	a3,a2,-1
    80000dc4:	1682                	slli	a3,a3,0x20
    80000dc6:	9281                	srli	a3,a3,0x20
    80000dc8:	96ae                	add	a3,a3,a1
    80000dca:	87aa                	mv	a5,a0
    return os;
  while (--n > 0 && (*s++ = *t++) != 0)
    80000dcc:	00d58963          	beq	a1,a3,80000dde <safestrcpy+0x28>
    80000dd0:	0585                	addi	a1,a1,1
    80000dd2:	0785                	addi	a5,a5,1
    80000dd4:	fff5c703          	lbu	a4,-1(a1)
    80000dd8:	fee78fa3          	sb	a4,-1(a5)
    80000ddc:	fb65                	bnez	a4,80000dcc <safestrcpy+0x16>
    ;
  *s = 0;
    80000dde:	00078023          	sb	zero,0(a5)
  return os;
}
    80000de2:	6422                	ld	s0,8(sp)
    80000de4:	0141                	addi	sp,sp,16
    80000de6:	8082                	ret

0000000080000de8 <strlen>:

int
strlen(const char *s)
{
    80000de8:	1141                	addi	sp,sp,-16
    80000dea:	e422                	sd	s0,8(sp)
    80000dec:	0800                	addi	s0,sp,16
  int n;

  for (n = 0; s[n]; n++)
    80000dee:	00054783          	lbu	a5,0(a0)
    80000df2:	cf91                	beqz	a5,80000e0e <strlen+0x26>
    80000df4:	0505                	addi	a0,a0,1
    80000df6:	87aa                	mv	a5,a0
    80000df8:	86be                	mv	a3,a5
    80000dfa:	0785                	addi	a5,a5,1
    80000dfc:	fff7c703          	lbu	a4,-1(a5)
    80000e00:	ff65                	bnez	a4,80000df8 <strlen+0x10>
    80000e02:	40a6853b          	subw	a0,a3,a0
    80000e06:	2505                	addiw	a0,a0,1
    ;
  return n;
}
    80000e08:	6422                	ld	s0,8(sp)
    80000e0a:	0141                	addi	sp,sp,16
    80000e0c:	8082                	ret
  for (n = 0; s[n]; n++)
    80000e0e:	4501                	li	a0,0
    80000e10:	bfe5                	j	80000e08 <strlen+0x20>

0000000080000e12 <main>:
volatile static int started = 0;

// start() jumps here in supervisor mode on all CPUs.
void
main()
{
    80000e12:	1141                	addi	sp,sp,-16
    80000e14:	e406                	sd	ra,8(sp)
    80000e16:	e022                	sd	s0,0(sp)
    80000e18:	0800                	addi	s0,sp,16
  if (cpuid() == 0) {
    80000e1a:	25f000ef          	jal	80001878 <cpuid>
    virtio_disk_init(); // emulated hard disk
    userinit();         // first user process
    __atomic_thread_fence(__ATOMIC_SEQ_CST);
    started = 1;
  } else {
    while (started == 0)
    80000e1e:	00009717          	auipc	a4,0x9
    80000e22:	39270713          	addi	a4,a4,914 # 8000a1b0 <started>
  if (cpuid() == 0) {
    80000e26:	c51d                	beqz	a0,80000e54 <main+0x42>
    while (started == 0)
    80000e28:	431c                	lw	a5,0(a4)
    80000e2a:	2781                	sext.w	a5,a5
    80000e2c:	dff5                	beqz	a5,80000e28 <main+0x16>
      ;
    __atomic_thread_fence(__ATOMIC_SEQ_CST);
    80000e2e:	0330000f          	fence	rw,rw
    printk("hart %d starting\n", cpuid());
    80000e32:	247000ef          	jal	80001878 <cpuid>
    80000e36:	85aa                	mv	a1,a0
    80000e38:	00006517          	auipc	a0,0x6
    80000e3c:	26050513          	addi	a0,a0,608 # 80007098 <etext+0x98>
    80000e40:	eaeff0ef          	jal	800004ee <printk>
    kvminithart();  // turn on paging
    80000e44:	080000ef          	jal	80000ec4 <kvminithart>
    trapinithart(); // install kernel trap vector
    80000e48:	588010ef          	jal	800023d0 <trapinithart>
    plicinithart(); // ask PLIC for device interrupts
    80000e4c:	5bc040ef          	jal	80005408 <plicinithart>
  }

  scheduler();
    80000e50:	6c7000ef          	jal	80001d16 <scheduler>
    consoleinit();
    80000e54:	dc4ff0ef          	jal	80000418 <consoleinit>
    printkinit();
    80000e58:	9b9ff0ef          	jal	80000810 <printkinit>
    printk("\n");
    80000e5c:	00006517          	auipc	a0,0x6
    80000e60:	21c50513          	addi	a0,a0,540 # 80007078 <etext+0x78>
    80000e64:	e8aff0ef          	jal	800004ee <printk>
    printk("xv6 kernel is booting\n");
    80000e68:	00006517          	auipc	a0,0x6
    80000e6c:	21850513          	addi	a0,a0,536 # 80007080 <etext+0x80>
    80000e70:	e7eff0ef          	jal	800004ee <printk>
    printk("\n");
    80000e74:	00006517          	auipc	a0,0x6
    80000e78:	20450513          	addi	a0,a0,516 # 80007078 <etext+0x78>
    80000e7c:	e72ff0ef          	jal	800004ee <printk>
    kinit();            // physical page allocator
    80000e80:	c29ff0ef          	jal	80000aa8 <kinit>
    kvminit();          // create kernel page table
    80000e84:	2ca000ef          	jal	8000114e <kvminit>
    kvminithart();      // turn on paging
    80000e88:	03c000ef          	jal	80000ec4 <kvminithart>
    procinit();         // process table
    80000e8c:	137000ef          	jal	800017c2 <procinit>
    trapinit();         // trap vectors
    80000e90:	51c010ef          	jal	800023ac <trapinit>
    trapinithart();     // install kernel trap vector
    80000e94:	53c010ef          	jal	800023d0 <trapinithart>
    plicinit();         // set up interrupt controller
    80000e98:	556040ef          	jal	800053ee <plicinit>
    plicinithart();     // ask PLIC for device interrupts
    80000e9c:	56c040ef          	jal	80005408 <plicinithart>
    binit();            // buffer cache
    80000ea0:	3c7010ef          	jal	80002a66 <binit>
    iinit();            // inode table
    80000ea4:	14c020ef          	jal	80002ff0 <iinit>
    fileinit();         // file table
    80000ea8:	0a6030ef          	jal	80003f4e <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000eac:	64c040ef          	jal	800054f8 <virtio_disk_init>
    userinit();         // first user process
    80000eb0:	4bb000ef          	jal	80001b6a <userinit>
    __atomic_thread_fence(__ATOMIC_SEQ_CST);
    80000eb4:	0330000f          	fence	rw,rw
    started = 1;
    80000eb8:	4785                	li	a5,1
    80000eba:	00009717          	auipc	a4,0x9
    80000ebe:	2ef72b23          	sw	a5,758(a4) # 8000a1b0 <started>
    80000ec2:	b779                	j	80000e50 <main+0x3e>

0000000080000ec4 <kvminithart>:

// Switch the current CPU's h/w page table register to
// the kernel's page table, and enable paging.
void
kvminithart()
{
    80000ec4:	1141                	addi	sp,sp,-16
    80000ec6:	e422                	sd	s0,8(sp)
    80000ec8:	0800                	addi	s0,sp,16
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero");
    80000eca:	12000073          	sfence.vma
  // wait for any previous writes to the page table memory to finish.
  sfence_vma();

  w_satp(MAKE_SATP(kernel_pagetable));
    80000ece:	00009797          	auipc	a5,0x9
    80000ed2:	2ea7b783          	ld	a5,746(a5) # 8000a1b8 <kernel_pagetable>
    80000ed6:	83b1                	srli	a5,a5,0xc
    80000ed8:	577d                	li	a4,-1
    80000eda:	177e                	slli	a4,a4,0x3f
    80000edc:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r"(x));
    80000ede:	18079073          	csrw	satp,a5
  asm volatile("sfence.vma zero, zero");
    80000ee2:	12000073          	sfence.vma

  // flush stale entries from the TLB.
  sfence_vma();
}
    80000ee6:	6422                	ld	s0,8(sp)
    80000ee8:	0141                	addi	sp,sp,16
    80000eea:	8082                	ret

0000000080000eec <walk>:
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    80000eec:	7139                	addi	sp,sp,-64
    80000eee:	fc06                	sd	ra,56(sp)
    80000ef0:	f822                	sd	s0,48(sp)
    80000ef2:	f426                	sd	s1,40(sp)
    80000ef4:	f04a                	sd	s2,32(sp)
    80000ef6:	ec4e                	sd	s3,24(sp)
    80000ef8:	e852                	sd	s4,16(sp)
    80000efa:	e456                	sd	s5,8(sp)
    80000efc:	e05a                	sd	s6,0(sp)
    80000efe:	0080                	addi	s0,sp,64
    80000f00:	84aa                	mv	s1,a0
    80000f02:	89ae                	mv	s3,a1
    80000f04:	8ab2                	mv	s5,a2
  if (va >= MAXVA)
    80000f06:	57fd                	li	a5,-1
    80000f08:	83e9                	srli	a5,a5,0x1a
    80000f0a:	4a79                	li	s4,30
    panic("walk");

  for (int level = 2; level > 0; level--) {
    80000f0c:	4b31                	li	s6,12
  if (va >= MAXVA)
    80000f0e:	02b7fc63          	bgeu	a5,a1,80000f46 <walk+0x5a>
    panic("walk");
    80000f12:	00006517          	auipc	a0,0x6
    80000f16:	19e50513          	addi	a0,a0,414 # 800070b0 <etext+0xb0>
    80000f1a:	8bbff0ef          	jal	800007d4 <panic>
    pte_t *pte = &pagetable[PX(level, va)];
    if (*pte & PTE_V) {
      pagetable = (pagetable_t)PTE2PA(*pte);
    } else {
      if (!alloc || (pagetable = (pde_t *)kalloc()) == 0)
    80000f1e:	060a8263          	beqz	s5,80000f82 <walk+0x96>
    80000f22:	bbbff0ef          	jal	80000adc <kalloc>
    80000f26:	84aa                	mv	s1,a0
    80000f28:	c139                	beqz	a0,80000f6e <walk+0x82>
        return 0;
      memset(pagetable, 0, PGSIZE);
    80000f2a:	6605                	lui	a2,0x1
    80000f2c:	4581                	li	a1,0
    80000f2e:	d4bff0ef          	jal	80000c78 <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    80000f32:	00c4d793          	srli	a5,s1,0xc
    80000f36:	07aa                	slli	a5,a5,0xa
    80000f38:	0017e793          	ori	a5,a5,1
    80000f3c:	00f93023          	sd	a5,0(s2)
  for (int level = 2; level > 0; level--) {
    80000f40:	3a5d                	addiw	s4,s4,-9 # ffffffffffffeff7 <end+0xffffffff7ffdbb1f>
    80000f42:	036a0063          	beq	s4,s6,80000f62 <walk+0x76>
    pte_t *pte = &pagetable[PX(level, va)];
    80000f46:	0149d933          	srl	s2,s3,s4
    80000f4a:	1ff97913          	andi	s2,s2,511
    80000f4e:	090e                	slli	s2,s2,0x3
    80000f50:	9926                	add	s2,s2,s1
    if (*pte & PTE_V) {
    80000f52:	00093483          	ld	s1,0(s2)
    80000f56:	0014f793          	andi	a5,s1,1
    80000f5a:	d3f1                	beqz	a5,80000f1e <walk+0x32>
      pagetable = (pagetable_t)PTE2PA(*pte);
    80000f5c:	80a9                	srli	s1,s1,0xa
    80000f5e:	04b2                	slli	s1,s1,0xc
    80000f60:	b7c5                	j	80000f40 <walk+0x54>
    }
  }
  return &pagetable[PX(0, va)];
    80000f62:	00c9d513          	srli	a0,s3,0xc
    80000f66:	1ff57513          	andi	a0,a0,511
    80000f6a:	050e                	slli	a0,a0,0x3
    80000f6c:	9526                	add	a0,a0,s1
}
    80000f6e:	70e2                	ld	ra,56(sp)
    80000f70:	7442                	ld	s0,48(sp)
    80000f72:	74a2                	ld	s1,40(sp)
    80000f74:	7902                	ld	s2,32(sp)
    80000f76:	69e2                	ld	s3,24(sp)
    80000f78:	6a42                	ld	s4,16(sp)
    80000f7a:	6aa2                	ld	s5,8(sp)
    80000f7c:	6b02                	ld	s6,0(sp)
    80000f7e:	6121                	addi	sp,sp,64
    80000f80:	8082                	ret
        return 0;
    80000f82:	4501                	li	a0,0
    80000f84:	b7ed                	j	80000f6e <walk+0x82>

0000000080000f86 <walkaddr>:
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if (va >= MAXVA)
    80000f86:	57fd                	li	a5,-1
    80000f88:	83e9                	srli	a5,a5,0x1a
    80000f8a:	00b7f463          	bgeu	a5,a1,80000f92 <walkaddr+0xc>
    return 0;
    80000f8e:	4501                	li	a0,0
    return 0;
  if ((*pte & PTE_U) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
}
    80000f90:	8082                	ret
{
    80000f92:	1141                	addi	sp,sp,-16
    80000f94:	e406                	sd	ra,8(sp)
    80000f96:	e022                	sd	s0,0(sp)
    80000f98:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    80000f9a:	4601                	li	a2,0
    80000f9c:	f51ff0ef          	jal	80000eec <walk>
  if (pte == 0)
    80000fa0:	c105                	beqz	a0,80000fc0 <walkaddr+0x3a>
  if ((*pte & PTE_V) == 0)
    80000fa2:	611c                	ld	a5,0(a0)
  if ((*pte & PTE_U) == 0)
    80000fa4:	0117f693          	andi	a3,a5,17
    80000fa8:	4745                	li	a4,17
    return 0;
    80000faa:	4501                	li	a0,0
  if ((*pte & PTE_U) == 0)
    80000fac:	00e68663          	beq	a3,a4,80000fb8 <walkaddr+0x32>
}
    80000fb0:	60a2                	ld	ra,8(sp)
    80000fb2:	6402                	ld	s0,0(sp)
    80000fb4:	0141                	addi	sp,sp,16
    80000fb6:	8082                	ret
  pa = PTE2PA(*pte);
    80000fb8:	83a9                	srli	a5,a5,0xa
    80000fba:	00c79513          	slli	a0,a5,0xc
  return pa;
    80000fbe:	bfcd                	j	80000fb0 <walkaddr+0x2a>
    return 0;
    80000fc0:	4501                	li	a0,0
    80000fc2:	b7fd                	j	80000fb0 <walkaddr+0x2a>

0000000080000fc4 <mappages>:
// va and size MUST be page-aligned.
// Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    80000fc4:	715d                	addi	sp,sp,-80
    80000fc6:	e486                	sd	ra,72(sp)
    80000fc8:	e0a2                	sd	s0,64(sp)
    80000fca:	fc26                	sd	s1,56(sp)
    80000fcc:	f84a                	sd	s2,48(sp)
    80000fce:	f44e                	sd	s3,40(sp)
    80000fd0:	f052                	sd	s4,32(sp)
    80000fd2:	ec56                	sd	s5,24(sp)
    80000fd4:	e85a                	sd	s6,16(sp)
    80000fd6:	e45e                	sd	s7,8(sp)
    80000fd8:	0880                	addi	s0,sp,80
  uint64 a, last;
  pte_t *pte;

  if ((va % PGSIZE) != 0)
    80000fda:	03459793          	slli	a5,a1,0x34
    80000fde:	e7a9                	bnez	a5,80001028 <mappages+0x64>
    80000fe0:	8aaa                	mv	s5,a0
    80000fe2:	8b3a                	mv	s6,a4
    panic("mappages: va not aligned");

  if ((size % PGSIZE) != 0)
    80000fe4:	03461793          	slli	a5,a2,0x34
    80000fe8:	e7b1                	bnez	a5,80001034 <mappages+0x70>
    panic("mappages: size not aligned");

  if (size == 0)
    80000fea:	ca39                	beqz	a2,80001040 <mappages+0x7c>
    panic("mappages: size");

  a = va;
  last = va + size - PGSIZE;
    80000fec:	77fd                	lui	a5,0xfffff
    80000fee:	963e                	add	a2,a2,a5
    80000ff0:	00b609b3          	add	s3,a2,a1
  a = va;
    80000ff4:	892e                	mv	s2,a1
    80000ff6:	40b68a33          	sub	s4,a3,a1
    if (*pte & PTE_V)
      panic("mappages: remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if (a == last)
      break;
    a += PGSIZE;
    80000ffa:	6b85                	lui	s7,0x1
    80000ffc:	014904b3          	add	s1,s2,s4
    if ((pte = walk(pagetable, a, 1)) == 0)
    80001000:	4605                	li	a2,1
    80001002:	85ca                	mv	a1,s2
    80001004:	8556                	mv	a0,s5
    80001006:	ee7ff0ef          	jal	80000eec <walk>
    8000100a:	c539                	beqz	a0,80001058 <mappages+0x94>
    if (*pte & PTE_V)
    8000100c:	611c                	ld	a5,0(a0)
    8000100e:	8b85                	andi	a5,a5,1
    80001010:	ef95                	bnez	a5,8000104c <mappages+0x88>
    *pte = PA2PTE(pa) | perm | PTE_V;
    80001012:	80b1                	srli	s1,s1,0xc
    80001014:	04aa                	slli	s1,s1,0xa
    80001016:	0164e4b3          	or	s1,s1,s6
    8000101a:	0014e493          	ori	s1,s1,1
    8000101e:	e104                	sd	s1,0(a0)
    if (a == last)
    80001020:	05390863          	beq	s2,s3,80001070 <mappages+0xac>
    a += PGSIZE;
    80001024:	995e                	add	s2,s2,s7
    if ((pte = walk(pagetable, a, 1)) == 0)
    80001026:	bfd9                	j	80000ffc <mappages+0x38>
    panic("mappages: va not aligned");
    80001028:	00006517          	auipc	a0,0x6
    8000102c:	09050513          	addi	a0,a0,144 # 800070b8 <etext+0xb8>
    80001030:	fa4ff0ef          	jal	800007d4 <panic>
    panic("mappages: size not aligned");
    80001034:	00006517          	auipc	a0,0x6
    80001038:	0a450513          	addi	a0,a0,164 # 800070d8 <etext+0xd8>
    8000103c:	f98ff0ef          	jal	800007d4 <panic>
    panic("mappages: size");
    80001040:	00006517          	auipc	a0,0x6
    80001044:	0b850513          	addi	a0,a0,184 # 800070f8 <etext+0xf8>
    80001048:	f8cff0ef          	jal	800007d4 <panic>
      panic("mappages: remap");
    8000104c:	00006517          	auipc	a0,0x6
    80001050:	0bc50513          	addi	a0,a0,188 # 80007108 <etext+0x108>
    80001054:	f80ff0ef          	jal	800007d4 <panic>
      return -1;
    80001058:	557d                	li	a0,-1
    pa += PGSIZE;
  }
  return 0;
}
    8000105a:	60a6                	ld	ra,72(sp)
    8000105c:	6406                	ld	s0,64(sp)
    8000105e:	74e2                	ld	s1,56(sp)
    80001060:	7942                	ld	s2,48(sp)
    80001062:	79a2                	ld	s3,40(sp)
    80001064:	7a02                	ld	s4,32(sp)
    80001066:	6ae2                	ld	s5,24(sp)
    80001068:	6b42                	ld	s6,16(sp)
    8000106a:	6ba2                	ld	s7,8(sp)
    8000106c:	6161                	addi	sp,sp,80
    8000106e:	8082                	ret
  return 0;
    80001070:	4501                	li	a0,0
    80001072:	b7e5                	j	8000105a <mappages+0x96>

0000000080001074 <kvmmap>:
{
    80001074:	1141                	addi	sp,sp,-16
    80001076:	e406                	sd	ra,8(sp)
    80001078:	e022                	sd	s0,0(sp)
    8000107a:	0800                	addi	s0,sp,16
    8000107c:	87b6                	mv	a5,a3
  if (mappages(kpgtbl, va, sz, pa, perm) != 0)
    8000107e:	86b2                	mv	a3,a2
    80001080:	863e                	mv	a2,a5
    80001082:	f43ff0ef          	jal	80000fc4 <mappages>
    80001086:	e509                	bnez	a0,80001090 <kvmmap+0x1c>
}
    80001088:	60a2                	ld	ra,8(sp)
    8000108a:	6402                	ld	s0,0(sp)
    8000108c:	0141                	addi	sp,sp,16
    8000108e:	8082                	ret
    panic("kvmmap");
    80001090:	00006517          	auipc	a0,0x6
    80001094:	08850513          	addi	a0,a0,136 # 80007118 <etext+0x118>
    80001098:	f3cff0ef          	jal	800007d4 <panic>

000000008000109c <kvmmake>:
{
    8000109c:	1101                	addi	sp,sp,-32
    8000109e:	ec06                	sd	ra,24(sp)
    800010a0:	e822                	sd	s0,16(sp)
    800010a2:	e426                	sd	s1,8(sp)
    800010a4:	e04a                	sd	s2,0(sp)
    800010a6:	1000                	addi	s0,sp,32
  kpgtbl = (pagetable_t)kalloc();
    800010a8:	a35ff0ef          	jal	80000adc <kalloc>
    800010ac:	84aa                	mv	s1,a0
  memset(kpgtbl, 0, PGSIZE);
    800010ae:	6605                	lui	a2,0x1
    800010b0:	4581                	li	a1,0
    800010b2:	bc7ff0ef          	jal	80000c78 <memset>
  kvmmap(kpgtbl, UART0, UART0, PGSIZE, PTE_R | PTE_W);
    800010b6:	4719                	li	a4,6
    800010b8:	6685                	lui	a3,0x1
    800010ba:	10000637          	lui	a2,0x10000
    800010be:	100005b7          	lui	a1,0x10000
    800010c2:	8526                	mv	a0,s1
    800010c4:	fb1ff0ef          	jal	80001074 <kvmmap>
  kvmmap(kpgtbl, VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    800010c8:	4719                	li	a4,6
    800010ca:	6685                	lui	a3,0x1
    800010cc:	10001637          	lui	a2,0x10001
    800010d0:	100015b7          	lui	a1,0x10001
    800010d4:	8526                	mv	a0,s1
    800010d6:	f9fff0ef          	jal	80001074 <kvmmap>
  kvmmap(kpgtbl, PLIC, PLIC, 0x4000000, PTE_R | PTE_W);
    800010da:	4719                	li	a4,6
    800010dc:	040006b7          	lui	a3,0x4000
    800010e0:	0c000637          	lui	a2,0xc000
    800010e4:	0c0005b7          	lui	a1,0xc000
    800010e8:	8526                	mv	a0,s1
    800010ea:	f8bff0ef          	jal	80001074 <kvmmap>
  kvmmap(kpgtbl, KERNBASE, KERNBASE, (uint64)etext - KERNBASE, PTE_R | PTE_X);
    800010ee:	00006917          	auipc	s2,0x6
    800010f2:	f1290913          	addi	s2,s2,-238 # 80007000 <etext>
    800010f6:	4729                	li	a4,10
    800010f8:	80006697          	auipc	a3,0x80006
    800010fc:	f0868693          	addi	a3,a3,-248 # 7000 <_entry-0x7fff9000>
    80001100:	4605                	li	a2,1
    80001102:	067e                	slli	a2,a2,0x1f
    80001104:	85b2                	mv	a1,a2
    80001106:	8526                	mv	a0,s1
    80001108:	f6dff0ef          	jal	80001074 <kvmmap>
  kvmmap(kpgtbl, (uint64)etext, (uint64)etext, PHYSTOP - (uint64)etext,
    8000110c:	46c5                	li	a3,17
    8000110e:	06ee                	slli	a3,a3,0x1b
    80001110:	4719                	li	a4,6
    80001112:	412686b3          	sub	a3,a3,s2
    80001116:	864a                	mv	a2,s2
    80001118:	85ca                	mv	a1,s2
    8000111a:	8526                	mv	a0,s1
    8000111c:	f59ff0ef          	jal	80001074 <kvmmap>
  kvmmap(kpgtbl, TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    80001120:	4729                	li	a4,10
    80001122:	6685                	lui	a3,0x1
    80001124:	00005617          	auipc	a2,0x5
    80001128:	edc60613          	addi	a2,a2,-292 # 80006000 <_trampoline>
    8000112c:	040005b7          	lui	a1,0x4000
    80001130:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001132:	05b2                	slli	a1,a1,0xc
    80001134:	8526                	mv	a0,s1
    80001136:	f3fff0ef          	jal	80001074 <kvmmap>
  proc_mapstacks(kpgtbl);
    8000113a:	8526                	mv	a0,s1
    8000113c:	5ee000ef          	jal	8000172a <proc_mapstacks>
}
    80001140:	8526                	mv	a0,s1
    80001142:	60e2                	ld	ra,24(sp)
    80001144:	6442                	ld	s0,16(sp)
    80001146:	64a2                	ld	s1,8(sp)
    80001148:	6902                	ld	s2,0(sp)
    8000114a:	6105                	addi	sp,sp,32
    8000114c:	8082                	ret

000000008000114e <kvminit>:
{
    8000114e:	1141                	addi	sp,sp,-16
    80001150:	e406                	sd	ra,8(sp)
    80001152:	e022                	sd	s0,0(sp)
    80001154:	0800                	addi	s0,sp,16
  kernel_pagetable = kvmmake();
    80001156:	f47ff0ef          	jal	8000109c <kvmmake>
    8000115a:	00009797          	auipc	a5,0x9
    8000115e:	04a7bf23          	sd	a0,94(a5) # 8000a1b8 <kernel_pagetable>
}
    80001162:	60a2                	ld	ra,8(sp)
    80001164:	6402                	ld	s0,0(sp)
    80001166:	0141                	addi	sp,sp,16
    80001168:	8082                	ret

000000008000116a <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    8000116a:	1101                	addi	sp,sp,-32
    8000116c:	ec06                	sd	ra,24(sp)
    8000116e:	e822                	sd	s0,16(sp)
    80001170:	e426                	sd	s1,8(sp)
    80001172:	1000                	addi	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t)kalloc();
    80001174:	969ff0ef          	jal	80000adc <kalloc>
    80001178:	84aa                	mv	s1,a0
  if (pagetable == 0)
    8000117a:	c509                	beqz	a0,80001184 <uvmcreate+0x1a>
    return 0;
  memset(pagetable, 0, PGSIZE);
    8000117c:	6605                	lui	a2,0x1
    8000117e:	4581                	li	a1,0
    80001180:	af9ff0ef          	jal	80000c78 <memset>
  return pagetable;
}
    80001184:	8526                	mv	a0,s1
    80001186:	60e2                	ld	ra,24(sp)
    80001188:	6442                	ld	s0,16(sp)
    8000118a:	64a2                	ld	s1,8(sp)
    8000118c:	6105                	addi	sp,sp,32
    8000118e:	8082                	ret

0000000080001190 <uvmunmap>:
// Remove npages of mappings starting from va. va must be
// page-aligned. It's OK if the mappings don't exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    80001190:	7139                	addi	sp,sp,-64
    80001192:	fc06                	sd	ra,56(sp)
    80001194:	f822                	sd	s0,48(sp)
    80001196:	0080                	addi	s0,sp,64
  uint64 a;
  pte_t *pte;

  if ((va % PGSIZE) != 0)
    80001198:	03459793          	slli	a5,a1,0x34
    8000119c:	e38d                	bnez	a5,800011be <uvmunmap+0x2e>
    8000119e:	f04a                	sd	s2,32(sp)
    800011a0:	ec4e                	sd	s3,24(sp)
    800011a2:	e852                	sd	s4,16(sp)
    800011a4:	e456                	sd	s5,8(sp)
    800011a6:	e05a                	sd	s6,0(sp)
    800011a8:	8a2a                	mv	s4,a0
    800011aa:	892e                	mv	s2,a1
    800011ac:	8ab6                	mv	s5,a3
    panic("uvmunmap: not aligned");

  for (a = va; a < va + npages * PGSIZE; a += PGSIZE) {
    800011ae:	0632                	slli	a2,a2,0xc
    800011b0:	00b609b3          	add	s3,a2,a1
    800011b4:	6b05                	lui	s6,0x1
    800011b6:	0535f963          	bgeu	a1,s3,80001208 <uvmunmap+0x78>
    800011ba:	f426                	sd	s1,40(sp)
    800011bc:	a015                	j	800011e0 <uvmunmap+0x50>
    800011be:	f426                	sd	s1,40(sp)
    800011c0:	f04a                	sd	s2,32(sp)
    800011c2:	ec4e                	sd	s3,24(sp)
    800011c4:	e852                	sd	s4,16(sp)
    800011c6:	e456                	sd	s5,8(sp)
    800011c8:	e05a                	sd	s6,0(sp)
    panic("uvmunmap: not aligned");
    800011ca:	00006517          	auipc	a0,0x6
    800011ce:	f5650513          	addi	a0,a0,-170 # 80007120 <etext+0x120>
    800011d2:	e02ff0ef          	jal	800007d4 <panic>
      continue;
    if (do_free) {
      uint64 pa = PTE2PA(*pte);
      kfree((void *)pa);
    }
    *pte = 0;
    800011d6:	0004b023          	sd	zero,0(s1)
  for (a = va; a < va + npages * PGSIZE; a += PGSIZE) {
    800011da:	995a                	add	s2,s2,s6
    800011dc:	03397563          	bgeu	s2,s3,80001206 <uvmunmap+0x76>
    if ((pte = walk(pagetable, a, 0)) == 0) // leaf page table entry allocated?
    800011e0:	4601                	li	a2,0
    800011e2:	85ca                	mv	a1,s2
    800011e4:	8552                	mv	a0,s4
    800011e6:	d07ff0ef          	jal	80000eec <walk>
    800011ea:	84aa                	mv	s1,a0
    800011ec:	d57d                	beqz	a0,800011da <uvmunmap+0x4a>
    if ((*pte & PTE_V) == 0) // has physical page been allocated?
    800011ee:	611c                	ld	a5,0(a0)
    800011f0:	0017f713          	andi	a4,a5,1
    800011f4:	d37d                	beqz	a4,800011da <uvmunmap+0x4a>
    if (do_free) {
    800011f6:	fe0a80e3          	beqz	s5,800011d6 <uvmunmap+0x46>
      uint64 pa = PTE2PA(*pte);
    800011fa:	83a9                	srli	a5,a5,0xa
      kfree((void *)pa);
    800011fc:	00c79513          	slli	a0,a5,0xc
    80001200:	ffaff0ef          	jal	800009fa <kfree>
    80001204:	bfc9                	j	800011d6 <uvmunmap+0x46>
    80001206:	74a2                	ld	s1,40(sp)
    80001208:	7902                	ld	s2,32(sp)
    8000120a:	69e2                	ld	s3,24(sp)
    8000120c:	6a42                	ld	s4,16(sp)
    8000120e:	6aa2                	ld	s5,8(sp)
    80001210:	6b02                	ld	s6,0(sp)
  }
}
    80001212:	70e2                	ld	ra,56(sp)
    80001214:	7442                	ld	s0,48(sp)
    80001216:	6121                	addi	sp,sp,64
    80001218:	8082                	ret

000000008000121a <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    8000121a:	1101                	addi	sp,sp,-32
    8000121c:	ec06                	sd	ra,24(sp)
    8000121e:	e822                	sd	s0,16(sp)
    80001220:	e426                	sd	s1,8(sp)
    80001222:	1000                	addi	s0,sp,32
  if (newsz >= oldsz)
    return oldsz;
    80001224:	84ae                	mv	s1,a1
  if (newsz >= oldsz)
    80001226:	00b67d63          	bgeu	a2,a1,80001240 <uvmdealloc+0x26>
    8000122a:	84b2                	mv	s1,a2

  if (PGROUNDUP(newsz) < PGROUNDUP(oldsz)) {
    8000122c:	6785                	lui	a5,0x1
    8000122e:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80001230:	00f60733          	add	a4,a2,a5
    80001234:	76fd                	lui	a3,0xfffff
    80001236:	8f75                	and	a4,a4,a3
    80001238:	97ae                	add	a5,a5,a1
    8000123a:	8ff5                	and	a5,a5,a3
    8000123c:	00f76863          	bltu	a4,a5,8000124c <uvmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}
    80001240:	8526                	mv	a0,s1
    80001242:	60e2                	ld	ra,24(sp)
    80001244:	6442                	ld	s0,16(sp)
    80001246:	64a2                	ld	s1,8(sp)
    80001248:	6105                	addi	sp,sp,32
    8000124a:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    8000124c:	8f99                	sub	a5,a5,a4
    8000124e:	83b1                	srli	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    80001250:	4685                	li	a3,1
    80001252:	0007861b          	sext.w	a2,a5
    80001256:	85ba                	mv	a1,a4
    80001258:	f39ff0ef          	jal	80001190 <uvmunmap>
    8000125c:	b7d5                	j	80001240 <uvmdealloc+0x26>

000000008000125e <uvmalloc>:
  if (newsz < oldsz)
    8000125e:	08b66f63          	bltu	a2,a1,800012fc <uvmalloc+0x9e>
{
    80001262:	7139                	addi	sp,sp,-64
    80001264:	fc06                	sd	ra,56(sp)
    80001266:	f822                	sd	s0,48(sp)
    80001268:	ec4e                	sd	s3,24(sp)
    8000126a:	e852                	sd	s4,16(sp)
    8000126c:	e456                	sd	s5,8(sp)
    8000126e:	0080                	addi	s0,sp,64
    80001270:	8aaa                	mv	s5,a0
    80001272:	8a32                	mv	s4,a2
  oldsz = PGROUNDUP(oldsz);
    80001274:	6785                	lui	a5,0x1
    80001276:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80001278:	95be                	add	a1,a1,a5
    8000127a:	77fd                	lui	a5,0xfffff
    8000127c:	00f5f9b3          	and	s3,a1,a5
  for (a = oldsz; a < newsz; a += PGSIZE) {
    80001280:	08c9f063          	bgeu	s3,a2,80001300 <uvmalloc+0xa2>
    80001284:	f426                	sd	s1,40(sp)
    80001286:	f04a                	sd	s2,32(sp)
    80001288:	e05a                	sd	s6,0(sp)
    8000128a:	894e                	mv	s2,s3
    if (mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R | PTE_U | xperm) !=
    8000128c:	0126eb13          	ori	s6,a3,18
    mem = kalloc();
    80001290:	84dff0ef          	jal	80000adc <kalloc>
    80001294:	84aa                	mv	s1,a0
    if (mem == 0) {
    80001296:	c515                	beqz	a0,800012c2 <uvmalloc+0x64>
    memset(mem, 0, PGSIZE);
    80001298:	6605                	lui	a2,0x1
    8000129a:	4581                	li	a1,0
    8000129c:	9ddff0ef          	jal	80000c78 <memset>
    if (mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R | PTE_U | xperm) !=
    800012a0:	875a                	mv	a4,s6
    800012a2:	86a6                	mv	a3,s1
    800012a4:	6605                	lui	a2,0x1
    800012a6:	85ca                	mv	a1,s2
    800012a8:	8556                	mv	a0,s5
    800012aa:	d1bff0ef          	jal	80000fc4 <mappages>
    800012ae:	e915                	bnez	a0,800012e2 <uvmalloc+0x84>
  for (a = oldsz; a < newsz; a += PGSIZE) {
    800012b0:	6785                	lui	a5,0x1
    800012b2:	993e                	add	s2,s2,a5
    800012b4:	fd496ee3          	bltu	s2,s4,80001290 <uvmalloc+0x32>
  return newsz;
    800012b8:	8552                	mv	a0,s4
    800012ba:	74a2                	ld	s1,40(sp)
    800012bc:	7902                	ld	s2,32(sp)
    800012be:	6b02                	ld	s6,0(sp)
    800012c0:	a811                	j	800012d4 <uvmalloc+0x76>
      uvmdealloc(pagetable, a, oldsz);
    800012c2:	864e                	mv	a2,s3
    800012c4:	85ca                	mv	a1,s2
    800012c6:	8556                	mv	a0,s5
    800012c8:	f53ff0ef          	jal	8000121a <uvmdealloc>
      return 0;
    800012cc:	4501                	li	a0,0
    800012ce:	74a2                	ld	s1,40(sp)
    800012d0:	7902                	ld	s2,32(sp)
    800012d2:	6b02                	ld	s6,0(sp)
}
    800012d4:	70e2                	ld	ra,56(sp)
    800012d6:	7442                	ld	s0,48(sp)
    800012d8:	69e2                	ld	s3,24(sp)
    800012da:	6a42                	ld	s4,16(sp)
    800012dc:	6aa2                	ld	s5,8(sp)
    800012de:	6121                	addi	sp,sp,64
    800012e0:	8082                	ret
      kfree(mem);
    800012e2:	8526                	mv	a0,s1
    800012e4:	f16ff0ef          	jal	800009fa <kfree>
      uvmdealloc(pagetable, a, oldsz);
    800012e8:	864e                	mv	a2,s3
    800012ea:	85ca                	mv	a1,s2
    800012ec:	8556                	mv	a0,s5
    800012ee:	f2dff0ef          	jal	8000121a <uvmdealloc>
      return 0;
    800012f2:	4501                	li	a0,0
    800012f4:	74a2                	ld	s1,40(sp)
    800012f6:	7902                	ld	s2,32(sp)
    800012f8:	6b02                	ld	s6,0(sp)
    800012fa:	bfe9                	j	800012d4 <uvmalloc+0x76>
    return oldsz;
    800012fc:	852e                	mv	a0,a1
}
    800012fe:	8082                	ret
  return newsz;
    80001300:	8532                	mv	a0,a2
    80001302:	bfc9                	j	800012d4 <uvmalloc+0x76>

0000000080001304 <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
    80001304:	7179                	addi	sp,sp,-48
    80001306:	f406                	sd	ra,40(sp)
    80001308:	f022                	sd	s0,32(sp)
    8000130a:	ec26                	sd	s1,24(sp)
    8000130c:	e84a                	sd	s2,16(sp)
    8000130e:	e44e                	sd	s3,8(sp)
    80001310:	e052                	sd	s4,0(sp)
    80001312:	1800                	addi	s0,sp,48
    80001314:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for (int i = 0; i < 512; i++) {
    80001316:	84aa                	mv	s1,a0
    80001318:	6905                	lui	s2,0x1
    8000131a:	992a                	add	s2,s2,a0
    pte_t pte = pagetable[i];
    if ((pte & PTE_V) && (pte & (PTE_R | PTE_W | PTE_X)) == 0) {
    8000131c:	4985                	li	s3,1
    8000131e:	a819                	j	80001334 <freewalk+0x30>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    80001320:	83a9                	srli	a5,a5,0xa
      freewalk((pagetable_t)child);
    80001322:	00c79513          	slli	a0,a5,0xc
    80001326:	fdfff0ef          	jal	80001304 <freewalk>
      pagetable[i] = 0;
    8000132a:	0004b023          	sd	zero,0(s1)
  for (int i = 0; i < 512; i++) {
    8000132e:	04a1                	addi	s1,s1,8
    80001330:	01248f63          	beq	s1,s2,8000134e <freewalk+0x4a>
    pte_t pte = pagetable[i];
    80001334:	609c                	ld	a5,0(s1)
    if ((pte & PTE_V) && (pte & (PTE_R | PTE_W | PTE_X)) == 0) {
    80001336:	00f7f713          	andi	a4,a5,15
    8000133a:	ff3703e3          	beq	a4,s3,80001320 <freewalk+0x1c>
    } else if (pte & PTE_V) {
    8000133e:	8b85                	andi	a5,a5,1
    80001340:	d7fd                	beqz	a5,8000132e <freewalk+0x2a>
      panic("freewalk: leaf");
    80001342:	00006517          	auipc	a0,0x6
    80001346:	df650513          	addi	a0,a0,-522 # 80007138 <etext+0x138>
    8000134a:	c8aff0ef          	jal	800007d4 <panic>
    }
  }
  kfree((void *)pagetable);
    8000134e:	8552                	mv	a0,s4
    80001350:	eaaff0ef          	jal	800009fa <kfree>
}
    80001354:	70a2                	ld	ra,40(sp)
    80001356:	7402                	ld	s0,32(sp)
    80001358:	64e2                	ld	s1,24(sp)
    8000135a:	6942                	ld	s2,16(sp)
    8000135c:	69a2                	ld	s3,8(sp)
    8000135e:	6a02                	ld	s4,0(sp)
    80001360:	6145                	addi	sp,sp,48
    80001362:	8082                	ret

0000000080001364 <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    80001364:	1101                	addi	sp,sp,-32
    80001366:	ec06                	sd	ra,24(sp)
    80001368:	e822                	sd	s0,16(sp)
    8000136a:	e426                	sd	s1,8(sp)
    8000136c:	1000                	addi	s0,sp,32
    8000136e:	84aa                	mv	s1,a0
  if (sz > 0)
    80001370:	e989                	bnez	a1,80001382 <uvmfree+0x1e>
    uvmunmap(pagetable, 0, PGROUNDUP(sz) / PGSIZE, 1);
  freewalk(pagetable);
    80001372:	8526                	mv	a0,s1
    80001374:	f91ff0ef          	jal	80001304 <freewalk>
}
    80001378:	60e2                	ld	ra,24(sp)
    8000137a:	6442                	ld	s0,16(sp)
    8000137c:	64a2                	ld	s1,8(sp)
    8000137e:	6105                	addi	sp,sp,32
    80001380:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz) / PGSIZE, 1);
    80001382:	6785                	lui	a5,0x1
    80001384:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80001386:	95be                	add	a1,a1,a5
    80001388:	4685                	li	a3,1
    8000138a:	00c5d613          	srli	a2,a1,0xc
    8000138e:	4581                	li	a1,0
    80001390:	e01ff0ef          	jal	80001190 <uvmunmap>
    80001394:	bff9                	j	80001372 <uvmfree+0xe>

0000000080001396 <uvmcopy>:
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  char *mem;

  for (i = 0; i < sz; i += PGSIZE) {
    80001396:	ce49                	beqz	a2,80001430 <uvmcopy+0x9a>
{
    80001398:	715d                	addi	sp,sp,-80
    8000139a:	e486                	sd	ra,72(sp)
    8000139c:	e0a2                	sd	s0,64(sp)
    8000139e:	fc26                	sd	s1,56(sp)
    800013a0:	f84a                	sd	s2,48(sp)
    800013a2:	f44e                	sd	s3,40(sp)
    800013a4:	f052                	sd	s4,32(sp)
    800013a6:	ec56                	sd	s5,24(sp)
    800013a8:	e85a                	sd	s6,16(sp)
    800013aa:	e45e                	sd	s7,8(sp)
    800013ac:	0880                	addi	s0,sp,80
    800013ae:	8aaa                	mv	s5,a0
    800013b0:	8b2e                	mv	s6,a1
    800013b2:	8a32                	mv	s4,a2
  for (i = 0; i < sz; i += PGSIZE) {
    800013b4:	4481                	li	s1,0
    800013b6:	a029                	j	800013c0 <uvmcopy+0x2a>
    800013b8:	6785                	lui	a5,0x1
    800013ba:	94be                	add	s1,s1,a5
    800013bc:	0544fe63          	bgeu	s1,s4,80001418 <uvmcopy+0x82>
    if ((pte = walk(old, i, 0)) == 0)
    800013c0:	4601                	li	a2,0
    800013c2:	85a6                	mv	a1,s1
    800013c4:	8556                	mv	a0,s5
    800013c6:	b27ff0ef          	jal	80000eec <walk>
    800013ca:	d57d                	beqz	a0,800013b8 <uvmcopy+0x22>
      continue; // page table entry hasn't been allocated
    if ((*pte & PTE_V) == 0)
    800013cc:	6118                	ld	a4,0(a0)
    800013ce:	00177793          	andi	a5,a4,1
    800013d2:	d3fd                	beqz	a5,800013b8 <uvmcopy+0x22>
      continue; // physical page hasn't been allocated
    pa = PTE2PA(*pte);
    800013d4:	00a75593          	srli	a1,a4,0xa
    800013d8:	00c59b93          	slli	s7,a1,0xc
    flags = PTE_FLAGS(*pte);
    800013dc:	3ff77913          	andi	s2,a4,1023
    if ((mem = kalloc()) == 0)
    800013e0:	efcff0ef          	jal	80000adc <kalloc>
    800013e4:	89aa                	mv	s3,a0
    800013e6:	c105                	beqz	a0,80001406 <uvmcopy+0x70>
      goto err;
    memmove(mem, (char *)pa, PGSIZE);
    800013e8:	6605                	lui	a2,0x1
    800013ea:	85de                	mv	a1,s7
    800013ec:	8e9ff0ef          	jal	80000cd4 <memmove>
    if (mappages(new, i, PGSIZE, (uint64)mem, flags) != 0) {
    800013f0:	874a                	mv	a4,s2
    800013f2:	86ce                	mv	a3,s3
    800013f4:	6605                	lui	a2,0x1
    800013f6:	85a6                	mv	a1,s1
    800013f8:	855a                	mv	a0,s6
    800013fa:	bcbff0ef          	jal	80000fc4 <mappages>
    800013fe:	dd4d                	beqz	a0,800013b8 <uvmcopy+0x22>
      kfree(mem);
    80001400:	854e                	mv	a0,s3
    80001402:	df8ff0ef          	jal	800009fa <kfree>
    }
  }
  return 0;

err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    80001406:	4685                	li	a3,1
    80001408:	00c4d613          	srli	a2,s1,0xc
    8000140c:	4581                	li	a1,0
    8000140e:	855a                	mv	a0,s6
    80001410:	d81ff0ef          	jal	80001190 <uvmunmap>
  return -1;
    80001414:	557d                	li	a0,-1
    80001416:	a011                	j	8000141a <uvmcopy+0x84>
  return 0;
    80001418:	4501                	li	a0,0
}
    8000141a:	60a6                	ld	ra,72(sp)
    8000141c:	6406                	ld	s0,64(sp)
    8000141e:	74e2                	ld	s1,56(sp)
    80001420:	7942                	ld	s2,48(sp)
    80001422:	79a2                	ld	s3,40(sp)
    80001424:	7a02                	ld	s4,32(sp)
    80001426:	6ae2                	ld	s5,24(sp)
    80001428:	6b42                	ld	s6,16(sp)
    8000142a:	6ba2                	ld	s7,8(sp)
    8000142c:	6161                	addi	sp,sp,80
    8000142e:	8082                	ret
  return 0;
    80001430:	4501                	li	a0,0
}
    80001432:	8082                	ret

0000000080001434 <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    80001434:	1141                	addi	sp,sp,-16
    80001436:	e406                	sd	ra,8(sp)
    80001438:	e022                	sd	s0,0(sp)
    8000143a:	0800                	addi	s0,sp,16
  pte_t *pte;

  pte = walk(pagetable, va, 0);
    8000143c:	4601                	li	a2,0
    8000143e:	aafff0ef          	jal	80000eec <walk>
  if (pte == 0)
    80001442:	c901                	beqz	a0,80001452 <uvmclear+0x1e>
    panic("uvmclear");
  *pte &= ~PTE_U;
    80001444:	611c                	ld	a5,0(a0)
    80001446:	9bbd                	andi	a5,a5,-17
    80001448:	e11c                	sd	a5,0(a0)
}
    8000144a:	60a2                	ld	ra,8(sp)
    8000144c:	6402                	ld	s0,0(sp)
    8000144e:	0141                	addi	sp,sp,16
    80001450:	8082                	ret
    panic("uvmclear");
    80001452:	00006517          	auipc	a0,0x6
    80001456:	cf650513          	addi	a0,a0,-778 # 80007148 <etext+0x148>
    8000145a:	b7aff0ef          	jal	800007d4 <panic>

000000008000145e <copyinstr>:
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while (got_null == 0 && max > 0) {
    8000145e:	c6dd                	beqz	a3,8000150c <copyinstr+0xae>
{
    80001460:	715d                	addi	sp,sp,-80
    80001462:	e486                	sd	ra,72(sp)
    80001464:	e0a2                	sd	s0,64(sp)
    80001466:	fc26                	sd	s1,56(sp)
    80001468:	f84a                	sd	s2,48(sp)
    8000146a:	f44e                	sd	s3,40(sp)
    8000146c:	f052                	sd	s4,32(sp)
    8000146e:	ec56                	sd	s5,24(sp)
    80001470:	e85a                	sd	s6,16(sp)
    80001472:	e45e                	sd	s7,8(sp)
    80001474:	0880                	addi	s0,sp,80
    80001476:	8a2a                	mv	s4,a0
    80001478:	8b2e                	mv	s6,a1
    8000147a:	8bb2                	mv	s7,a2
    8000147c:	8936                	mv	s2,a3
    va0 = PGROUNDDOWN(srcva);
    8000147e:	7afd                	lui	s5,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if (pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    80001480:	6985                	lui	s3,0x1
    80001482:	a825                	j	800014ba <copyinstr+0x5c>
      n = max;

    char *p = (char *)(pa0 + (srcva - va0));
    while (n > 0) {
      if (*p == '\0') {
        *dst = '\0';
    80001484:	00078023          	sb	zero,0(a5) # 1000 <_entry-0x7ffff000>
    80001488:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if (got_null) {
    8000148a:	37fd                	addiw	a5,a5,-1
    8000148c:	0007851b          	sext.w	a0,a5
    return 0;
  } else {
    return -1;
  }
}
    80001490:	60a6                	ld	ra,72(sp)
    80001492:	6406                	ld	s0,64(sp)
    80001494:	74e2                	ld	s1,56(sp)
    80001496:	7942                	ld	s2,48(sp)
    80001498:	79a2                	ld	s3,40(sp)
    8000149a:	7a02                	ld	s4,32(sp)
    8000149c:	6ae2                	ld	s5,24(sp)
    8000149e:	6b42                	ld	s6,16(sp)
    800014a0:	6ba2                	ld	s7,8(sp)
    800014a2:	6161                	addi	sp,sp,80
    800014a4:	8082                	ret
    800014a6:	fff90713          	addi	a4,s2,-1 # fff <_entry-0x7ffff001>
    800014aa:	9742                	add	a4,a4,a6
      --max;
    800014ac:	40b70933          	sub	s2,a4,a1
    srcva = va0 + PGSIZE;
    800014b0:	01348bb3          	add	s7,s1,s3
  while (got_null == 0 && max > 0) {
    800014b4:	04e58463          	beq	a1,a4,800014fc <copyinstr+0x9e>
{
    800014b8:	8b3e                	mv	s6,a5
    va0 = PGROUNDDOWN(srcva);
    800014ba:	015bf4b3          	and	s1,s7,s5
    pa0 = walkaddr(pagetable, va0);
    800014be:	85a6                	mv	a1,s1
    800014c0:	8552                	mv	a0,s4
    800014c2:	ac5ff0ef          	jal	80000f86 <walkaddr>
    if (pa0 == 0)
    800014c6:	cd0d                	beqz	a0,80001500 <copyinstr+0xa2>
    n = PGSIZE - (srcva - va0);
    800014c8:	417486b3          	sub	a3,s1,s7
    800014cc:	96ce                	add	a3,a3,s3
    if (n > max)
    800014ce:	00d97363          	bgeu	s2,a3,800014d4 <copyinstr+0x76>
    800014d2:	86ca                	mv	a3,s2
    char *p = (char *)(pa0 + (srcva - va0));
    800014d4:	955e                	add	a0,a0,s7
    800014d6:	8d05                	sub	a0,a0,s1
    while (n > 0) {
    800014d8:	c695                	beqz	a3,80001504 <copyinstr+0xa6>
    800014da:	87da                	mv	a5,s6
    800014dc:	885a                	mv	a6,s6
      if (*p == '\0') {
    800014de:	41650633          	sub	a2,a0,s6
    while (n > 0) {
    800014e2:	96da                	add	a3,a3,s6
    800014e4:	85be                	mv	a1,a5
      if (*p == '\0') {
    800014e6:	00f60733          	add	a4,a2,a5
    800014ea:	00074703          	lbu	a4,0(a4)
    800014ee:	db59                	beqz	a4,80001484 <copyinstr+0x26>
        *dst = *p;
    800014f0:	00e78023          	sb	a4,0(a5)
      dst++;
    800014f4:	0785                	addi	a5,a5,1
    while (n > 0) {
    800014f6:	fed797e3          	bne	a5,a3,800014e4 <copyinstr+0x86>
    800014fa:	b775                	j	800014a6 <copyinstr+0x48>
    800014fc:	4781                	li	a5,0
    800014fe:	b771                	j	8000148a <copyinstr+0x2c>
      return -1;
    80001500:	557d                	li	a0,-1
    80001502:	b779                	j	80001490 <copyinstr+0x32>
    srcva = va0 + PGSIZE;
    80001504:	6b85                	lui	s7,0x1
    80001506:	9ba6                	add	s7,s7,s1
    80001508:	87da                	mv	a5,s6
    8000150a:	b77d                	j	800014b8 <copyinstr+0x5a>
  int got_null = 0;
    8000150c:	4781                	li	a5,0
  if (got_null) {
    8000150e:	37fd                	addiw	a5,a5,-1
    80001510:	0007851b          	sext.w	a0,a5
}
    80001514:	8082                	ret

0000000080001516 <ismapped>:
  return mem;
}

int
ismapped(pagetable_t pagetable, uint64 va)
{
    80001516:	1141                	addi	sp,sp,-16
    80001518:	e406                	sd	ra,8(sp)
    8000151a:	e022                	sd	s0,0(sp)
    8000151c:	0800                	addi	s0,sp,16
  pte_t *pte = walk(pagetable, va, 0);
    8000151e:	4601                	li	a2,0
    80001520:	9cdff0ef          	jal	80000eec <walk>
  if (pte == 0) {
    80001524:	c519                	beqz	a0,80001532 <ismapped+0x1c>
    return 0;
  }
  if (*pte & PTE_V) {
    80001526:	6108                	ld	a0,0(a0)
    80001528:	8905                	andi	a0,a0,1
    return 1;
  }
  return 0;
}
    8000152a:	60a2                	ld	ra,8(sp)
    8000152c:	6402                	ld	s0,0(sp)
    8000152e:	0141                	addi	sp,sp,16
    80001530:	8082                	ret
    return 0;
    80001532:	4501                	li	a0,0
    80001534:	bfdd                	j	8000152a <ismapped+0x14>

0000000080001536 <vmfault>:
{
    80001536:	7179                	addi	sp,sp,-48
    80001538:	f406                	sd	ra,40(sp)
    8000153a:	f022                	sd	s0,32(sp)
    8000153c:	ec26                	sd	s1,24(sp)
    8000153e:	e44e                	sd	s3,8(sp)
    80001540:	1800                	addi	s0,sp,48
    80001542:	89aa                	mv	s3,a0
    80001544:	84ae                	mv	s1,a1
  struct proc *p = myproc();
    80001546:	35e000ef          	jal	800018a4 <myproc>
  if (va >= p->sz)
    8000154a:	653c                	ld	a5,72(a0)
    8000154c:	00f4ea63          	bltu	s1,a5,80001560 <vmfault+0x2a>
    return 0;
    80001550:	4981                	li	s3,0
}
    80001552:	854e                	mv	a0,s3
    80001554:	70a2                	ld	ra,40(sp)
    80001556:	7402                	ld	s0,32(sp)
    80001558:	64e2                	ld	s1,24(sp)
    8000155a:	69a2                	ld	s3,8(sp)
    8000155c:	6145                	addi	sp,sp,48
    8000155e:	8082                	ret
    80001560:	e84a                	sd	s2,16(sp)
    80001562:	892a                	mv	s2,a0
  va = PGROUNDDOWN(va);
    80001564:	77fd                	lui	a5,0xfffff
    80001566:	8cfd                	and	s1,s1,a5
  if (ismapped(pagetable, va)) {
    80001568:	85a6                	mv	a1,s1
    8000156a:	854e                	mv	a0,s3
    8000156c:	fabff0ef          	jal	80001516 <ismapped>
    return 0;
    80001570:	4981                	li	s3,0
  if (ismapped(pagetable, va)) {
    80001572:	c119                	beqz	a0,80001578 <vmfault+0x42>
    80001574:	6942                	ld	s2,16(sp)
    80001576:	bff1                	j	80001552 <vmfault+0x1c>
    80001578:	e052                	sd	s4,0(sp)
  mem = (uint64)kalloc();
    8000157a:	d62ff0ef          	jal	80000adc <kalloc>
    8000157e:	8a2a                	mv	s4,a0
  if (mem == 0)
    80001580:	c90d                	beqz	a0,800015b2 <vmfault+0x7c>
  mem = (uint64)kalloc();
    80001582:	89aa                	mv	s3,a0
  memset((void *)mem, 0, PGSIZE);
    80001584:	6605                	lui	a2,0x1
    80001586:	4581                	li	a1,0
    80001588:	ef0ff0ef          	jal	80000c78 <memset>
  if (mappages(p->pagetable, va, PGSIZE, mem, PTE_W | PTE_U | PTE_R) != 0) {
    8000158c:	4759                	li	a4,22
    8000158e:	86d2                	mv	a3,s4
    80001590:	6605                	lui	a2,0x1
    80001592:	85a6                	mv	a1,s1
    80001594:	05093503          	ld	a0,80(s2)
    80001598:	a2dff0ef          	jal	80000fc4 <mappages>
    8000159c:	e501                	bnez	a0,800015a4 <vmfault+0x6e>
    8000159e:	6942                	ld	s2,16(sp)
    800015a0:	6a02                	ld	s4,0(sp)
    800015a2:	bf45                	j	80001552 <vmfault+0x1c>
    kfree((void *)mem);
    800015a4:	8552                	mv	a0,s4
    800015a6:	c54ff0ef          	jal	800009fa <kfree>
    return 0;
    800015aa:	4981                	li	s3,0
    800015ac:	6942                	ld	s2,16(sp)
    800015ae:	6a02                	ld	s4,0(sp)
    800015b0:	b74d                	j	80001552 <vmfault+0x1c>
    800015b2:	6942                	ld	s2,16(sp)
    800015b4:	6a02                	ld	s4,0(sp)
    800015b6:	bf71                	j	80001552 <vmfault+0x1c>

00000000800015b8 <copyout>:
  while (len > 0) {
    800015b8:	c2cd                	beqz	a3,8000165a <copyout+0xa2>
{
    800015ba:	711d                	addi	sp,sp,-96
    800015bc:	ec86                	sd	ra,88(sp)
    800015be:	e8a2                	sd	s0,80(sp)
    800015c0:	e4a6                	sd	s1,72(sp)
    800015c2:	f852                	sd	s4,48(sp)
    800015c4:	f05a                	sd	s6,32(sp)
    800015c6:	ec5e                	sd	s7,24(sp)
    800015c8:	e862                	sd	s8,16(sp)
    800015ca:	1080                	addi	s0,sp,96
    800015cc:	8c2a                	mv	s8,a0
    800015ce:	8b2e                	mv	s6,a1
    800015d0:	8bb2                	mv	s7,a2
    800015d2:	8a36                	mv	s4,a3
    va0 = PGROUNDDOWN(dstva);
    800015d4:	74fd                	lui	s1,0xfffff
    800015d6:	8ced                	and	s1,s1,a1
    if (va0 >= MAXVA)
    800015d8:	57fd                	li	a5,-1
    800015da:	83e9                	srli	a5,a5,0x1a
    800015dc:	0897e163          	bltu	a5,s1,8000165e <copyout+0xa6>
    800015e0:	e0ca                	sd	s2,64(sp)
    800015e2:	fc4e                	sd	s3,56(sp)
    800015e4:	f456                	sd	s5,40(sp)
    800015e6:	e466                	sd	s9,8(sp)
    800015e8:	e06a                	sd	s10,0(sp)
    800015ea:	6d05                	lui	s10,0x1
    800015ec:	8cbe                	mv	s9,a5
    800015ee:	a015                	j	80001612 <copyout+0x5a>
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    800015f0:	409b0533          	sub	a0,s6,s1
    800015f4:	0009861b          	sext.w	a2,s3
    800015f8:	85de                	mv	a1,s7
    800015fa:	954a                	add	a0,a0,s2
    800015fc:	ed8ff0ef          	jal	80000cd4 <memmove>
    len -= n;
    80001600:	413a0a33          	sub	s4,s4,s3
    src += n;
    80001604:	9bce                	add	s7,s7,s3
  while (len > 0) {
    80001606:	040a0363          	beqz	s4,8000164c <copyout+0x94>
    if (va0 >= MAXVA)
    8000160a:	055cec63          	bltu	s9,s5,80001662 <copyout+0xaa>
    8000160e:	84d6                	mv	s1,s5
    80001610:	8b56                	mv	s6,s5
    pa0 = walkaddr(pagetable, va0);
    80001612:	85a6                	mv	a1,s1
    80001614:	8562                	mv	a0,s8
    80001616:	971ff0ef          	jal	80000f86 <walkaddr>
    8000161a:	892a                	mv	s2,a0
    if (pa0 == 0) {
    8000161c:	e901                	bnez	a0,8000162c <copyout+0x74>
      if ((pa0 = vmfault(pagetable, va0, 0)) == 0) {
    8000161e:	4601                	li	a2,0
    80001620:	85a6                	mv	a1,s1
    80001622:	8562                	mv	a0,s8
    80001624:	f13ff0ef          	jal	80001536 <vmfault>
    80001628:	892a                	mv	s2,a0
    8000162a:	c139                	beqz	a0,80001670 <copyout+0xb8>
    pte = walk(pagetable, va0, 0);
    8000162c:	4601                	li	a2,0
    8000162e:	85a6                	mv	a1,s1
    80001630:	8562                	mv	a0,s8
    80001632:	8bbff0ef          	jal	80000eec <walk>
    if ((*pte & PTE_W) == 0)
    80001636:	611c                	ld	a5,0(a0)
    80001638:	8b91                	andi	a5,a5,4
    8000163a:	c3b1                	beqz	a5,8000167e <copyout+0xc6>
    n = PGSIZE - (dstva - va0);
    8000163c:	01a48ab3          	add	s5,s1,s10
    80001640:	416a89b3          	sub	s3,s5,s6
    if (n > len)
    80001644:	fb3a76e3          	bgeu	s4,s3,800015f0 <copyout+0x38>
    80001648:	89d2                	mv	s3,s4
    8000164a:	b75d                	j	800015f0 <copyout+0x38>
  return 0;
    8000164c:	4501                	li	a0,0
    8000164e:	6906                	ld	s2,64(sp)
    80001650:	79e2                	ld	s3,56(sp)
    80001652:	7aa2                	ld	s5,40(sp)
    80001654:	6ca2                	ld	s9,8(sp)
    80001656:	6d02                	ld	s10,0(sp)
    80001658:	a80d                	j	8000168a <copyout+0xd2>
    8000165a:	4501                	li	a0,0
}
    8000165c:	8082                	ret
      return -1;
    8000165e:	557d                	li	a0,-1
    80001660:	a02d                	j	8000168a <copyout+0xd2>
    80001662:	557d                	li	a0,-1
    80001664:	6906                	ld	s2,64(sp)
    80001666:	79e2                	ld	s3,56(sp)
    80001668:	7aa2                	ld	s5,40(sp)
    8000166a:	6ca2                	ld	s9,8(sp)
    8000166c:	6d02                	ld	s10,0(sp)
    8000166e:	a831                	j	8000168a <copyout+0xd2>
        return -1;
    80001670:	557d                	li	a0,-1
    80001672:	6906                	ld	s2,64(sp)
    80001674:	79e2                	ld	s3,56(sp)
    80001676:	7aa2                	ld	s5,40(sp)
    80001678:	6ca2                	ld	s9,8(sp)
    8000167a:	6d02                	ld	s10,0(sp)
    8000167c:	a039                	j	8000168a <copyout+0xd2>
      return -1;
    8000167e:	557d                	li	a0,-1
    80001680:	6906                	ld	s2,64(sp)
    80001682:	79e2                	ld	s3,56(sp)
    80001684:	7aa2                	ld	s5,40(sp)
    80001686:	6ca2                	ld	s9,8(sp)
    80001688:	6d02                	ld	s10,0(sp)
}
    8000168a:	60e6                	ld	ra,88(sp)
    8000168c:	6446                	ld	s0,80(sp)
    8000168e:	64a6                	ld	s1,72(sp)
    80001690:	7a42                	ld	s4,48(sp)
    80001692:	7b02                	ld	s6,32(sp)
    80001694:	6be2                	ld	s7,24(sp)
    80001696:	6c42                	ld	s8,16(sp)
    80001698:	6125                	addi	sp,sp,96
    8000169a:	8082                	ret

000000008000169c <copyin>:
  while (len > 0) {
    8000169c:	c6c9                	beqz	a3,80001726 <copyin+0x8a>
{
    8000169e:	715d                	addi	sp,sp,-80
    800016a0:	e486                	sd	ra,72(sp)
    800016a2:	e0a2                	sd	s0,64(sp)
    800016a4:	fc26                	sd	s1,56(sp)
    800016a6:	f84a                	sd	s2,48(sp)
    800016a8:	f44e                	sd	s3,40(sp)
    800016aa:	f052                	sd	s4,32(sp)
    800016ac:	ec56                	sd	s5,24(sp)
    800016ae:	e85a                	sd	s6,16(sp)
    800016b0:	e45e                	sd	s7,8(sp)
    800016b2:	e062                	sd	s8,0(sp)
    800016b4:	0880                	addi	s0,sp,80
    800016b6:	8baa                	mv	s7,a0
    800016b8:	8aae                	mv	s5,a1
    800016ba:	8932                	mv	s2,a2
    800016bc:	8a36                	mv	s4,a3
    va0 = PGROUNDDOWN(srcva);
    800016be:	7c7d                	lui	s8,0xfffff
    n = PGSIZE - (srcva - va0);
    800016c0:	6b05                	lui	s6,0x1
    800016c2:	a035                	j	800016ee <copyin+0x52>
    800016c4:	412984b3          	sub	s1,s3,s2
    800016c8:	94da                	add	s1,s1,s6
    if (n > len)
    800016ca:	009a7363          	bgeu	s4,s1,800016d0 <copyin+0x34>
    800016ce:	84d2                	mv	s1,s4
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    800016d0:	413905b3          	sub	a1,s2,s3
    800016d4:	0004861b          	sext.w	a2,s1
    800016d8:	95aa                	add	a1,a1,a0
    800016da:	8556                	mv	a0,s5
    800016dc:	df8ff0ef          	jal	80000cd4 <memmove>
    len -= n;
    800016e0:	409a0a33          	sub	s4,s4,s1
    dst += n;
    800016e4:	9aa6                	add	s5,s5,s1
    srcva = va0 + PGSIZE;
    800016e6:	01698933          	add	s2,s3,s6
  while (len > 0) {
    800016ea:	020a0163          	beqz	s4,8000170c <copyin+0x70>
    va0 = PGROUNDDOWN(srcva);
    800016ee:	018979b3          	and	s3,s2,s8
    pa0 = walkaddr(pagetable, va0);
    800016f2:	85ce                	mv	a1,s3
    800016f4:	855e                	mv	a0,s7
    800016f6:	891ff0ef          	jal	80000f86 <walkaddr>
    if (pa0 == 0) {
    800016fa:	f569                	bnez	a0,800016c4 <copyin+0x28>
      if ((pa0 = vmfault(pagetable, va0, 0)) == 0) {
    800016fc:	4601                	li	a2,0
    800016fe:	85ce                	mv	a1,s3
    80001700:	855e                	mv	a0,s7
    80001702:	e35ff0ef          	jal	80001536 <vmfault>
    80001706:	fd5d                	bnez	a0,800016c4 <copyin+0x28>
        return -1;
    80001708:	557d                	li	a0,-1
    8000170a:	a011                	j	8000170e <copyin+0x72>
  return 0;
    8000170c:	4501                	li	a0,0
}
    8000170e:	60a6                	ld	ra,72(sp)
    80001710:	6406                	ld	s0,64(sp)
    80001712:	74e2                	ld	s1,56(sp)
    80001714:	7942                	ld	s2,48(sp)
    80001716:	79a2                	ld	s3,40(sp)
    80001718:	7a02                	ld	s4,32(sp)
    8000171a:	6ae2                	ld	s5,24(sp)
    8000171c:	6b42                	ld	s6,16(sp)
    8000171e:	6ba2                	ld	s7,8(sp)
    80001720:	6c02                	ld	s8,0(sp)
    80001722:	6161                	addi	sp,sp,80
    80001724:	8082                	ret
  return 0;
    80001726:	4501                	li	a0,0
}
    80001728:	8082                	ret

000000008000172a <proc_mapstacks>:
// Allocate a page for each process's kernel stack.
// Map it high in memory, followed by an invalid
// guard page.
void
proc_mapstacks(pagetable_t kpgtbl)
{
    8000172a:	7139                	addi	sp,sp,-64
    8000172c:	fc06                	sd	ra,56(sp)
    8000172e:	f822                	sd	s0,48(sp)
    80001730:	f426                	sd	s1,40(sp)
    80001732:	f04a                	sd	s2,32(sp)
    80001734:	ec4e                	sd	s3,24(sp)
    80001736:	e852                	sd	s4,16(sp)
    80001738:	e456                	sd	s5,8(sp)
    8000173a:	e05a                	sd	s6,0(sp)
    8000173c:	0080                	addi	s0,sp,64
    8000173e:	8a2a                	mv	s4,a0
  struct proc *p;

  for (p = proc; p < &proc[NPROC]; p++) {
    80001740:	00011497          	auipc	s1,0x11
    80001744:	fb848493          	addi	s1,s1,-72 # 800126f8 <proc>
    char *pa = kalloc();
    if (pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int)(p - proc));
    80001748:	8b26                	mv	s6,s1
    8000174a:	04fa5937          	lui	s2,0x4fa5
    8000174e:	fa590913          	addi	s2,s2,-91 # 4fa4fa5 <_entry-0x7b05b05b>
    80001752:	0932                	slli	s2,s2,0xc
    80001754:	fa590913          	addi	s2,s2,-91
    80001758:	0932                	slli	s2,s2,0xc
    8000175a:	fa590913          	addi	s2,s2,-91
    8000175e:	0932                	slli	s2,s2,0xc
    80001760:	fa590913          	addi	s2,s2,-91
    80001764:	040009b7          	lui	s3,0x4000
    80001768:	19fd                	addi	s3,s3,-1 # 3ffffff <_entry-0x7c000001>
    8000176a:	09b2                	slli	s3,s3,0xc
  for (p = proc; p < &proc[NPROC]; p++) {
    8000176c:	00017a97          	auipc	s5,0x17
    80001770:	98ca8a93          	addi	s5,s5,-1652 # 800180f8 <tickslock>
    char *pa = kalloc();
    80001774:	b68ff0ef          	jal	80000adc <kalloc>
    80001778:	862a                	mv	a2,a0
    if (pa == 0)
    8000177a:	cd15                	beqz	a0,800017b6 <proc_mapstacks+0x8c>
    uint64 va = KSTACK((int)(p - proc));
    8000177c:	416485b3          	sub	a1,s1,s6
    80001780:	858d                	srai	a1,a1,0x3
    80001782:	032585b3          	mul	a1,a1,s2
    80001786:	2585                	addiw	a1,a1,1
    80001788:	00d5959b          	slliw	a1,a1,0xd
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    8000178c:	4719                	li	a4,6
    8000178e:	6685                	lui	a3,0x1
    80001790:	40b985b3          	sub	a1,s3,a1
    80001794:	8552                	mv	a0,s4
    80001796:	8dfff0ef          	jal	80001074 <kvmmap>
  for (p = proc; p < &proc[NPROC]; p++) {
    8000179a:	16848493          	addi	s1,s1,360
    8000179e:	fd549be3          	bne	s1,s5,80001774 <proc_mapstacks+0x4a>
  }
}
    800017a2:	70e2                	ld	ra,56(sp)
    800017a4:	7442                	ld	s0,48(sp)
    800017a6:	74a2                	ld	s1,40(sp)
    800017a8:	7902                	ld	s2,32(sp)
    800017aa:	69e2                	ld	s3,24(sp)
    800017ac:	6a42                	ld	s4,16(sp)
    800017ae:	6aa2                	ld	s5,8(sp)
    800017b0:	6b02                	ld	s6,0(sp)
    800017b2:	6121                	addi	sp,sp,64
    800017b4:	8082                	ret
      panic("kalloc");
    800017b6:	00006517          	auipc	a0,0x6
    800017ba:	9a250513          	addi	a0,a0,-1630 # 80007158 <etext+0x158>
    800017be:	816ff0ef          	jal	800007d4 <panic>

00000000800017c2 <procinit>:

// initialize the proc table.
void
procinit(void)
{
    800017c2:	7139                	addi	sp,sp,-64
    800017c4:	fc06                	sd	ra,56(sp)
    800017c6:	f822                	sd	s0,48(sp)
    800017c8:	f426                	sd	s1,40(sp)
    800017ca:	f04a                	sd	s2,32(sp)
    800017cc:	ec4e                	sd	s3,24(sp)
    800017ce:	e852                	sd	s4,16(sp)
    800017d0:	e456                	sd	s5,8(sp)
    800017d2:	e05a                	sd	s6,0(sp)
    800017d4:	0080                	addi	s0,sp,64
  struct proc *p;

  initlock(&pid_lock, "nextpid");
    800017d6:	00006597          	auipc	a1,0x6
    800017da:	98a58593          	addi	a1,a1,-1654 # 80007160 <etext+0x160>
    800017de:	00011517          	auipc	a0,0x11
    800017e2:	aea50513          	addi	a0,a0,-1302 # 800122c8 <pid_lock>
    800017e6:	b46ff0ef          	jal	80000b2c <initlock>
  initlock(&wait_lock, "wait_lock");
    800017ea:	00006597          	auipc	a1,0x6
    800017ee:	97e58593          	addi	a1,a1,-1666 # 80007168 <etext+0x168>
    800017f2:	00011517          	auipc	a0,0x11
    800017f6:	aee50513          	addi	a0,a0,-1298 # 800122e0 <wait_lock>
    800017fa:	b32ff0ef          	jal	80000b2c <initlock>
  for (p = proc; p < &proc[NPROC]; p++) {
    800017fe:	00011497          	auipc	s1,0x11
    80001802:	efa48493          	addi	s1,s1,-262 # 800126f8 <proc>
    initlock(&p->lock, "proc");
    80001806:	00006b17          	auipc	s6,0x6
    8000180a:	972b0b13          	addi	s6,s6,-1678 # 80007178 <etext+0x178>
    p->state = UNUSED;
    p->kstack = KSTACK((int)(p - proc));
    8000180e:	8aa6                	mv	s5,s1
    80001810:	04fa5937          	lui	s2,0x4fa5
    80001814:	fa590913          	addi	s2,s2,-91 # 4fa4fa5 <_entry-0x7b05b05b>
    80001818:	0932                	slli	s2,s2,0xc
    8000181a:	fa590913          	addi	s2,s2,-91
    8000181e:	0932                	slli	s2,s2,0xc
    80001820:	fa590913          	addi	s2,s2,-91
    80001824:	0932                	slli	s2,s2,0xc
    80001826:	fa590913          	addi	s2,s2,-91
    8000182a:	040009b7          	lui	s3,0x4000
    8000182e:	19fd                	addi	s3,s3,-1 # 3ffffff <_entry-0x7c000001>
    80001830:	09b2                	slli	s3,s3,0xc
  for (p = proc; p < &proc[NPROC]; p++) {
    80001832:	00017a17          	auipc	s4,0x17
    80001836:	8c6a0a13          	addi	s4,s4,-1850 # 800180f8 <tickslock>
    initlock(&p->lock, "proc");
    8000183a:	85da                	mv	a1,s6
    8000183c:	8526                	mv	a0,s1
    8000183e:	aeeff0ef          	jal	80000b2c <initlock>
    p->state = UNUSED;
    80001842:	0004ac23          	sw	zero,24(s1)
    p->kstack = KSTACK((int)(p - proc));
    80001846:	415487b3          	sub	a5,s1,s5
    8000184a:	878d                	srai	a5,a5,0x3
    8000184c:	032787b3          	mul	a5,a5,s2
    80001850:	2785                	addiw	a5,a5,1 # fffffffffffff001 <end+0xffffffff7ffdbb29>
    80001852:	00d7979b          	slliw	a5,a5,0xd
    80001856:	40f987b3          	sub	a5,s3,a5
    8000185a:	e0bc                	sd	a5,64(s1)
  for (p = proc; p < &proc[NPROC]; p++) {
    8000185c:	16848493          	addi	s1,s1,360
    80001860:	fd449de3          	bne	s1,s4,8000183a <procinit+0x78>
  }
}
    80001864:	70e2                	ld	ra,56(sp)
    80001866:	7442                	ld	s0,48(sp)
    80001868:	74a2                	ld	s1,40(sp)
    8000186a:	7902                	ld	s2,32(sp)
    8000186c:	69e2                	ld	s3,24(sp)
    8000186e:	6a42                	ld	s4,16(sp)
    80001870:	6aa2                	ld	s5,8(sp)
    80001872:	6b02                	ld	s6,0(sp)
    80001874:	6121                	addi	sp,sp,64
    80001876:	8082                	ret

0000000080001878 <cpuid>:
// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int
cpuid()
{
    80001878:	1141                	addi	sp,sp,-16
    8000187a:	e422                	sd	s0,8(sp)
    8000187c:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r"(x));
    8000187e:	8512                	mv	a0,tp
  int id = r_tp();
  return id;
}
    80001880:	2501                	sext.w	a0,a0
    80001882:	6422                	ld	s0,8(sp)
    80001884:	0141                	addi	sp,sp,16
    80001886:	8082                	ret

0000000080001888 <mycpu>:

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu *
mycpu(void)
{
    80001888:	1141                	addi	sp,sp,-16
    8000188a:	e422                	sd	s0,8(sp)
    8000188c:	0800                	addi	s0,sp,16
    8000188e:	8792                	mv	a5,tp
  int id = cpuid();
  struct cpu *c = &cpus[id];
    80001890:	2781                	sext.w	a5,a5
    80001892:	079e                	slli	a5,a5,0x7
  return c;
}
    80001894:	00011517          	auipc	a0,0x11
    80001898:	a6450513          	addi	a0,a0,-1436 # 800122f8 <cpus>
    8000189c:	953e                	add	a0,a0,a5
    8000189e:	6422                	ld	s0,8(sp)
    800018a0:	0141                	addi	sp,sp,16
    800018a2:	8082                	ret

00000000800018a4 <myproc>:

// Return the current struct proc *, or zero if none.
struct proc *
myproc(void)
{
    800018a4:	1101                	addi	sp,sp,-32
    800018a6:	ec06                	sd	ra,24(sp)
    800018a8:	e822                	sd	s0,16(sp)
    800018aa:	e426                	sd	s1,8(sp)
    800018ac:	1000                	addi	s0,sp,32
  push_off();
    800018ae:	abeff0ef          	jal	80000b6c <push_off>
    800018b2:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
    800018b4:	2781                	sext.w	a5,a5
    800018b6:	079e                	slli	a5,a5,0x7
    800018b8:	00011717          	auipc	a4,0x11
    800018bc:	a1070713          	addi	a4,a4,-1520 # 800122c8 <pid_lock>
    800018c0:	97ba                	add	a5,a5,a4
    800018c2:	7b84                	ld	s1,48(a5)
  pop_off();
    800018c4:	b28ff0ef          	jal	80000bec <pop_off>
  return p;
}
    800018c8:	8526                	mv	a0,s1
    800018ca:	60e2                	ld	ra,24(sp)
    800018cc:	6442                	ld	s0,16(sp)
    800018ce:	64a2                	ld	s1,8(sp)
    800018d0:	6105                	addi	sp,sp,32
    800018d2:	8082                	ret

00000000800018d4 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void
forkret(void)
{
    800018d4:	7179                	addi	sp,sp,-48
    800018d6:	f406                	sd	ra,40(sp)
    800018d8:	f022                	sd	s0,32(sp)
    800018da:	ec26                	sd	s1,24(sp)
    800018dc:	1800                	addi	s0,sp,48
  extern char userret[];
  static int first = 1;
  struct proc *p = myproc();
    800018de:	fc7ff0ef          	jal	800018a4 <myproc>
    800018e2:	84aa                	mv	s1,a0

  // Still holding p->lock from scheduler.
  release(&p->lock);
    800018e4:	b5cff0ef          	jal	80000c40 <release>

  if (first) {
    800018e8:	00009797          	auipc	a5,0x9
    800018ec:	8887a783          	lw	a5,-1912(a5) # 8000a170 <first.1>
    800018f0:	cf8d                	beqz	a5,8000192a <forkret+0x56>
    // File system initialization must be run in the context of a
    // regular process (e.g., because it calls sleep), and thus cannot
    // be run from main().
    fsinit(ROOTDEV);
    800018f2:	4505                	li	a0,1
    800018f4:	3b9010ef          	jal	800034ac <fsinit>

    first = 0;
    800018f8:	00009797          	auipc	a5,0x9
    800018fc:	8607ac23          	sw	zero,-1928(a5) # 8000a170 <first.1>
    // ensure other cores see first=0.
    __atomic_thread_fence(__ATOMIC_SEQ_CST);
    80001900:	0330000f          	fence	rw,rw

    // We can invoke kexec() now that file system is initialized.
    // Put the return value (argc) of kexec into a0.
    p->trapframe->a0 = kexec("/init", (char *[]){"/init", 0});
    80001904:	00006517          	auipc	a0,0x6
    80001908:	87c50513          	addi	a0,a0,-1924 # 80007180 <etext+0x180>
    8000190c:	fca43823          	sd	a0,-48(s0)
    80001910:	fc043c23          	sd	zero,-40(s0)
    80001914:	fd040593          	addi	a1,s0,-48
    80001918:	507020ef          	jal	8000461e <kexec>
    8000191c:	6cbc                	ld	a5,88(s1)
    8000191e:	fba8                	sd	a0,112(a5)
    if (p->trapframe->a0 == -1) {
    80001920:	6cbc                	ld	a5,88(s1)
    80001922:	7bb8                	ld	a4,112(a5)
    80001924:	57fd                	li	a5,-1
    80001926:	02f70d63          	beq	a4,a5,80001960 <forkret+0x8c>
      panic("exec");
    }
  }

  // return to user space, mimicing usertrap()'s return.
  prepare_return();
    8000192a:	2bf000ef          	jal	800023e8 <prepare_return>
  uint64 satp = MAKE_SATP(p->pagetable);
    8000192e:	68a8                	ld	a0,80(s1)
    80001930:	8131                	srli	a0,a0,0xc
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    80001932:	04000737          	lui	a4,0x4000
    80001936:	177d                	addi	a4,a4,-1 # 3ffffff <_entry-0x7c000001>
    80001938:	0732                	slli	a4,a4,0xc
    8000193a:	00004797          	auipc	a5,0x4
    8000193e:	76278793          	addi	a5,a5,1890 # 8000609c <userret>
    80001942:	00004697          	auipc	a3,0x4
    80001946:	6be68693          	addi	a3,a3,1726 # 80006000 <_trampoline>
    8000194a:	8f95                	sub	a5,a5,a3
    8000194c:	97ba                	add	a5,a5,a4
  ((void (*)(uint64))trampoline_userret)(satp);
    8000194e:	577d                	li	a4,-1
    80001950:	177e                	slli	a4,a4,0x3f
    80001952:	8d59                	or	a0,a0,a4
    80001954:	9782                	jalr	a5
}
    80001956:	70a2                	ld	ra,40(sp)
    80001958:	7402                	ld	s0,32(sp)
    8000195a:	64e2                	ld	s1,24(sp)
    8000195c:	6145                	addi	sp,sp,48
    8000195e:	8082                	ret
      panic("exec");
    80001960:	00006517          	auipc	a0,0x6
    80001964:	82850513          	addi	a0,a0,-2008 # 80007188 <etext+0x188>
    80001968:	e6dfe0ef          	jal	800007d4 <panic>

000000008000196c <allocpid>:
{
    8000196c:	1101                	addi	sp,sp,-32
    8000196e:	ec06                	sd	ra,24(sp)
    80001970:	e822                	sd	s0,16(sp)
    80001972:	e426                	sd	s1,8(sp)
    80001974:	e04a                	sd	s2,0(sp)
    80001976:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80001978:	00011917          	auipc	s2,0x11
    8000197c:	95090913          	addi	s2,s2,-1712 # 800122c8 <pid_lock>
    80001980:	854a                	mv	a0,s2
    80001982:	a2aff0ef          	jal	80000bac <acquire>
  pid = nextpid;
    80001986:	00008797          	auipc	a5,0x8
    8000198a:	7ee78793          	addi	a5,a5,2030 # 8000a174 <nextpid>
    8000198e:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80001990:	0014871b          	addiw	a4,s1,1
    80001994:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001996:	854a                	mv	a0,s2
    80001998:	aa8ff0ef          	jal	80000c40 <release>
}
    8000199c:	8526                	mv	a0,s1
    8000199e:	60e2                	ld	ra,24(sp)
    800019a0:	6442                	ld	s0,16(sp)
    800019a2:	64a2                	ld	s1,8(sp)
    800019a4:	6902                	ld	s2,0(sp)
    800019a6:	6105                	addi	sp,sp,32
    800019a8:	8082                	ret

00000000800019aa <proc_pagetable>:
{
    800019aa:	1101                	addi	sp,sp,-32
    800019ac:	ec06                	sd	ra,24(sp)
    800019ae:	e822                	sd	s0,16(sp)
    800019b0:	e426                	sd	s1,8(sp)
    800019b2:	e04a                	sd	s2,0(sp)
    800019b4:	1000                	addi	s0,sp,32
    800019b6:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    800019b8:	fb2ff0ef          	jal	8000116a <uvmcreate>
    800019bc:	84aa                	mv	s1,a0
  if (pagetable == 0)
    800019be:	cd05                	beqz	a0,800019f6 <proc_pagetable+0x4c>
  if (mappages(pagetable, TRAMPOLINE, PGSIZE, (uint64)trampoline,
    800019c0:	4729                	li	a4,10
    800019c2:	00004697          	auipc	a3,0x4
    800019c6:	63e68693          	addi	a3,a3,1598 # 80006000 <_trampoline>
    800019ca:	6605                	lui	a2,0x1
    800019cc:	040005b7          	lui	a1,0x4000
    800019d0:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    800019d2:	05b2                	slli	a1,a1,0xc
    800019d4:	df0ff0ef          	jal	80000fc4 <mappages>
    800019d8:	02054663          	bltz	a0,80001a04 <proc_pagetable+0x5a>
  if (mappages(pagetable, TRAPFRAME, PGSIZE, (uint64)(p->trapframe),
    800019dc:	4719                	li	a4,6
    800019de:	05893683          	ld	a3,88(s2)
    800019e2:	6605                	lui	a2,0x1
    800019e4:	020005b7          	lui	a1,0x2000
    800019e8:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    800019ea:	05b6                	slli	a1,a1,0xd
    800019ec:	8526                	mv	a0,s1
    800019ee:	dd6ff0ef          	jal	80000fc4 <mappages>
    800019f2:	00054f63          	bltz	a0,80001a10 <proc_pagetable+0x66>
}
    800019f6:	8526                	mv	a0,s1
    800019f8:	60e2                	ld	ra,24(sp)
    800019fa:	6442                	ld	s0,16(sp)
    800019fc:	64a2                	ld	s1,8(sp)
    800019fe:	6902                	ld	s2,0(sp)
    80001a00:	6105                	addi	sp,sp,32
    80001a02:	8082                	ret
    uvmfree(pagetable, 0);
    80001a04:	4581                	li	a1,0
    80001a06:	8526                	mv	a0,s1
    80001a08:	95dff0ef          	jal	80001364 <uvmfree>
    return 0;
    80001a0c:	4481                	li	s1,0
    80001a0e:	b7e5                	j	800019f6 <proc_pagetable+0x4c>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001a10:	4681                	li	a3,0
    80001a12:	4605                	li	a2,1
    80001a14:	040005b7          	lui	a1,0x4000
    80001a18:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001a1a:	05b2                	slli	a1,a1,0xc
    80001a1c:	8526                	mv	a0,s1
    80001a1e:	f72ff0ef          	jal	80001190 <uvmunmap>
    uvmfree(pagetable, 0);
    80001a22:	4581                	li	a1,0
    80001a24:	8526                	mv	a0,s1
    80001a26:	93fff0ef          	jal	80001364 <uvmfree>
    return 0;
    80001a2a:	4481                	li	s1,0
    80001a2c:	b7e9                	j	800019f6 <proc_pagetable+0x4c>

0000000080001a2e <proc_freepagetable>:
{
    80001a2e:	1101                	addi	sp,sp,-32
    80001a30:	ec06                	sd	ra,24(sp)
    80001a32:	e822                	sd	s0,16(sp)
    80001a34:	e426                	sd	s1,8(sp)
    80001a36:	e04a                	sd	s2,0(sp)
    80001a38:	1000                	addi	s0,sp,32
    80001a3a:	84aa                	mv	s1,a0
    80001a3c:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001a3e:	4681                	li	a3,0
    80001a40:	4605                	li	a2,1
    80001a42:	040005b7          	lui	a1,0x4000
    80001a46:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001a48:	05b2                	slli	a1,a1,0xc
    80001a4a:	f46ff0ef          	jal	80001190 <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001a4e:	4681                	li	a3,0
    80001a50:	4605                	li	a2,1
    80001a52:	020005b7          	lui	a1,0x2000
    80001a56:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001a58:	05b6                	slli	a1,a1,0xd
    80001a5a:	8526                	mv	a0,s1
    80001a5c:	f34ff0ef          	jal	80001190 <uvmunmap>
  uvmfree(pagetable, sz);
    80001a60:	85ca                	mv	a1,s2
    80001a62:	8526                	mv	a0,s1
    80001a64:	901ff0ef          	jal	80001364 <uvmfree>
}
    80001a68:	60e2                	ld	ra,24(sp)
    80001a6a:	6442                	ld	s0,16(sp)
    80001a6c:	64a2                	ld	s1,8(sp)
    80001a6e:	6902                	ld	s2,0(sp)
    80001a70:	6105                	addi	sp,sp,32
    80001a72:	8082                	ret

0000000080001a74 <freeproc>:
{
    80001a74:	1101                	addi	sp,sp,-32
    80001a76:	ec06                	sd	ra,24(sp)
    80001a78:	e822                	sd	s0,16(sp)
    80001a7a:	e426                	sd	s1,8(sp)
    80001a7c:	1000                	addi	s0,sp,32
    80001a7e:	84aa                	mv	s1,a0
  if (p->trapframe)
    80001a80:	6d28                	ld	a0,88(a0)
    80001a82:	c119                	beqz	a0,80001a88 <freeproc+0x14>
    kfree((void *)p->trapframe);
    80001a84:	f77fe0ef          	jal	800009fa <kfree>
  p->trapframe = 0;
    80001a88:	0404bc23          	sd	zero,88(s1)
  if (p->pagetable)
    80001a8c:	68a8                	ld	a0,80(s1)
    80001a8e:	c501                	beqz	a0,80001a96 <freeproc+0x22>
    proc_freepagetable(p->pagetable, p->sz);
    80001a90:	64ac                	ld	a1,72(s1)
    80001a92:	f9dff0ef          	jal	80001a2e <proc_freepagetable>
  p->pagetable = 0;
    80001a96:	0404b823          	sd	zero,80(s1)
  p->sz = 0;
    80001a9a:	0404b423          	sd	zero,72(s1)
  p->pid = 0;
    80001a9e:	0204a823          	sw	zero,48(s1)
  p->parent = 0;
    80001aa2:	0204bc23          	sd	zero,56(s1)
  p->name[0] = 0;
    80001aa6:	14048c23          	sb	zero,344(s1)
  p->chan = 0;
    80001aaa:	0204b023          	sd	zero,32(s1)
  p->killed = 0;
    80001aae:	0204a423          	sw	zero,40(s1)
  p->xstate = 0;
    80001ab2:	0204a623          	sw	zero,44(s1)
  p->state = UNUSED;
    80001ab6:	0004ac23          	sw	zero,24(s1)
}
    80001aba:	60e2                	ld	ra,24(sp)
    80001abc:	6442                	ld	s0,16(sp)
    80001abe:	64a2                	ld	s1,8(sp)
    80001ac0:	6105                	addi	sp,sp,32
    80001ac2:	8082                	ret

0000000080001ac4 <allocproc>:
{
    80001ac4:	1101                	addi	sp,sp,-32
    80001ac6:	ec06                	sd	ra,24(sp)
    80001ac8:	e822                	sd	s0,16(sp)
    80001aca:	e426                	sd	s1,8(sp)
    80001acc:	e04a                	sd	s2,0(sp)
    80001ace:	1000                	addi	s0,sp,32
  for (p = proc; p < &proc[NPROC]; p++) {
    80001ad0:	00011497          	auipc	s1,0x11
    80001ad4:	c2848493          	addi	s1,s1,-984 # 800126f8 <proc>
    80001ad8:	00016917          	auipc	s2,0x16
    80001adc:	62090913          	addi	s2,s2,1568 # 800180f8 <tickslock>
    acquire(&p->lock);
    80001ae0:	8526                	mv	a0,s1
    80001ae2:	8caff0ef          	jal	80000bac <acquire>
    if (p->state == UNUSED) {
    80001ae6:	4c9c                	lw	a5,24(s1)
    80001ae8:	cb91                	beqz	a5,80001afc <allocproc+0x38>
      release(&p->lock);
    80001aea:	8526                	mv	a0,s1
    80001aec:	954ff0ef          	jal	80000c40 <release>
  for (p = proc; p < &proc[NPROC]; p++) {
    80001af0:	16848493          	addi	s1,s1,360
    80001af4:	ff2496e3          	bne	s1,s2,80001ae0 <allocproc+0x1c>
  return 0;
    80001af8:	4481                	li	s1,0
    80001afa:	a089                	j	80001b3c <allocproc+0x78>
  p->pid = allocpid();
    80001afc:	e71ff0ef          	jal	8000196c <allocpid>
    80001b00:	d888                	sw	a0,48(s1)
  p->state = USED;
    80001b02:	4785                	li	a5,1
    80001b04:	cc9c                	sw	a5,24(s1)
  if ((p->trapframe = (struct trapframe *)kalloc()) == 0) {
    80001b06:	fd7fe0ef          	jal	80000adc <kalloc>
    80001b0a:	892a                	mv	s2,a0
    80001b0c:	eca8                	sd	a0,88(s1)
    80001b0e:	cd15                	beqz	a0,80001b4a <allocproc+0x86>
  p->pagetable = proc_pagetable(p);
    80001b10:	8526                	mv	a0,s1
    80001b12:	e99ff0ef          	jal	800019aa <proc_pagetable>
    80001b16:	892a                	mv	s2,a0
    80001b18:	e8a8                	sd	a0,80(s1)
  if (p->pagetable == 0) {
    80001b1a:	c121                	beqz	a0,80001b5a <allocproc+0x96>
  memset(&p->context, 0, sizeof(p->context));
    80001b1c:	07000613          	li	a2,112
    80001b20:	4581                	li	a1,0
    80001b22:	06048513          	addi	a0,s1,96
    80001b26:	952ff0ef          	jal	80000c78 <memset>
  p->context.ra = (uint64)forkret;
    80001b2a:	00000797          	auipc	a5,0x0
    80001b2e:	daa78793          	addi	a5,a5,-598 # 800018d4 <forkret>
    80001b32:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001b34:	60bc                	ld	a5,64(s1)
    80001b36:	6705                	lui	a4,0x1
    80001b38:	97ba                	add	a5,a5,a4
    80001b3a:	f4bc                	sd	a5,104(s1)
}
    80001b3c:	8526                	mv	a0,s1
    80001b3e:	60e2                	ld	ra,24(sp)
    80001b40:	6442                	ld	s0,16(sp)
    80001b42:	64a2                	ld	s1,8(sp)
    80001b44:	6902                	ld	s2,0(sp)
    80001b46:	6105                	addi	sp,sp,32
    80001b48:	8082                	ret
    freeproc(p);
    80001b4a:	8526                	mv	a0,s1
    80001b4c:	f29ff0ef          	jal	80001a74 <freeproc>
    release(&p->lock);
    80001b50:	8526                	mv	a0,s1
    80001b52:	8eeff0ef          	jal	80000c40 <release>
    return 0;
    80001b56:	84ca                	mv	s1,s2
    80001b58:	b7d5                	j	80001b3c <allocproc+0x78>
    freeproc(p);
    80001b5a:	8526                	mv	a0,s1
    80001b5c:	f19ff0ef          	jal	80001a74 <freeproc>
    release(&p->lock);
    80001b60:	8526                	mv	a0,s1
    80001b62:	8deff0ef          	jal	80000c40 <release>
    return 0;
    80001b66:	84ca                	mv	s1,s2
    80001b68:	bfd1                	j	80001b3c <allocproc+0x78>

0000000080001b6a <userinit>:
{
    80001b6a:	1101                	addi	sp,sp,-32
    80001b6c:	ec06                	sd	ra,24(sp)
    80001b6e:	e822                	sd	s0,16(sp)
    80001b70:	e426                	sd	s1,8(sp)
    80001b72:	1000                	addi	s0,sp,32
  p = allocproc();
    80001b74:	f51ff0ef          	jal	80001ac4 <allocproc>
    80001b78:	84aa                	mv	s1,a0
  initproc = p;
    80001b7a:	00008797          	auipc	a5,0x8
    80001b7e:	64a7b323          	sd	a0,1606(a5) # 8000a1c0 <initproc>
  p->cwd = namei("/");
    80001b82:	00005517          	auipc	a0,0x5
    80001b86:	60e50513          	addi	a0,a0,1550 # 80007190 <etext+0x190>
    80001b8a:	645010ef          	jal	800039ce <namei>
    80001b8e:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    80001b92:	478d                	li	a5,3
    80001b94:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80001b96:	8526                	mv	a0,s1
    80001b98:	8a8ff0ef          	jal	80000c40 <release>
}
    80001b9c:	60e2                	ld	ra,24(sp)
    80001b9e:	6442                	ld	s0,16(sp)
    80001ba0:	64a2                	ld	s1,8(sp)
    80001ba2:	6105                	addi	sp,sp,32
    80001ba4:	8082                	ret

0000000080001ba6 <growproc>:
{
    80001ba6:	1101                	addi	sp,sp,-32
    80001ba8:	ec06                	sd	ra,24(sp)
    80001baa:	e822                	sd	s0,16(sp)
    80001bac:	e426                	sd	s1,8(sp)
    80001bae:	e04a                	sd	s2,0(sp)
    80001bb0:	1000                	addi	s0,sp,32
    80001bb2:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80001bb4:	cf1ff0ef          	jal	800018a4 <myproc>
    80001bb8:	892a                	mv	s2,a0
  sz = p->sz;
    80001bba:	652c                	ld	a1,72(a0)
  if (n > 0) {
    80001bbc:	02905963          	blez	s1,80001bee <growproc+0x48>
    if (sz + n > TRAPFRAME) {
    80001bc0:	00b48633          	add	a2,s1,a1
    80001bc4:	020007b7          	lui	a5,0x2000
    80001bc8:	17fd                	addi	a5,a5,-1 # 1ffffff <_entry-0x7e000001>
    80001bca:	07b6                	slli	a5,a5,0xd
    80001bcc:	02c7ea63          	bltu	a5,a2,80001c00 <growproc+0x5a>
    if ((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0) {
    80001bd0:	4691                	li	a3,4
    80001bd2:	6928                	ld	a0,80(a0)
    80001bd4:	e8aff0ef          	jal	8000125e <uvmalloc>
    80001bd8:	85aa                	mv	a1,a0
    80001bda:	c50d                	beqz	a0,80001c04 <growproc+0x5e>
  p->sz = sz;
    80001bdc:	04b93423          	sd	a1,72(s2)
  return 0;
    80001be0:	4501                	li	a0,0
}
    80001be2:	60e2                	ld	ra,24(sp)
    80001be4:	6442                	ld	s0,16(sp)
    80001be6:	64a2                	ld	s1,8(sp)
    80001be8:	6902                	ld	s2,0(sp)
    80001bea:	6105                	addi	sp,sp,32
    80001bec:	8082                	ret
  } else if (n < 0) {
    80001bee:	fe04d7e3          	bgez	s1,80001bdc <growproc+0x36>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001bf2:	00b48633          	add	a2,s1,a1
    80001bf6:	6928                	ld	a0,80(a0)
    80001bf8:	e22ff0ef          	jal	8000121a <uvmdealloc>
    80001bfc:	85aa                	mv	a1,a0
    80001bfe:	bff9                	j	80001bdc <growproc+0x36>
      return -1;
    80001c00:	557d                	li	a0,-1
    80001c02:	b7c5                	j	80001be2 <growproc+0x3c>
      return -1;
    80001c04:	557d                	li	a0,-1
    80001c06:	bff1                	j	80001be2 <growproc+0x3c>

0000000080001c08 <kfork>:
{
    80001c08:	7139                	addi	sp,sp,-64
    80001c0a:	fc06                	sd	ra,56(sp)
    80001c0c:	f822                	sd	s0,48(sp)
    80001c0e:	f04a                	sd	s2,32(sp)
    80001c10:	e456                	sd	s5,8(sp)
    80001c12:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    80001c14:	c91ff0ef          	jal	800018a4 <myproc>
    80001c18:	8aaa                	mv	s5,a0
  if ((np = allocproc()) == 0) {
    80001c1a:	eabff0ef          	jal	80001ac4 <allocproc>
    80001c1e:	0e050a63          	beqz	a0,80001d12 <kfork+0x10a>
    80001c22:	e852                	sd	s4,16(sp)
    80001c24:	8a2a                	mv	s4,a0
  if (uvmcopy(p->pagetable, np->pagetable, p->sz) < 0) {
    80001c26:	048ab603          	ld	a2,72(s5)
    80001c2a:	692c                	ld	a1,80(a0)
    80001c2c:	050ab503          	ld	a0,80(s5)
    80001c30:	f66ff0ef          	jal	80001396 <uvmcopy>
    80001c34:	04054a63          	bltz	a0,80001c88 <kfork+0x80>
    80001c38:	f426                	sd	s1,40(sp)
    80001c3a:	ec4e                	sd	s3,24(sp)
  np->sz = p->sz;
    80001c3c:	048ab783          	ld	a5,72(s5)
    80001c40:	04fa3423          	sd	a5,72(s4)
  *(np->trapframe) = *(p->trapframe);
    80001c44:	058ab683          	ld	a3,88(s5)
    80001c48:	87b6                	mv	a5,a3
    80001c4a:	058a3703          	ld	a4,88(s4)
    80001c4e:	12068693          	addi	a3,a3,288
    80001c52:	0007b803          	ld	a6,0(a5)
    80001c56:	6788                	ld	a0,8(a5)
    80001c58:	6b8c                	ld	a1,16(a5)
    80001c5a:	6f90                	ld	a2,24(a5)
    80001c5c:	01073023          	sd	a6,0(a4) # 1000 <_entry-0x7ffff000>
    80001c60:	e708                	sd	a0,8(a4)
    80001c62:	eb0c                	sd	a1,16(a4)
    80001c64:	ef10                	sd	a2,24(a4)
    80001c66:	02078793          	addi	a5,a5,32
    80001c6a:	02070713          	addi	a4,a4,32
    80001c6e:	fed792e3          	bne	a5,a3,80001c52 <kfork+0x4a>
  np->trapframe->a0 = 0;
    80001c72:	058a3783          	ld	a5,88(s4)
    80001c76:	0607b823          	sd	zero,112(a5)
  for (i = 0; i < NOFILE; i++)
    80001c7a:	0d0a8493          	addi	s1,s5,208
    80001c7e:	0d0a0913          	addi	s2,s4,208
    80001c82:	150a8993          	addi	s3,s5,336
    80001c86:	a831                	j	80001ca2 <kfork+0x9a>
    freeproc(np);
    80001c88:	8552                	mv	a0,s4
    80001c8a:	debff0ef          	jal	80001a74 <freeproc>
    release(&np->lock);
    80001c8e:	8552                	mv	a0,s4
    80001c90:	fb1fe0ef          	jal	80000c40 <release>
    return -1;
    80001c94:	597d                	li	s2,-1
    80001c96:	6a42                	ld	s4,16(sp)
    80001c98:	a0b5                	j	80001d04 <kfork+0xfc>
  for (i = 0; i < NOFILE; i++)
    80001c9a:	04a1                	addi	s1,s1,8
    80001c9c:	0921                	addi	s2,s2,8
    80001c9e:	01348963          	beq	s1,s3,80001cb0 <kfork+0xa8>
    if (p->ofile[i])
    80001ca2:	6088                	ld	a0,0(s1)
    80001ca4:	d97d                	beqz	a0,80001c9a <kfork+0x92>
      np->ofile[i] = filedup(p->ofile[i]);
    80001ca6:	32a020ef          	jal	80003fd0 <filedup>
    80001caa:	00a93023          	sd	a0,0(s2)
    80001cae:	b7f5                	j	80001c9a <kfork+0x92>
  np->cwd = idup(p->cwd);
    80001cb0:	150ab503          	ld	a0,336(s5)
    80001cb4:	4ce010ef          	jal	80003182 <idup>
    80001cb8:	14aa3823          	sd	a0,336(s4)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001cbc:	4641                	li	a2,16
    80001cbe:	158a8593          	addi	a1,s5,344
    80001cc2:	158a0513          	addi	a0,s4,344
    80001cc6:	8f0ff0ef          	jal	80000db6 <safestrcpy>
  pid = np->pid;
    80001cca:	030a2903          	lw	s2,48(s4)
  release(&np->lock);
    80001cce:	8552                	mv	a0,s4
    80001cd0:	f71fe0ef          	jal	80000c40 <release>
  acquire(&wait_lock);
    80001cd4:	00010497          	auipc	s1,0x10
    80001cd8:	60c48493          	addi	s1,s1,1548 # 800122e0 <wait_lock>
    80001cdc:	8526                	mv	a0,s1
    80001cde:	ecffe0ef          	jal	80000bac <acquire>
  np->parent = p;
    80001ce2:	035a3c23          	sd	s5,56(s4)
  release(&wait_lock);
    80001ce6:	8526                	mv	a0,s1
    80001ce8:	f59fe0ef          	jal	80000c40 <release>
  acquire(&np->lock);
    80001cec:	8552                	mv	a0,s4
    80001cee:	ebffe0ef          	jal	80000bac <acquire>
  np->state = RUNNABLE;
    80001cf2:	478d                	li	a5,3
    80001cf4:	00fa2c23          	sw	a5,24(s4)
  release(&np->lock);
    80001cf8:	8552                	mv	a0,s4
    80001cfa:	f47fe0ef          	jal	80000c40 <release>
  return pid;
    80001cfe:	74a2                	ld	s1,40(sp)
    80001d00:	69e2                	ld	s3,24(sp)
    80001d02:	6a42                	ld	s4,16(sp)
}
    80001d04:	854a                	mv	a0,s2
    80001d06:	70e2                	ld	ra,56(sp)
    80001d08:	7442                	ld	s0,48(sp)
    80001d0a:	7902                	ld	s2,32(sp)
    80001d0c:	6aa2                	ld	s5,8(sp)
    80001d0e:	6121                	addi	sp,sp,64
    80001d10:	8082                	ret
    return -1;
    80001d12:	597d                	li	s2,-1
    80001d14:	bfc5                	j	80001d04 <kfork+0xfc>

0000000080001d16 <scheduler>:
{
    80001d16:	715d                	addi	sp,sp,-80
    80001d18:	e486                	sd	ra,72(sp)
    80001d1a:	e0a2                	sd	s0,64(sp)
    80001d1c:	fc26                	sd	s1,56(sp)
    80001d1e:	f84a                	sd	s2,48(sp)
    80001d20:	f44e                	sd	s3,40(sp)
    80001d22:	f052                	sd	s4,32(sp)
    80001d24:	ec56                	sd	s5,24(sp)
    80001d26:	e85a                	sd	s6,16(sp)
    80001d28:	e45e                	sd	s7,8(sp)
    80001d2a:	e062                	sd	s8,0(sp)
    80001d2c:	0880                	addi	s0,sp,80
    80001d2e:	8792                	mv	a5,tp
  int id = r_tp();
    80001d30:	2781                	sext.w	a5,a5
  c->proc = 0;
    80001d32:	00779b13          	slli	s6,a5,0x7
    80001d36:	00010717          	auipc	a4,0x10
    80001d3a:	59270713          	addi	a4,a4,1426 # 800122c8 <pid_lock>
    80001d3e:	975a                	add	a4,a4,s6
    80001d40:	02073823          	sd	zero,48(a4)
        swtch(&c->context, &p->context);
    80001d44:	00010717          	auipc	a4,0x10
    80001d48:	5bc70713          	addi	a4,a4,1468 # 80012300 <cpus+0x8>
    80001d4c:	9b3a                	add	s6,s6,a4
        p->state = RUNNING;
    80001d4e:	4c11                	li	s8,4
        c->proc = p;
    80001d50:	079e                	slli	a5,a5,0x7
    80001d52:	00010a17          	auipc	s4,0x10
    80001d56:	576a0a13          	addi	s4,s4,1398 # 800122c8 <pid_lock>
    80001d5a:	9a3e                	add	s4,s4,a5
        found = 1;
    80001d5c:	4b85                	li	s7,1
    for (p = proc; p < &proc[NPROC]; p++) {
    80001d5e:	00016997          	auipc	s3,0x16
    80001d62:	39a98993          	addi	s3,s3,922 # 800180f8 <tickslock>
    80001d66:	a83d                	j	80001da4 <scheduler+0x8e>
      release(&p->lock);
    80001d68:	8526                	mv	a0,s1
    80001d6a:	ed7fe0ef          	jal	80000c40 <release>
    for (p = proc; p < &proc[NPROC]; p++) {
    80001d6e:	16848493          	addi	s1,s1,360
    80001d72:	03348563          	beq	s1,s3,80001d9c <scheduler+0x86>
      acquire(&p->lock);
    80001d76:	8526                	mv	a0,s1
    80001d78:	e35fe0ef          	jal	80000bac <acquire>
      if (p->state == RUNNABLE) {
    80001d7c:	4c9c                	lw	a5,24(s1)
    80001d7e:	ff2795e3          	bne	a5,s2,80001d68 <scheduler+0x52>
        p->state = RUNNING;
    80001d82:	0184ac23          	sw	s8,24(s1)
        c->proc = p;
    80001d86:	029a3823          	sd	s1,48(s4)
        swtch(&c->context, &p->context);
    80001d8a:	06048593          	addi	a1,s1,96
    80001d8e:	855a                	mv	a0,s6
    80001d90:	5b2000ef          	jal	80002342 <swtch>
        c->proc = 0;
    80001d94:	020a3823          	sd	zero,48(s4)
        found = 1;
    80001d98:	8ade                	mv	s5,s7
    80001d9a:	b7f9                	j	80001d68 <scheduler+0x52>
    if (found == 0) {
    80001d9c:	000a9463          	bnez	s5,80001da4 <scheduler+0x8e>
      asm volatile("wfi");
    80001da0:	10500073          	wfi
  asm volatile("csrr %0, sstatus" : "=r"(x));
    80001da4:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001da8:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r"(x));
    80001dac:	10079073          	csrw	sstatus,a5
  asm volatile("csrr %0, sstatus" : "=r"(x));
    80001db0:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80001db4:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r"(x));
    80001db6:	10079073          	csrw	sstatus,a5
    int found = 0;
    80001dba:	4a81                	li	s5,0
    for (p = proc; p < &proc[NPROC]; p++) {
    80001dbc:	00011497          	auipc	s1,0x11
    80001dc0:	93c48493          	addi	s1,s1,-1732 # 800126f8 <proc>
      if (p->state == RUNNABLE) {
    80001dc4:	490d                	li	s2,3
    80001dc6:	bf45                	j	80001d76 <scheduler+0x60>

0000000080001dc8 <sched>:
{
    80001dc8:	7179                	addi	sp,sp,-48
    80001dca:	f406                	sd	ra,40(sp)
    80001dcc:	f022                	sd	s0,32(sp)
    80001dce:	ec26                	sd	s1,24(sp)
    80001dd0:	e84a                	sd	s2,16(sp)
    80001dd2:	e44e                	sd	s3,8(sp)
    80001dd4:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80001dd6:	acfff0ef          	jal	800018a4 <myproc>
    80001dda:	84aa                	mv	s1,a0
  if (!holding(&p->lock))
    80001ddc:	d67fe0ef          	jal	80000b42 <holding>
    80001de0:	c92d                	beqz	a0,80001e52 <sched+0x8a>
  asm volatile("mv %0, tp" : "=r"(x));
    80001de2:	8792                	mv	a5,tp
  if (mycpu()->noff != 1)
    80001de4:	2781                	sext.w	a5,a5
    80001de6:	079e                	slli	a5,a5,0x7
    80001de8:	00010717          	auipc	a4,0x10
    80001dec:	4e070713          	addi	a4,a4,1248 # 800122c8 <pid_lock>
    80001df0:	97ba                	add	a5,a5,a4
    80001df2:	0a87a703          	lw	a4,168(a5)
    80001df6:	4785                	li	a5,1
    80001df8:	06f71363          	bne	a4,a5,80001e5e <sched+0x96>
  if (p->state == RUNNING)
    80001dfc:	4c98                	lw	a4,24(s1)
    80001dfe:	4791                	li	a5,4
    80001e00:	06f70563          	beq	a4,a5,80001e6a <sched+0xa2>
  asm volatile("csrr %0, sstatus" : "=r"(x));
    80001e04:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80001e08:	8b89                	andi	a5,a5,2
  if (intr_get())
    80001e0a:	e7b5                	bnez	a5,80001e76 <sched+0xae>
  asm volatile("mv %0, tp" : "=r"(x));
    80001e0c:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    80001e0e:	00010917          	auipc	s2,0x10
    80001e12:	4ba90913          	addi	s2,s2,1210 # 800122c8 <pid_lock>
    80001e16:	2781                	sext.w	a5,a5
    80001e18:	079e                	slli	a5,a5,0x7
    80001e1a:	97ca                	add	a5,a5,s2
    80001e1c:	0ac7a983          	lw	s3,172(a5)
    80001e20:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    80001e22:	2781                	sext.w	a5,a5
    80001e24:	079e                	slli	a5,a5,0x7
    80001e26:	00010597          	auipc	a1,0x10
    80001e2a:	4da58593          	addi	a1,a1,1242 # 80012300 <cpus+0x8>
    80001e2e:	95be                	add	a1,a1,a5
    80001e30:	06048513          	addi	a0,s1,96
    80001e34:	50e000ef          	jal	80002342 <swtch>
    80001e38:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    80001e3a:	2781                	sext.w	a5,a5
    80001e3c:	079e                	slli	a5,a5,0x7
    80001e3e:	993e                	add	s2,s2,a5
    80001e40:	0b392623          	sw	s3,172(s2)
}
    80001e44:	70a2                	ld	ra,40(sp)
    80001e46:	7402                	ld	s0,32(sp)
    80001e48:	64e2                	ld	s1,24(sp)
    80001e4a:	6942                	ld	s2,16(sp)
    80001e4c:	69a2                	ld	s3,8(sp)
    80001e4e:	6145                	addi	sp,sp,48
    80001e50:	8082                	ret
    panic("sched p->lock");
    80001e52:	00005517          	auipc	a0,0x5
    80001e56:	34650513          	addi	a0,a0,838 # 80007198 <etext+0x198>
    80001e5a:	97bfe0ef          	jal	800007d4 <panic>
    panic("sched locks");
    80001e5e:	00005517          	auipc	a0,0x5
    80001e62:	34a50513          	addi	a0,a0,842 # 800071a8 <etext+0x1a8>
    80001e66:	96ffe0ef          	jal	800007d4 <panic>
    panic("sched RUNNING");
    80001e6a:	00005517          	auipc	a0,0x5
    80001e6e:	34e50513          	addi	a0,a0,846 # 800071b8 <etext+0x1b8>
    80001e72:	963fe0ef          	jal	800007d4 <panic>
    panic("sched interruptible");
    80001e76:	00005517          	auipc	a0,0x5
    80001e7a:	35250513          	addi	a0,a0,850 # 800071c8 <etext+0x1c8>
    80001e7e:	957fe0ef          	jal	800007d4 <panic>

0000000080001e82 <yield>:
{
    80001e82:	1101                	addi	sp,sp,-32
    80001e84:	ec06                	sd	ra,24(sp)
    80001e86:	e822                	sd	s0,16(sp)
    80001e88:	e426                	sd	s1,8(sp)
    80001e8a:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80001e8c:	a19ff0ef          	jal	800018a4 <myproc>
    80001e90:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80001e92:	d1bfe0ef          	jal	80000bac <acquire>
  p->state = RUNNABLE;
    80001e96:	478d                	li	a5,3
    80001e98:	cc9c                	sw	a5,24(s1)
  sched();
    80001e9a:	f2fff0ef          	jal	80001dc8 <sched>
  release(&p->lock);
    80001e9e:	8526                	mv	a0,s1
    80001ea0:	da1fe0ef          	jal	80000c40 <release>
}
    80001ea4:	60e2                	ld	ra,24(sp)
    80001ea6:	6442                	ld	s0,16(sp)
    80001ea8:	64a2                	ld	s1,8(sp)
    80001eaa:	6105                	addi	sp,sp,32
    80001eac:	8082                	ret

0000000080001eae <sleep>:

// Sleep on channel chan, releasing condition lock lk.
// Re-acquires lk when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
    80001eae:	7179                	addi	sp,sp,-48
    80001eb0:	f406                	sd	ra,40(sp)
    80001eb2:	f022                	sd	s0,32(sp)
    80001eb4:	ec26                	sd	s1,24(sp)
    80001eb6:	e84a                	sd	s2,16(sp)
    80001eb8:	e44e                	sd	s3,8(sp)
    80001eba:	1800                	addi	s0,sp,48
    80001ebc:	89aa                	mv	s3,a0
    80001ebe:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80001ec0:	9e5ff0ef          	jal	800018a4 <myproc>
    80001ec4:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock); //DOC: sleeplock1
    80001ec6:	ce7fe0ef          	jal	80000bac <acquire>
  release(lk);
    80001eca:	854a                	mv	a0,s2
    80001ecc:	d75fe0ef          	jal	80000c40 <release>

  // Go to sleep.
  p->chan = chan;
    80001ed0:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    80001ed4:	4789                	li	a5,2
    80001ed6:	cc9c                	sw	a5,24(s1)

  sched();
    80001ed8:	ef1ff0ef          	jal	80001dc8 <sched>

  // Tidy up.
  p->chan = 0;
    80001edc:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    80001ee0:	8526                	mv	a0,s1
    80001ee2:	d5ffe0ef          	jal	80000c40 <release>
  acquire(lk);
    80001ee6:	854a                	mv	a0,s2
    80001ee8:	cc5fe0ef          	jal	80000bac <acquire>
}
    80001eec:	70a2                	ld	ra,40(sp)
    80001eee:	7402                	ld	s0,32(sp)
    80001ef0:	64e2                	ld	s1,24(sp)
    80001ef2:	6942                	ld	s2,16(sp)
    80001ef4:	69a2                	ld	s3,8(sp)
    80001ef6:	6145                	addi	sp,sp,48
    80001ef8:	8082                	ret

0000000080001efa <wakeup>:

// Wake up all processes sleeping on channel chan.
// Caller should hold the condition lock.
void
wakeup(void *chan)
{
    80001efa:	7139                	addi	sp,sp,-64
    80001efc:	fc06                	sd	ra,56(sp)
    80001efe:	f822                	sd	s0,48(sp)
    80001f00:	f426                	sd	s1,40(sp)
    80001f02:	f04a                	sd	s2,32(sp)
    80001f04:	ec4e                	sd	s3,24(sp)
    80001f06:	e852                	sd	s4,16(sp)
    80001f08:	e456                	sd	s5,8(sp)
    80001f0a:	0080                	addi	s0,sp,64
    80001f0c:	8a2a                	mv	s4,a0
  struct proc *p;

  for (p = proc; p < &proc[NPROC]; p++) {
    80001f0e:	00010497          	auipc	s1,0x10
    80001f12:	7ea48493          	addi	s1,s1,2026 # 800126f8 <proc>
    if (p != myproc()) {
      acquire(&p->lock);
      if (p->state == SLEEPING && p->chan == chan) {
    80001f16:	4989                	li	s3,2
        p->state = RUNNABLE;
    80001f18:	4a8d                	li	s5,3
  for (p = proc; p < &proc[NPROC]; p++) {
    80001f1a:	00016917          	auipc	s2,0x16
    80001f1e:	1de90913          	addi	s2,s2,478 # 800180f8 <tickslock>
    80001f22:	a801                	j	80001f32 <wakeup+0x38>
      }
      release(&p->lock);
    80001f24:	8526                	mv	a0,s1
    80001f26:	d1bfe0ef          	jal	80000c40 <release>
  for (p = proc; p < &proc[NPROC]; p++) {
    80001f2a:	16848493          	addi	s1,s1,360
    80001f2e:	03248263          	beq	s1,s2,80001f52 <wakeup+0x58>
    if (p != myproc()) {
    80001f32:	973ff0ef          	jal	800018a4 <myproc>
    80001f36:	fea48ae3          	beq	s1,a0,80001f2a <wakeup+0x30>
      acquire(&p->lock);
    80001f3a:	8526                	mv	a0,s1
    80001f3c:	c71fe0ef          	jal	80000bac <acquire>
      if (p->state == SLEEPING && p->chan == chan) {
    80001f40:	4c9c                	lw	a5,24(s1)
    80001f42:	ff3791e3          	bne	a5,s3,80001f24 <wakeup+0x2a>
    80001f46:	709c                	ld	a5,32(s1)
    80001f48:	fd479ee3          	bne	a5,s4,80001f24 <wakeup+0x2a>
        p->state = RUNNABLE;
    80001f4c:	0154ac23          	sw	s5,24(s1)
    80001f50:	bfd1                	j	80001f24 <wakeup+0x2a>
    }
  }
}
    80001f52:	70e2                	ld	ra,56(sp)
    80001f54:	7442                	ld	s0,48(sp)
    80001f56:	74a2                	ld	s1,40(sp)
    80001f58:	7902                	ld	s2,32(sp)
    80001f5a:	69e2                	ld	s3,24(sp)
    80001f5c:	6a42                	ld	s4,16(sp)
    80001f5e:	6aa2                	ld	s5,8(sp)
    80001f60:	6121                	addi	sp,sp,64
    80001f62:	8082                	ret

0000000080001f64 <reparent>:
{
    80001f64:	7179                	addi	sp,sp,-48
    80001f66:	f406                	sd	ra,40(sp)
    80001f68:	f022                	sd	s0,32(sp)
    80001f6a:	ec26                	sd	s1,24(sp)
    80001f6c:	e84a                	sd	s2,16(sp)
    80001f6e:	e44e                	sd	s3,8(sp)
    80001f70:	e052                	sd	s4,0(sp)
    80001f72:	1800                	addi	s0,sp,48
    80001f74:	892a                	mv	s2,a0
  for (pp = proc; pp < &proc[NPROC]; pp++) {
    80001f76:	00010497          	auipc	s1,0x10
    80001f7a:	78248493          	addi	s1,s1,1922 # 800126f8 <proc>
      pp->parent = initproc;
    80001f7e:	00008a17          	auipc	s4,0x8
    80001f82:	242a0a13          	addi	s4,s4,578 # 8000a1c0 <initproc>
  for (pp = proc; pp < &proc[NPROC]; pp++) {
    80001f86:	00016997          	auipc	s3,0x16
    80001f8a:	17298993          	addi	s3,s3,370 # 800180f8 <tickslock>
    80001f8e:	a029                	j	80001f98 <reparent+0x34>
    80001f90:	16848493          	addi	s1,s1,360
    80001f94:	01348b63          	beq	s1,s3,80001faa <reparent+0x46>
    if (pp->parent == p) {
    80001f98:	7c9c                	ld	a5,56(s1)
    80001f9a:	ff279be3          	bne	a5,s2,80001f90 <reparent+0x2c>
      pp->parent = initproc;
    80001f9e:	000a3503          	ld	a0,0(s4)
    80001fa2:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    80001fa4:	f57ff0ef          	jal	80001efa <wakeup>
    80001fa8:	b7e5                	j	80001f90 <reparent+0x2c>
}
    80001faa:	70a2                	ld	ra,40(sp)
    80001fac:	7402                	ld	s0,32(sp)
    80001fae:	64e2                	ld	s1,24(sp)
    80001fb0:	6942                	ld	s2,16(sp)
    80001fb2:	69a2                	ld	s3,8(sp)
    80001fb4:	6a02                	ld	s4,0(sp)
    80001fb6:	6145                	addi	sp,sp,48
    80001fb8:	8082                	ret

0000000080001fba <kexit>:
{
    80001fba:	7179                	addi	sp,sp,-48
    80001fbc:	f406                	sd	ra,40(sp)
    80001fbe:	f022                	sd	s0,32(sp)
    80001fc0:	ec26                	sd	s1,24(sp)
    80001fc2:	e84a                	sd	s2,16(sp)
    80001fc4:	e44e                	sd	s3,8(sp)
    80001fc6:	e052                	sd	s4,0(sp)
    80001fc8:	1800                	addi	s0,sp,48
    80001fca:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    80001fcc:	8d9ff0ef          	jal	800018a4 <myproc>
    80001fd0:	89aa                	mv	s3,a0
  if (p == initproc)
    80001fd2:	00008797          	auipc	a5,0x8
    80001fd6:	1ee7b783          	ld	a5,494(a5) # 8000a1c0 <initproc>
    80001fda:	0d050493          	addi	s1,a0,208
    80001fde:	15050913          	addi	s2,a0,336
    80001fe2:	00a79f63          	bne	a5,a0,80002000 <kexit+0x46>
    panic("init exiting");
    80001fe6:	00005517          	auipc	a0,0x5
    80001fea:	1fa50513          	addi	a0,a0,506 # 800071e0 <etext+0x1e0>
    80001fee:	fe6fe0ef          	jal	800007d4 <panic>
      fileclose(f);
    80001ff2:	024020ef          	jal	80004016 <fileclose>
      p->ofile[fd] = 0;
    80001ff6:	0004b023          	sd	zero,0(s1)
  for (int fd = 0; fd < NOFILE; fd++) {
    80001ffa:	04a1                	addi	s1,s1,8
    80001ffc:	01248563          	beq	s1,s2,80002006 <kexit+0x4c>
    if (p->ofile[fd]) {
    80002000:	6088                	ld	a0,0(s1)
    80002002:	f965                	bnez	a0,80001ff2 <kexit+0x38>
    80002004:	bfdd                	j	80001ffa <kexit+0x40>
  begin_op();
    80002006:	39d010ef          	jal	80003ba2 <begin_op>
  iput(p->cwd);
    8000200a:	1509b503          	ld	a0,336(s3)
    8000200e:	32c010ef          	jal	8000333a <iput>
  end_op();
    80002012:	3fb010ef          	jal	80003c0c <end_op>
  p->cwd = 0;
    80002016:	1409b823          	sd	zero,336(s3)
  acquire(&wait_lock);
    8000201a:	00010497          	auipc	s1,0x10
    8000201e:	2c648493          	addi	s1,s1,710 # 800122e0 <wait_lock>
    80002022:	8526                	mv	a0,s1
    80002024:	b89fe0ef          	jal	80000bac <acquire>
  reparent(p);
    80002028:	854e                	mv	a0,s3
    8000202a:	f3bff0ef          	jal	80001f64 <reparent>
  wakeup(p->parent);
    8000202e:	0389b503          	ld	a0,56(s3)
    80002032:	ec9ff0ef          	jal	80001efa <wakeup>
  acquire(&p->lock);
    80002036:	854e                	mv	a0,s3
    80002038:	b75fe0ef          	jal	80000bac <acquire>
  p->xstate = status;
    8000203c:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    80002040:	4795                	li	a5,5
    80002042:	00f9ac23          	sw	a5,24(s3)
  release(&wait_lock);
    80002046:	8526                	mv	a0,s1
    80002048:	bf9fe0ef          	jal	80000c40 <release>
  sched();
    8000204c:	d7dff0ef          	jal	80001dc8 <sched>
  panic("zombie exit");
    80002050:	00005517          	auipc	a0,0x5
    80002054:	1a050513          	addi	a0,a0,416 # 800071f0 <etext+0x1f0>
    80002058:	f7cfe0ef          	jal	800007d4 <panic>

000000008000205c <kkill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kkill(int pid)
{
    8000205c:	7179                	addi	sp,sp,-48
    8000205e:	f406                	sd	ra,40(sp)
    80002060:	f022                	sd	s0,32(sp)
    80002062:	ec26                	sd	s1,24(sp)
    80002064:	e84a                	sd	s2,16(sp)
    80002066:	e44e                	sd	s3,8(sp)
    80002068:	1800                	addi	s0,sp,48
    8000206a:	892a                	mv	s2,a0
  struct proc *p;

  for (p = proc; p < &proc[NPROC]; p++) {
    8000206c:	00010497          	auipc	s1,0x10
    80002070:	68c48493          	addi	s1,s1,1676 # 800126f8 <proc>
    80002074:	00016997          	auipc	s3,0x16
    80002078:	08498993          	addi	s3,s3,132 # 800180f8 <tickslock>
    acquire(&p->lock);
    8000207c:	8526                	mv	a0,s1
    8000207e:	b2ffe0ef          	jal	80000bac <acquire>
    if (p->pid == pid) {
    80002082:	589c                	lw	a5,48(s1)
    80002084:	01278b63          	beq	a5,s2,8000209a <kkill+0x3e>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    80002088:	8526                	mv	a0,s1
    8000208a:	bb7fe0ef          	jal	80000c40 <release>
  for (p = proc; p < &proc[NPROC]; p++) {
    8000208e:	16848493          	addi	s1,s1,360
    80002092:	ff3495e3          	bne	s1,s3,8000207c <kkill+0x20>
  }
  return -1;
    80002096:	557d                	li	a0,-1
    80002098:	a819                	j	800020ae <kkill+0x52>
      p->killed = 1;
    8000209a:	4785                	li	a5,1
    8000209c:	d49c                	sw	a5,40(s1)
      if (p->state == SLEEPING) {
    8000209e:	4c98                	lw	a4,24(s1)
    800020a0:	4789                	li	a5,2
    800020a2:	00f70d63          	beq	a4,a5,800020bc <kkill+0x60>
      release(&p->lock);
    800020a6:	8526                	mv	a0,s1
    800020a8:	b99fe0ef          	jal	80000c40 <release>
      return 0;
    800020ac:	4501                	li	a0,0
}
    800020ae:	70a2                	ld	ra,40(sp)
    800020b0:	7402                	ld	s0,32(sp)
    800020b2:	64e2                	ld	s1,24(sp)
    800020b4:	6942                	ld	s2,16(sp)
    800020b6:	69a2                	ld	s3,8(sp)
    800020b8:	6145                	addi	sp,sp,48
    800020ba:	8082                	ret
        p->state = RUNNABLE;
    800020bc:	478d                	li	a5,3
    800020be:	cc9c                	sw	a5,24(s1)
    800020c0:	b7dd                	j	800020a6 <kkill+0x4a>

00000000800020c2 <setkilled>:

void
setkilled(struct proc *p)
{
    800020c2:	1101                	addi	sp,sp,-32
    800020c4:	ec06                	sd	ra,24(sp)
    800020c6:	e822                	sd	s0,16(sp)
    800020c8:	e426                	sd	s1,8(sp)
    800020ca:	1000                	addi	s0,sp,32
    800020cc:	84aa                	mv	s1,a0
  acquire(&p->lock);
    800020ce:	adffe0ef          	jal	80000bac <acquire>
  p->killed = 1;
    800020d2:	4785                	li	a5,1
    800020d4:	d49c                	sw	a5,40(s1)
  release(&p->lock);
    800020d6:	8526                	mv	a0,s1
    800020d8:	b69fe0ef          	jal	80000c40 <release>
}
    800020dc:	60e2                	ld	ra,24(sp)
    800020de:	6442                	ld	s0,16(sp)
    800020e0:	64a2                	ld	s1,8(sp)
    800020e2:	6105                	addi	sp,sp,32
    800020e4:	8082                	ret

00000000800020e6 <killed>:

int
killed(struct proc *p)
{
    800020e6:	1101                	addi	sp,sp,-32
    800020e8:	ec06                	sd	ra,24(sp)
    800020ea:	e822                	sd	s0,16(sp)
    800020ec:	e426                	sd	s1,8(sp)
    800020ee:	e04a                	sd	s2,0(sp)
    800020f0:	1000                	addi	s0,sp,32
    800020f2:	84aa                	mv	s1,a0
  int k;

  acquire(&p->lock);
    800020f4:	ab9fe0ef          	jal	80000bac <acquire>
  k = p->killed;
    800020f8:	0284a903          	lw	s2,40(s1)
  release(&p->lock);
    800020fc:	8526                	mv	a0,s1
    800020fe:	b43fe0ef          	jal	80000c40 <release>
  return k;
}
    80002102:	854a                	mv	a0,s2
    80002104:	60e2                	ld	ra,24(sp)
    80002106:	6442                	ld	s0,16(sp)
    80002108:	64a2                	ld	s1,8(sp)
    8000210a:	6902                	ld	s2,0(sp)
    8000210c:	6105                	addi	sp,sp,32
    8000210e:	8082                	ret

0000000080002110 <kwait>:
{
    80002110:	715d                	addi	sp,sp,-80
    80002112:	e486                	sd	ra,72(sp)
    80002114:	e0a2                	sd	s0,64(sp)
    80002116:	fc26                	sd	s1,56(sp)
    80002118:	f84a                	sd	s2,48(sp)
    8000211a:	f44e                	sd	s3,40(sp)
    8000211c:	f052                	sd	s4,32(sp)
    8000211e:	ec56                	sd	s5,24(sp)
    80002120:	e85a                	sd	s6,16(sp)
    80002122:	e45e                	sd	s7,8(sp)
    80002124:	e062                	sd	s8,0(sp)
    80002126:	0880                	addi	s0,sp,80
    80002128:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    8000212a:	f7aff0ef          	jal	800018a4 <myproc>
    8000212e:	892a                	mv	s2,a0
  acquire(&wait_lock);
    80002130:	00010517          	auipc	a0,0x10
    80002134:	1b050513          	addi	a0,a0,432 # 800122e0 <wait_lock>
    80002138:	a75fe0ef          	jal	80000bac <acquire>
    havekids = 0;
    8000213c:	4b81                	li	s7,0
        if (pp->state == ZOMBIE) {
    8000213e:	4a15                	li	s4,5
        havekids = 1;
    80002140:	4a85                	li	s5,1
    for (pp = proc; pp < &proc[NPROC]; pp++) {
    80002142:	00016997          	auipc	s3,0x16
    80002146:	fb698993          	addi	s3,s3,-74 # 800180f8 <tickslock>
    sleep(p, &wait_lock); //DOC: wait-sleep
    8000214a:	00010c17          	auipc	s8,0x10
    8000214e:	196c0c13          	addi	s8,s8,406 # 800122e0 <wait_lock>
    80002152:	a871                	j	800021ee <kwait+0xde>
          pid = pp->pid;
    80002154:	0304a983          	lw	s3,48(s1)
          if (addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    80002158:	000b0c63          	beqz	s6,80002170 <kwait+0x60>
    8000215c:	4691                	li	a3,4
    8000215e:	02c48613          	addi	a2,s1,44
    80002162:	85da                	mv	a1,s6
    80002164:	05093503          	ld	a0,80(s2)
    80002168:	c50ff0ef          	jal	800015b8 <copyout>
    8000216c:	02054b63          	bltz	a0,800021a2 <kwait+0x92>
          freeproc(pp);
    80002170:	8526                	mv	a0,s1
    80002172:	903ff0ef          	jal	80001a74 <freeproc>
          release(&pp->lock);
    80002176:	8526                	mv	a0,s1
    80002178:	ac9fe0ef          	jal	80000c40 <release>
          release(&wait_lock);
    8000217c:	00010517          	auipc	a0,0x10
    80002180:	16450513          	addi	a0,a0,356 # 800122e0 <wait_lock>
    80002184:	abdfe0ef          	jal	80000c40 <release>
}
    80002188:	854e                	mv	a0,s3
    8000218a:	60a6                	ld	ra,72(sp)
    8000218c:	6406                	ld	s0,64(sp)
    8000218e:	74e2                	ld	s1,56(sp)
    80002190:	7942                	ld	s2,48(sp)
    80002192:	79a2                	ld	s3,40(sp)
    80002194:	7a02                	ld	s4,32(sp)
    80002196:	6ae2                	ld	s5,24(sp)
    80002198:	6b42                	ld	s6,16(sp)
    8000219a:	6ba2                	ld	s7,8(sp)
    8000219c:	6c02                	ld	s8,0(sp)
    8000219e:	6161                	addi	sp,sp,80
    800021a0:	8082                	ret
            release(&pp->lock);
    800021a2:	8526                	mv	a0,s1
    800021a4:	a9dfe0ef          	jal	80000c40 <release>
            release(&wait_lock);
    800021a8:	00010517          	auipc	a0,0x10
    800021ac:	13850513          	addi	a0,a0,312 # 800122e0 <wait_lock>
    800021b0:	a91fe0ef          	jal	80000c40 <release>
            return -1;
    800021b4:	59fd                	li	s3,-1
    800021b6:	bfc9                	j	80002188 <kwait+0x78>
    for (pp = proc; pp < &proc[NPROC]; pp++) {
    800021b8:	16848493          	addi	s1,s1,360
    800021bc:	03348063          	beq	s1,s3,800021dc <kwait+0xcc>
      if (pp->parent == p) {
    800021c0:	7c9c                	ld	a5,56(s1)
    800021c2:	ff279be3          	bne	a5,s2,800021b8 <kwait+0xa8>
        acquire(&pp->lock);
    800021c6:	8526                	mv	a0,s1
    800021c8:	9e5fe0ef          	jal	80000bac <acquire>
        if (pp->state == ZOMBIE) {
    800021cc:	4c9c                	lw	a5,24(s1)
    800021ce:	f94783e3          	beq	a5,s4,80002154 <kwait+0x44>
        release(&pp->lock);
    800021d2:	8526                	mv	a0,s1
    800021d4:	a6dfe0ef          	jal	80000c40 <release>
        havekids = 1;
    800021d8:	8756                	mv	a4,s5
    800021da:	bff9                	j	800021b8 <kwait+0xa8>
    if (!havekids || killed(p)) {
    800021dc:	cf19                	beqz	a4,800021fa <kwait+0xea>
    800021de:	854a                	mv	a0,s2
    800021e0:	f07ff0ef          	jal	800020e6 <killed>
    800021e4:	e919                	bnez	a0,800021fa <kwait+0xea>
    sleep(p, &wait_lock); //DOC: wait-sleep
    800021e6:	85e2                	mv	a1,s8
    800021e8:	854a                	mv	a0,s2
    800021ea:	cc5ff0ef          	jal	80001eae <sleep>
    havekids = 0;
    800021ee:	875e                	mv	a4,s7
    for (pp = proc; pp < &proc[NPROC]; pp++) {
    800021f0:	00010497          	auipc	s1,0x10
    800021f4:	50848493          	addi	s1,s1,1288 # 800126f8 <proc>
    800021f8:	b7e1                	j	800021c0 <kwait+0xb0>
      release(&wait_lock);
    800021fa:	00010517          	auipc	a0,0x10
    800021fe:	0e650513          	addi	a0,a0,230 # 800122e0 <wait_lock>
    80002202:	a3ffe0ef          	jal	80000c40 <release>
      return -1;
    80002206:	59fd                	li	s3,-1
    80002208:	b741                	j	80002188 <kwait+0x78>

000000008000220a <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    8000220a:	7179                	addi	sp,sp,-48
    8000220c:	f406                	sd	ra,40(sp)
    8000220e:	f022                	sd	s0,32(sp)
    80002210:	ec26                	sd	s1,24(sp)
    80002212:	e84a                	sd	s2,16(sp)
    80002214:	e44e                	sd	s3,8(sp)
    80002216:	e052                	sd	s4,0(sp)
    80002218:	1800                	addi	s0,sp,48
    8000221a:	84aa                	mv	s1,a0
    8000221c:	892e                	mv	s2,a1
    8000221e:	89b2                	mv	s3,a2
    80002220:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80002222:	e82ff0ef          	jal	800018a4 <myproc>
  if (user_dst) {
    80002226:	cc99                	beqz	s1,80002244 <either_copyout+0x3a>
    return copyout(p->pagetable, dst, src, len);
    80002228:	86d2                	mv	a3,s4
    8000222a:	864e                	mv	a2,s3
    8000222c:	85ca                	mv	a1,s2
    8000222e:	6928                	ld	a0,80(a0)
    80002230:	b88ff0ef          	jal	800015b8 <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    80002234:	70a2                	ld	ra,40(sp)
    80002236:	7402                	ld	s0,32(sp)
    80002238:	64e2                	ld	s1,24(sp)
    8000223a:	6942                	ld	s2,16(sp)
    8000223c:	69a2                	ld	s3,8(sp)
    8000223e:	6a02                	ld	s4,0(sp)
    80002240:	6145                	addi	sp,sp,48
    80002242:	8082                	ret
    memmove((char *)dst, src, len);
    80002244:	000a061b          	sext.w	a2,s4
    80002248:	85ce                	mv	a1,s3
    8000224a:	854a                	mv	a0,s2
    8000224c:	a89fe0ef          	jal	80000cd4 <memmove>
    return 0;
    80002250:	8526                	mv	a0,s1
    80002252:	b7cd                	j	80002234 <either_copyout+0x2a>

0000000080002254 <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    80002254:	7179                	addi	sp,sp,-48
    80002256:	f406                	sd	ra,40(sp)
    80002258:	f022                	sd	s0,32(sp)
    8000225a:	ec26                	sd	s1,24(sp)
    8000225c:	e84a                	sd	s2,16(sp)
    8000225e:	e44e                	sd	s3,8(sp)
    80002260:	e052                	sd	s4,0(sp)
    80002262:	1800                	addi	s0,sp,48
    80002264:	892a                	mv	s2,a0
    80002266:	84ae                	mv	s1,a1
    80002268:	89b2                	mv	s3,a2
    8000226a:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    8000226c:	e38ff0ef          	jal	800018a4 <myproc>
  if (user_src) {
    80002270:	cc99                	beqz	s1,8000228e <either_copyin+0x3a>
    return copyin(p->pagetable, dst, src, len);
    80002272:	86d2                	mv	a3,s4
    80002274:	864e                	mv	a2,s3
    80002276:	85ca                	mv	a1,s2
    80002278:	6928                	ld	a0,80(a0)
    8000227a:	c22ff0ef          	jal	8000169c <copyin>
  } else {
    memmove(dst, (char *)src, len);
    return 0;
  }
}
    8000227e:	70a2                	ld	ra,40(sp)
    80002280:	7402                	ld	s0,32(sp)
    80002282:	64e2                	ld	s1,24(sp)
    80002284:	6942                	ld	s2,16(sp)
    80002286:	69a2                	ld	s3,8(sp)
    80002288:	6a02                	ld	s4,0(sp)
    8000228a:	6145                	addi	sp,sp,48
    8000228c:	8082                	ret
    memmove(dst, (char *)src, len);
    8000228e:	000a061b          	sext.w	a2,s4
    80002292:	85ce                	mv	a1,s3
    80002294:	854a                	mv	a0,s2
    80002296:	a3ffe0ef          	jal	80000cd4 <memmove>
    return 0;
    8000229a:	8526                	mv	a0,s1
    8000229c:	b7cd                	j	8000227e <either_copyin+0x2a>

000000008000229e <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    8000229e:	715d                	addi	sp,sp,-80
    800022a0:	e486                	sd	ra,72(sp)
    800022a2:	e0a2                	sd	s0,64(sp)
    800022a4:	fc26                	sd	s1,56(sp)
    800022a6:	f84a                	sd	s2,48(sp)
    800022a8:	f44e                	sd	s3,40(sp)
    800022aa:	f052                	sd	s4,32(sp)
    800022ac:	ec56                	sd	s5,24(sp)
    800022ae:	e85a                	sd	s6,16(sp)
    800022b0:	e45e                	sd	s7,8(sp)
    800022b2:	0880                	addi	s0,sp,80
    // clang-format on
  };
  struct proc *p;
  char *state;

  printk("\n");
    800022b4:	00005517          	auipc	a0,0x5
    800022b8:	dc450513          	addi	a0,a0,-572 # 80007078 <etext+0x78>
    800022bc:	a32fe0ef          	jal	800004ee <printk>
  for (p = proc; p < &proc[NPROC]; p++) {
    800022c0:	00010497          	auipc	s1,0x10
    800022c4:	59048493          	addi	s1,s1,1424 # 80012850 <proc+0x158>
    800022c8:	00016917          	auipc	s2,0x16
    800022cc:	f8890913          	addi	s2,s2,-120 # 80018250 <bcache+0x140>
    if (p->state == UNUSED)
      continue;
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800022d0:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    800022d2:	00005997          	auipc	s3,0x5
    800022d6:	f2e98993          	addi	s3,s3,-210 # 80007200 <etext+0x200>
    printk("%d %s %s", p->pid, state, p->name);
    800022da:	00005a97          	auipc	s5,0x5
    800022de:	f2ea8a93          	addi	s5,s5,-210 # 80007208 <etext+0x208>
    printk("\n");
    800022e2:	00005a17          	auipc	s4,0x5
    800022e6:	d96a0a13          	addi	s4,s4,-618 # 80007078 <etext+0x78>
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800022ea:	00005b97          	auipc	s7,0x5
    800022ee:	43eb8b93          	addi	s7,s7,1086 # 80007728 <states.0>
    800022f2:	a829                	j	8000230c <procdump+0x6e>
    printk("%d %s %s", p->pid, state, p->name);
    800022f4:	ed86a583          	lw	a1,-296(a3)
    800022f8:	8556                	mv	a0,s5
    800022fa:	9f4fe0ef          	jal	800004ee <printk>
    printk("\n");
    800022fe:	8552                	mv	a0,s4
    80002300:	9eefe0ef          	jal	800004ee <printk>
  for (p = proc; p < &proc[NPROC]; p++) {
    80002304:	16848493          	addi	s1,s1,360
    80002308:	03248263          	beq	s1,s2,8000232c <procdump+0x8e>
    if (p->state == UNUSED)
    8000230c:	86a6                	mv	a3,s1
    8000230e:	ec04a783          	lw	a5,-320(s1)
    80002312:	dbed                	beqz	a5,80002304 <procdump+0x66>
      state = "???";
    80002314:	864e                	mv	a2,s3
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002316:	fcfb6fe3          	bltu	s6,a5,800022f4 <procdump+0x56>
    8000231a:	02079713          	slli	a4,a5,0x20
    8000231e:	01d75793          	srli	a5,a4,0x1d
    80002322:	97de                	add	a5,a5,s7
    80002324:	6390                	ld	a2,0(a5)
    80002326:	f679                	bnez	a2,800022f4 <procdump+0x56>
      state = "???";
    80002328:	864e                	mv	a2,s3
    8000232a:	b7e9                	j	800022f4 <procdump+0x56>
  }
}
    8000232c:	60a6                	ld	ra,72(sp)
    8000232e:	6406                	ld	s0,64(sp)
    80002330:	74e2                	ld	s1,56(sp)
    80002332:	7942                	ld	s2,48(sp)
    80002334:	79a2                	ld	s3,40(sp)
    80002336:	7a02                	ld	s4,32(sp)
    80002338:	6ae2                	ld	s5,24(sp)
    8000233a:	6b42                	ld	s6,16(sp)
    8000233c:	6ba2                	ld	s7,8(sp)
    8000233e:	6161                	addi	sp,sp,80
    80002340:	8082                	ret

0000000080002342 <swtch>:
# Save current registers in old. Load from new.	


.globl swtch
swtch:
        sd ra, 0(a0)
    80002342:	00153023          	sd	ra,0(a0)
        sd sp, 8(a0)
    80002346:	00253423          	sd	sp,8(a0)
        sd s0, 16(a0)
    8000234a:	e900                	sd	s0,16(a0)
        sd s1, 24(a0)
    8000234c:	ed04                	sd	s1,24(a0)
        sd s2, 32(a0)
    8000234e:	03253023          	sd	s2,32(a0)
        sd s3, 40(a0)
    80002352:	03353423          	sd	s3,40(a0)
        sd s4, 48(a0)
    80002356:	03453823          	sd	s4,48(a0)
        sd s5, 56(a0)
    8000235a:	03553c23          	sd	s5,56(a0)
        sd s6, 64(a0)
    8000235e:	05653023          	sd	s6,64(a0)
        sd s7, 72(a0)
    80002362:	05753423          	sd	s7,72(a0)
        sd s8, 80(a0)
    80002366:	05853823          	sd	s8,80(a0)
        sd s9, 88(a0)
    8000236a:	05953c23          	sd	s9,88(a0)
        sd s10, 96(a0)
    8000236e:	07a53023          	sd	s10,96(a0)
        sd s11, 104(a0)
    80002372:	07b53423          	sd	s11,104(a0)

        ld ra, 0(a1)
    80002376:	0005b083          	ld	ra,0(a1)
        ld sp, 8(a1)
    8000237a:	0085b103          	ld	sp,8(a1)
        ld s0, 16(a1)
    8000237e:	6980                	ld	s0,16(a1)
        ld s1, 24(a1)
    80002380:	6d84                	ld	s1,24(a1)
        ld s2, 32(a1)
    80002382:	0205b903          	ld	s2,32(a1)
        ld s3, 40(a1)
    80002386:	0285b983          	ld	s3,40(a1)
        ld s4, 48(a1)
    8000238a:	0305ba03          	ld	s4,48(a1)
        ld s5, 56(a1)
    8000238e:	0385ba83          	ld	s5,56(a1)
        ld s6, 64(a1)
    80002392:	0405bb03          	ld	s6,64(a1)
        ld s7, 72(a1)
    80002396:	0485bb83          	ld	s7,72(a1)
        ld s8, 80(a1)
    8000239a:	0505bc03          	ld	s8,80(a1)
        ld s9, 88(a1)
    8000239e:	0585bc83          	ld	s9,88(a1)
        ld s10, 96(a1)
    800023a2:	0605bd03          	ld	s10,96(a1)
        ld s11, 104(a1)
    800023a6:	0685bd83          	ld	s11,104(a1)
        
        ret
    800023aa:	8082                	ret

00000000800023ac <trapinit>:

extern int devintr();

void
trapinit(void)
{
    800023ac:	1141                	addi	sp,sp,-16
    800023ae:	e406                	sd	ra,8(sp)
    800023b0:	e022                	sd	s0,0(sp)
    800023b2:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    800023b4:	00005597          	auipc	a1,0x5
    800023b8:	e9458593          	addi	a1,a1,-364 # 80007248 <etext+0x248>
    800023bc:	00016517          	auipc	a0,0x16
    800023c0:	d3c50513          	addi	a0,a0,-708 # 800180f8 <tickslock>
    800023c4:	f68fe0ef          	jal	80000b2c <initlock>
}
    800023c8:	60a2                	ld	ra,8(sp)
    800023ca:	6402                	ld	s0,0(sp)
    800023cc:	0141                	addi	sp,sp,16
    800023ce:	8082                	ret

00000000800023d0 <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    800023d0:	1141                	addi	sp,sp,-16
    800023d2:	e422                	sd	s0,8(sp)
    800023d4:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r"(x));
    800023d6:	00003797          	auipc	a5,0x3
    800023da:	fba78793          	addi	a5,a5,-70 # 80005390 <kernelvec>
    800023de:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    800023e2:	6422                	ld	s0,8(sp)
    800023e4:	0141                	addi	sp,sp,16
    800023e6:	8082                	ret

00000000800023e8 <prepare_return>:
//
// set up trapframe and control registers for a return to user space
//
void
prepare_return(void)
{
    800023e8:	1141                	addi	sp,sp,-16
    800023ea:	e406                	sd	ra,8(sp)
    800023ec:	e022                	sd	s0,0(sp)
    800023ee:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    800023f0:	cb4ff0ef          	jal	800018a4 <myproc>
  asm volatile("csrr %0, sstatus" : "=r"(x));
    800023f4:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    800023f8:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r"(x));
    800023fa:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(). because a trap from kernel
  // code to usertrap would be a disaster, turn off interrupts.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    800023fe:	04000737          	lui	a4,0x4000
    80002402:	177d                	addi	a4,a4,-1 # 3ffffff <_entry-0x7c000001>
    80002404:	0732                	slli	a4,a4,0xc
    80002406:	00004797          	auipc	a5,0x4
    8000240a:	bfa78793          	addi	a5,a5,-1030 # 80006000 <_trampoline>
    8000240e:	00004697          	auipc	a3,0x4
    80002412:	bf268693          	addi	a3,a3,-1038 # 80006000 <_trampoline>
    80002416:	8f95                	sub	a5,a5,a3
    80002418:	97ba                	add	a5,a5,a4
  asm volatile("csrw stvec, %0" : : "r"(x));
    8000241a:	10579073          	csrw	stvec,a5
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    8000241e:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, satp" : "=r"(x));
    80002420:	18002773          	csrr	a4,satp
    80002424:	e398                	sd	a4,0(a5)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    80002426:	6d38                	ld	a4,88(a0)
    80002428:	613c                	ld	a5,64(a0)
    8000242a:	6685                	lui	a3,0x1
    8000242c:	97b6                	add	a5,a5,a3
    8000242e:	e71c                	sd	a5,8(a4)
  p->trapframe->kernel_trap = (uint64)usertrap;
    80002430:	6d3c                	ld	a5,88(a0)
    80002432:	00000717          	auipc	a4,0x0
    80002436:	0f870713          	addi	a4,a4,248 # 8000252a <usertrap>
    8000243a:	eb98                	sd	a4,16(a5)
  p->trapframe->kernel_hartid = r_tp(); // hartid for cpuid()
    8000243c:	6d3c                	ld	a5,88(a0)
  asm volatile("mv %0, tp" : "=r"(x));
    8000243e:	8712                	mv	a4,tp
    80002440:	f398                	sd	a4,32(a5)
  asm volatile("csrr %0, sstatus" : "=r"(x));
    80002442:	100027f3          	csrr	a5,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.

  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    80002446:	eff7f793          	andi	a5,a5,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    8000244a:	0207e793          	ori	a5,a5,32
  asm volatile("csrw sstatus, %0" : : "r"(x));
    8000244e:	10079073          	csrw	sstatus,a5
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    80002452:	6d3c                	ld	a5,88(a0)
  asm volatile("csrw sepc, %0" : : "r"(x));
    80002454:	6f9c                	ld	a5,24(a5)
    80002456:	14179073          	csrw	sepc,a5
}
    8000245a:	60a2                	ld	ra,8(sp)
    8000245c:	6402                	ld	s0,0(sp)
    8000245e:	0141                	addi	sp,sp,16
    80002460:	8082                	ret

0000000080002462 <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    80002462:	1101                	addi	sp,sp,-32
    80002464:	ec06                	sd	ra,24(sp)
    80002466:	e822                	sd	s0,16(sp)
    80002468:	1000                	addi	s0,sp,32
  if (cpuid() == 0) {
    8000246a:	c0eff0ef          	jal	80001878 <cpuid>
    8000246e:	cd11                	beqz	a0,8000248a <clockintr+0x28>
  asm volatile("csrr %0, time" : "=r"(x));
    80002470:	c01027f3          	rdtime	a5
  }

  // ask for the next timer interrupt. this also clears
  // the interrupt request. 1000000 is about a tenth
  // of a second.
  w_stimecmp(r_time() + 1000000);
    80002474:	000f4737          	lui	a4,0xf4
    80002478:	24070713          	addi	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    8000247c:	97ba                	add	a5,a5,a4
  asm volatile("csrw 0x14d, %0" : : "r"(x));
    8000247e:	14d79073          	csrw	stimecmp,a5
}
    80002482:	60e2                	ld	ra,24(sp)
    80002484:	6442                	ld	s0,16(sp)
    80002486:	6105                	addi	sp,sp,32
    80002488:	8082                	ret
    8000248a:	e426                	sd	s1,8(sp)
    acquire(&tickslock);
    8000248c:	00016497          	auipc	s1,0x16
    80002490:	c6c48493          	addi	s1,s1,-916 # 800180f8 <tickslock>
    80002494:	8526                	mv	a0,s1
    80002496:	f16fe0ef          	jal	80000bac <acquire>
    ticks++;
    8000249a:	00008517          	auipc	a0,0x8
    8000249e:	d2e50513          	addi	a0,a0,-722 # 8000a1c8 <ticks>
    800024a2:	411c                	lw	a5,0(a0)
    800024a4:	2785                	addiw	a5,a5,1
    800024a6:	c11c                	sw	a5,0(a0)
    wakeup(&ticks);
    800024a8:	a53ff0ef          	jal	80001efa <wakeup>
    release(&tickslock);
    800024ac:	8526                	mv	a0,s1
    800024ae:	f92fe0ef          	jal	80000c40 <release>
    800024b2:	64a2                	ld	s1,8(sp)
    800024b4:	bf75                	j	80002470 <clockintr+0xe>

00000000800024b6 <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    800024b6:	1101                	addi	sp,sp,-32
    800024b8:	ec06                	sd	ra,24(sp)
    800024ba:	e822                	sd	s0,16(sp)
    800024bc:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r"(x));
    800024be:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if (scause == 0x8000000000000009L) {
    800024c2:	57fd                	li	a5,-1
    800024c4:	17fe                	slli	a5,a5,0x3f
    800024c6:	07a5                	addi	a5,a5,9
    800024c8:	00f70c63          	beq	a4,a5,800024e0 <devintr+0x2a>
    // now allowed to interrupt again.
    if (irq)
      plic_complete(irq);

    return 1;
  } else if (scause == 0x8000000000000005L) {
    800024cc:	57fd                	li	a5,-1
    800024ce:	17fe                	slli	a5,a5,0x3f
    800024d0:	0795                	addi	a5,a5,5
    // timer interrupt.
    clockintr();
    return 2;
  } else {
    return 0;
    800024d2:	4501                	li	a0,0
  } else if (scause == 0x8000000000000005L) {
    800024d4:	04f70763          	beq	a4,a5,80002522 <devintr+0x6c>
  }
}
    800024d8:	60e2                	ld	ra,24(sp)
    800024da:	6442                	ld	s0,16(sp)
    800024dc:	6105                	addi	sp,sp,32
    800024de:	8082                	ret
    800024e0:	e426                	sd	s1,8(sp)
    int irq = plic_claim();
    800024e2:	75b020ef          	jal	8000543c <plic_claim>
    800024e6:	84aa                	mv	s1,a0
    if (irq == UART0_IRQ) {
    800024e8:	47a9                	li	a5,10
    800024ea:	00f50963          	beq	a0,a5,800024fc <devintr+0x46>
    } else if (irq == VIRTIO0_IRQ) {
    800024ee:	4785                	li	a5,1
    800024f0:	00f50963          	beq	a0,a5,80002502 <devintr+0x4c>
    return 1;
    800024f4:	4505                	li	a0,1
    } else if (irq) {
    800024f6:	e889                	bnez	s1,80002508 <devintr+0x52>
    800024f8:	64a2                	ld	s1,8(sp)
    800024fa:	bff9                	j	800024d8 <devintr+0x22>
      uartintr();
    800024fc:	c82fe0ef          	jal	8000097e <uartintr>
    if (irq)
    80002500:	a819                	j	80002516 <devintr+0x60>
      virtio_disk_intr();
    80002502:	400030ef          	jal	80005902 <virtio_disk_intr>
    if (irq)
    80002506:	a801                	j	80002516 <devintr+0x60>
      printk("unexpected interrupt irq=%d\n", irq);
    80002508:	85a6                	mv	a1,s1
    8000250a:	00005517          	auipc	a0,0x5
    8000250e:	d4650513          	addi	a0,a0,-698 # 80007250 <etext+0x250>
    80002512:	fddfd0ef          	jal	800004ee <printk>
      plic_complete(irq);
    80002516:	8526                	mv	a0,s1
    80002518:	745020ef          	jal	8000545c <plic_complete>
    return 1;
    8000251c:	4505                	li	a0,1
    8000251e:	64a2                	ld	s1,8(sp)
    80002520:	bf65                	j	800024d8 <devintr+0x22>
    clockintr();
    80002522:	f41ff0ef          	jal	80002462 <clockintr>
    return 2;
    80002526:	4509                	li	a0,2
    80002528:	bf45                	j	800024d8 <devintr+0x22>

000000008000252a <usertrap>:
{
    8000252a:	1101                	addi	sp,sp,-32
    8000252c:	ec06                	sd	ra,24(sp)
    8000252e:	e822                	sd	s0,16(sp)
    80002530:	e426                	sd	s1,8(sp)
    80002532:	e04a                	sd	s2,0(sp)
    80002534:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r"(x));
    80002536:	100027f3          	csrr	a5,sstatus
  if ((r_sstatus() & SSTATUS_SPP) != 0)
    8000253a:	1007f793          	andi	a5,a5,256
    8000253e:	eba5                	bnez	a5,800025ae <usertrap+0x84>
  asm volatile("csrw stvec, %0" : : "r"(x));
    80002540:	00003797          	auipc	a5,0x3
    80002544:	e5078793          	addi	a5,a5,-432 # 80005390 <kernelvec>
    80002548:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    8000254c:	b58ff0ef          	jal	800018a4 <myproc>
    80002550:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    80002552:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r"(x));
    80002554:	14102773          	csrr	a4,sepc
    80002558:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r"(x));
    8000255a:	14202773          	csrr	a4,scause
  if (r_scause() == 8) {
    8000255e:	47a1                	li	a5,8
    80002560:	04f70d63          	beq	a4,a5,800025ba <usertrap+0x90>
  } else if ((which_dev = devintr()) != 0) {
    80002564:	f53ff0ef          	jal	800024b6 <devintr>
    80002568:	892a                	mv	s2,a0
    8000256a:	e945                	bnez	a0,8000261a <usertrap+0xf0>
    8000256c:	14202773          	csrr	a4,scause
  } else if ((r_scause() == 15 || r_scause() == 13) &&
    80002570:	47bd                	li	a5,15
    80002572:	08f70863          	beq	a4,a5,80002602 <usertrap+0xd8>
    80002576:	14202773          	csrr	a4,scause
    8000257a:	47b5                	li	a5,13
    8000257c:	08f70363          	beq	a4,a5,80002602 <usertrap+0xd8>
    80002580:	142025f3          	csrr	a1,scause
    printk("usertrap(): unexpected scause 0x%lx pid=%d\n", r_scause(), p->pid);
    80002584:	5890                	lw	a2,48(s1)
    80002586:	00005517          	auipc	a0,0x5
    8000258a:	d0a50513          	addi	a0,a0,-758 # 80007290 <etext+0x290>
    8000258e:	f61fd0ef          	jal	800004ee <printk>
  asm volatile("csrr %0, sepc" : "=r"(x));
    80002592:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r"(x));
    80002596:	14302673          	csrr	a2,stval
    printk("            sepc=0x%lx stval=0x%lx\n", r_sepc(), r_stval());
    8000259a:	00005517          	auipc	a0,0x5
    8000259e:	d2650513          	addi	a0,a0,-730 # 800072c0 <etext+0x2c0>
    800025a2:	f4dfd0ef          	jal	800004ee <printk>
    setkilled(p);
    800025a6:	8526                	mv	a0,s1
    800025a8:	b1bff0ef          	jal	800020c2 <setkilled>
    800025ac:	a035                	j	800025d8 <usertrap+0xae>
    panic("usertrap: not from user mode");
    800025ae:	00005517          	auipc	a0,0x5
    800025b2:	cc250513          	addi	a0,a0,-830 # 80007270 <etext+0x270>
    800025b6:	a1efe0ef          	jal	800007d4 <panic>
    if (killed(p))
    800025ba:	b2dff0ef          	jal	800020e6 <killed>
    800025be:	ed15                	bnez	a0,800025fa <usertrap+0xd0>
    p->trapframe->epc += 4;
    800025c0:	6cb8                	ld	a4,88(s1)
    800025c2:	6f1c                	ld	a5,24(a4)
    800025c4:	0791                	addi	a5,a5,4
    800025c6:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r"(x));
    800025c8:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    800025cc:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r"(x));
    800025d0:	10079073          	csrw	sstatus,a5
    syscall();
    800025d4:	246000ef          	jal	8000281a <syscall>
  if (killed(p))
    800025d8:	8526                	mv	a0,s1
    800025da:	b0dff0ef          	jal	800020e6 <killed>
    800025de:	e139                	bnez	a0,80002624 <usertrap+0xfa>
  prepare_return();
    800025e0:	e09ff0ef          	jal	800023e8 <prepare_return>
  uint64 satp = MAKE_SATP(p->pagetable);
    800025e4:	68a8                	ld	a0,80(s1)
    800025e6:	8131                	srli	a0,a0,0xc
    800025e8:	57fd                	li	a5,-1
    800025ea:	17fe                	slli	a5,a5,0x3f
    800025ec:	8d5d                	or	a0,a0,a5
}
    800025ee:	60e2                	ld	ra,24(sp)
    800025f0:	6442                	ld	s0,16(sp)
    800025f2:	64a2                	ld	s1,8(sp)
    800025f4:	6902                	ld	s2,0(sp)
    800025f6:	6105                	addi	sp,sp,32
    800025f8:	8082                	ret
      kexit(-1);
    800025fa:	557d                	li	a0,-1
    800025fc:	9bfff0ef          	jal	80001fba <kexit>
    80002600:	b7c1                	j	800025c0 <usertrap+0x96>
  asm volatile("csrr %0, stval" : "=r"(x));
    80002602:	143025f3          	csrr	a1,stval
  asm volatile("csrr %0, scause" : "=r"(x));
    80002606:	14202673          	csrr	a2,scause
             vmfault(p->pagetable, r_stval(), (r_scause() == 13) ? 1 : 0) !=
    8000260a:	164d                	addi	a2,a2,-13 # ff3 <_entry-0x7ffff00d>
    8000260c:	00163613          	seqz	a2,a2
    80002610:	68a8                	ld	a0,80(s1)
    80002612:	f25fe0ef          	jal	80001536 <vmfault>
  } else if ((r_scause() == 15 || r_scause() == 13) &&
    80002616:	f169                	bnez	a0,800025d8 <usertrap+0xae>
    80002618:	b7a5                	j	80002580 <usertrap+0x56>
  if (killed(p))
    8000261a:	8526                	mv	a0,s1
    8000261c:	acbff0ef          	jal	800020e6 <killed>
    80002620:	c511                	beqz	a0,8000262c <usertrap+0x102>
    80002622:	a011                	j	80002626 <usertrap+0xfc>
    80002624:	4901                	li	s2,0
    kexit(-1);
    80002626:	557d                	li	a0,-1
    80002628:	993ff0ef          	jal	80001fba <kexit>
  if (which_dev == 2)
    8000262c:	4789                	li	a5,2
    8000262e:	faf919e3          	bne	s2,a5,800025e0 <usertrap+0xb6>
    yield();
    80002632:	851ff0ef          	jal	80001e82 <yield>
    80002636:	b76d                	j	800025e0 <usertrap+0xb6>

0000000080002638 <kerneltrap>:
{
    80002638:	7179                	addi	sp,sp,-48
    8000263a:	f406                	sd	ra,40(sp)
    8000263c:	f022                	sd	s0,32(sp)
    8000263e:	ec26                	sd	s1,24(sp)
    80002640:	e84a                	sd	s2,16(sp)
    80002642:	e44e                	sd	s3,8(sp)
    80002644:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r"(x));
    80002646:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r"(x));
    8000264a:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r"(x));
    8000264e:	142029f3          	csrr	s3,scause
  if ((sstatus & SSTATUS_SPP) == 0)
    80002652:	1004f793          	andi	a5,s1,256
    80002656:	c795                	beqz	a5,80002682 <kerneltrap+0x4a>
  asm volatile("csrr %0, sstatus" : "=r"(x));
    80002658:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    8000265c:	8b89                	andi	a5,a5,2
  if (intr_get() != 0)
    8000265e:	eb85                	bnez	a5,8000268e <kerneltrap+0x56>
  if ((which_dev = devintr()) == 0) {
    80002660:	e57ff0ef          	jal	800024b6 <devintr>
    80002664:	c91d                	beqz	a0,8000269a <kerneltrap+0x62>
  if (which_dev == 2 && myproc() != 0)
    80002666:	4789                	li	a5,2
    80002668:	04f50a63          	beq	a0,a5,800026bc <kerneltrap+0x84>
  asm volatile("csrw sepc, %0" : : "r"(x));
    8000266c:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r"(x));
    80002670:	10049073          	csrw	sstatus,s1
}
    80002674:	70a2                	ld	ra,40(sp)
    80002676:	7402                	ld	s0,32(sp)
    80002678:	64e2                	ld	s1,24(sp)
    8000267a:	6942                	ld	s2,16(sp)
    8000267c:	69a2                	ld	s3,8(sp)
    8000267e:	6145                	addi	sp,sp,48
    80002680:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80002682:	00005517          	auipc	a0,0x5
    80002686:	c6650513          	addi	a0,a0,-922 # 800072e8 <etext+0x2e8>
    8000268a:	94afe0ef          	jal	800007d4 <panic>
    panic("kerneltrap: interrupts enabled");
    8000268e:	00005517          	auipc	a0,0x5
    80002692:	c8250513          	addi	a0,a0,-894 # 80007310 <etext+0x310>
    80002696:	93efe0ef          	jal	800007d4 <panic>
  asm volatile("csrr %0, sepc" : "=r"(x));
    8000269a:	14102673          	csrr	a2,sepc
  asm volatile("csrr %0, stval" : "=r"(x));
    8000269e:	143026f3          	csrr	a3,stval
    printk("scause=0x%lx sepc=0x%lx stval=0x%lx\n", scause, r_sepc(),
    800026a2:	85ce                	mv	a1,s3
    800026a4:	00005517          	auipc	a0,0x5
    800026a8:	c8c50513          	addi	a0,a0,-884 # 80007330 <etext+0x330>
    800026ac:	e43fd0ef          	jal	800004ee <printk>
    panic("kerneltrap");
    800026b0:	00005517          	auipc	a0,0x5
    800026b4:	ca850513          	addi	a0,a0,-856 # 80007358 <etext+0x358>
    800026b8:	91cfe0ef          	jal	800007d4 <panic>
  if (which_dev == 2 && myproc() != 0)
    800026bc:	9e8ff0ef          	jal	800018a4 <myproc>
    800026c0:	d555                	beqz	a0,8000266c <kerneltrap+0x34>
    yield();
    800026c2:	fc0ff0ef          	jal	80001e82 <yield>
    800026c6:	b75d                	j	8000266c <kerneltrap+0x34>

00000000800026c8 <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    800026c8:	1101                	addi	sp,sp,-32
    800026ca:	ec06                	sd	ra,24(sp)
    800026cc:	e822                	sd	s0,16(sp)
    800026ce:	e426                	sd	s1,8(sp)
    800026d0:	1000                	addi	s0,sp,32
    800026d2:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    800026d4:	9d0ff0ef          	jal	800018a4 <myproc>
  switch (n) {
    800026d8:	4795                	li	a5,5
    800026da:	0497e163          	bltu	a5,s1,8000271c <argraw+0x54>
    800026de:	048a                	slli	s1,s1,0x2
    800026e0:	00005717          	auipc	a4,0x5
    800026e4:	07870713          	addi	a4,a4,120 # 80007758 <states.0+0x30>
    800026e8:	94ba                	add	s1,s1,a4
    800026ea:	409c                	lw	a5,0(s1)
    800026ec:	97ba                	add	a5,a5,a4
    800026ee:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    800026f0:	6d3c                	ld	a5,88(a0)
    800026f2:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    800026f4:	60e2                	ld	ra,24(sp)
    800026f6:	6442                	ld	s0,16(sp)
    800026f8:	64a2                	ld	s1,8(sp)
    800026fa:	6105                	addi	sp,sp,32
    800026fc:	8082                	ret
    return p->trapframe->a1;
    800026fe:	6d3c                	ld	a5,88(a0)
    80002700:	7fa8                	ld	a0,120(a5)
    80002702:	bfcd                	j	800026f4 <argraw+0x2c>
    return p->trapframe->a2;
    80002704:	6d3c                	ld	a5,88(a0)
    80002706:	63c8                	ld	a0,128(a5)
    80002708:	b7f5                	j	800026f4 <argraw+0x2c>
    return p->trapframe->a3;
    8000270a:	6d3c                	ld	a5,88(a0)
    8000270c:	67c8                	ld	a0,136(a5)
    8000270e:	b7dd                	j	800026f4 <argraw+0x2c>
    return p->trapframe->a4;
    80002710:	6d3c                	ld	a5,88(a0)
    80002712:	6bc8                	ld	a0,144(a5)
    80002714:	b7c5                	j	800026f4 <argraw+0x2c>
    return p->trapframe->a5;
    80002716:	6d3c                	ld	a5,88(a0)
    80002718:	6fc8                	ld	a0,152(a5)
    8000271a:	bfe9                	j	800026f4 <argraw+0x2c>
  panic("argraw");
    8000271c:	00005517          	auipc	a0,0x5
    80002720:	c4c50513          	addi	a0,a0,-948 # 80007368 <etext+0x368>
    80002724:	8b0fe0ef          	jal	800007d4 <panic>

0000000080002728 <fetchaddr>:
{
    80002728:	1101                	addi	sp,sp,-32
    8000272a:	ec06                	sd	ra,24(sp)
    8000272c:	e822                	sd	s0,16(sp)
    8000272e:	e426                	sd	s1,8(sp)
    80002730:	e04a                	sd	s2,0(sp)
    80002732:	1000                	addi	s0,sp,32
    80002734:	84aa                	mv	s1,a0
    80002736:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002738:	96cff0ef          	jal	800018a4 <myproc>
  if (addr >= p->sz ||
    8000273c:	653c                	ld	a5,72(a0)
    8000273e:	02f4f663          	bgeu	s1,a5,8000276a <fetchaddr+0x42>
      addr + sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    80002742:	00848713          	addi	a4,s1,8
  if (addr >= p->sz ||
    80002746:	02e7e463          	bltu	a5,a4,8000276e <fetchaddr+0x46>
  if (copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    8000274a:	46a1                	li	a3,8
    8000274c:	8626                	mv	a2,s1
    8000274e:	85ca                	mv	a1,s2
    80002750:	6928                	ld	a0,80(a0)
    80002752:	f4bfe0ef          	jal	8000169c <copyin>
    80002756:	00a03533          	snez	a0,a0
    8000275a:	40a00533          	neg	a0,a0
}
    8000275e:	60e2                	ld	ra,24(sp)
    80002760:	6442                	ld	s0,16(sp)
    80002762:	64a2                	ld	s1,8(sp)
    80002764:	6902                	ld	s2,0(sp)
    80002766:	6105                	addi	sp,sp,32
    80002768:	8082                	ret
    return -1;
    8000276a:	557d                	li	a0,-1
    8000276c:	bfcd                	j	8000275e <fetchaddr+0x36>
    8000276e:	557d                	li	a0,-1
    80002770:	b7fd                	j	8000275e <fetchaddr+0x36>

0000000080002772 <fetchstr>:
{
    80002772:	7179                	addi	sp,sp,-48
    80002774:	f406                	sd	ra,40(sp)
    80002776:	f022                	sd	s0,32(sp)
    80002778:	ec26                	sd	s1,24(sp)
    8000277a:	e84a                	sd	s2,16(sp)
    8000277c:	e44e                	sd	s3,8(sp)
    8000277e:	1800                	addi	s0,sp,48
    80002780:	892a                	mv	s2,a0
    80002782:	84ae                	mv	s1,a1
    80002784:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80002786:	91eff0ef          	jal	800018a4 <myproc>
  if (copyinstr(p->pagetable, buf, addr, max) < 0)
    8000278a:	86ce                	mv	a3,s3
    8000278c:	864a                	mv	a2,s2
    8000278e:	85a6                	mv	a1,s1
    80002790:	6928                	ld	a0,80(a0)
    80002792:	ccdfe0ef          	jal	8000145e <copyinstr>
    80002796:	00054c63          	bltz	a0,800027ae <fetchstr+0x3c>
  return strlen(buf);
    8000279a:	8526                	mv	a0,s1
    8000279c:	e4cfe0ef          	jal	80000de8 <strlen>
}
    800027a0:	70a2                	ld	ra,40(sp)
    800027a2:	7402                	ld	s0,32(sp)
    800027a4:	64e2                	ld	s1,24(sp)
    800027a6:	6942                	ld	s2,16(sp)
    800027a8:	69a2                	ld	s3,8(sp)
    800027aa:	6145                	addi	sp,sp,48
    800027ac:	8082                	ret
    return -1;
    800027ae:	557d                	li	a0,-1
    800027b0:	bfc5                	j	800027a0 <fetchstr+0x2e>

00000000800027b2 <argint>:

// Fetch the nth 32-bit system call argument.
void
argint(int n, int *ip)
{
    800027b2:	1101                	addi	sp,sp,-32
    800027b4:	ec06                	sd	ra,24(sp)
    800027b6:	e822                	sd	s0,16(sp)
    800027b8:	e426                	sd	s1,8(sp)
    800027ba:	1000                	addi	s0,sp,32
    800027bc:	84ae                	mv	s1,a1
  *ip = argraw(n);
    800027be:	f0bff0ef          	jal	800026c8 <argraw>
    800027c2:	c088                	sw	a0,0(s1)
}
    800027c4:	60e2                	ld	ra,24(sp)
    800027c6:	6442                	ld	s0,16(sp)
    800027c8:	64a2                	ld	s1,8(sp)
    800027ca:	6105                	addi	sp,sp,32
    800027cc:	8082                	ret

00000000800027ce <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void
argaddr(int n, uint64 *ip)
{
    800027ce:	1101                	addi	sp,sp,-32
    800027d0:	ec06                	sd	ra,24(sp)
    800027d2:	e822                	sd	s0,16(sp)
    800027d4:	e426                	sd	s1,8(sp)
    800027d6:	1000                	addi	s0,sp,32
    800027d8:	84ae                	mv	s1,a1
  *ip = argraw(n);
    800027da:	eefff0ef          	jal	800026c8 <argraw>
    800027de:	e088                	sd	a0,0(s1)
}
    800027e0:	60e2                	ld	ra,24(sp)
    800027e2:	6442                	ld	s0,16(sp)
    800027e4:	64a2                	ld	s1,8(sp)
    800027e6:	6105                	addi	sp,sp,32
    800027e8:	8082                	ret

00000000800027ea <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (not including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    800027ea:	7179                	addi	sp,sp,-48
    800027ec:	f406                	sd	ra,40(sp)
    800027ee:	f022                	sd	s0,32(sp)
    800027f0:	ec26                	sd	s1,24(sp)
    800027f2:	e84a                	sd	s2,16(sp)
    800027f4:	1800                	addi	s0,sp,48
    800027f6:	84ae                	mv	s1,a1
    800027f8:	8932                	mv	s2,a2
  uint64 addr;
  argaddr(n, &addr);
    800027fa:	fd840593          	addi	a1,s0,-40
    800027fe:	fd1ff0ef          	jal	800027ce <argaddr>
  return fetchstr(addr, buf, max);
    80002802:	864a                	mv	a2,s2
    80002804:	85a6                	mv	a1,s1
    80002806:	fd843503          	ld	a0,-40(s0)
    8000280a:	f69ff0ef          	jal	80002772 <fetchstr>
}
    8000280e:	70a2                	ld	ra,40(sp)
    80002810:	7402                	ld	s0,32(sp)
    80002812:	64e2                	ld	s1,24(sp)
    80002814:	6942                	ld	s2,16(sp)
    80002816:	6145                	addi	sp,sp,48
    80002818:	8082                	ret

000000008000281a <syscall>:
  // clang-format on
};

void
syscall(void)
{
    8000281a:	1101                	addi	sp,sp,-32
    8000281c:	ec06                	sd	ra,24(sp)
    8000281e:	e822                	sd	s0,16(sp)
    80002820:	e426                	sd	s1,8(sp)
    80002822:	e04a                	sd	s2,0(sp)
    80002824:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    80002826:	87eff0ef          	jal	800018a4 <myproc>
    8000282a:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    8000282c:	05853903          	ld	s2,88(a0)
    80002830:	0a893783          	ld	a5,168(s2)
    80002834:	0007869b          	sext.w	a3,a5
  if (num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80002838:	37fd                	addiw	a5,a5,-1
    8000283a:	4755                	li	a4,21
    8000283c:	00f76f63          	bltu	a4,a5,8000285a <syscall+0x40>
    80002840:	00369713          	slli	a4,a3,0x3
    80002844:	00005797          	auipc	a5,0x5
    80002848:	f2c78793          	addi	a5,a5,-212 # 80007770 <syscalls>
    8000284c:	97ba                	add	a5,a5,a4
    8000284e:	639c                	ld	a5,0(a5)
    80002850:	c789                	beqz	a5,8000285a <syscall+0x40>
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
    p->trapframe->a0 = syscalls[num]();
    80002852:	9782                	jalr	a5
    80002854:	06a93823          	sd	a0,112(s2)
    80002858:	a829                	j	80002872 <syscall+0x58>
  } else {
    printk("%d %s: unknown sys call %d\n", p->pid, p->name, num);
    8000285a:	15848613          	addi	a2,s1,344
    8000285e:	588c                	lw	a1,48(s1)
    80002860:	00005517          	auipc	a0,0x5
    80002864:	b1050513          	addi	a0,a0,-1264 # 80007370 <etext+0x370>
    80002868:	c87fd0ef          	jal	800004ee <printk>
    p->trapframe->a0 = -1;
    8000286c:	6cbc                	ld	a5,88(s1)
    8000286e:	577d                	li	a4,-1
    80002870:	fbb8                	sd	a4,112(a5)
  }
}
    80002872:	60e2                	ld	ra,24(sp)
    80002874:	6442                	ld	s0,16(sp)
    80002876:	64a2                	ld	s1,8(sp)
    80002878:	6902                	ld	s2,0(sp)
    8000287a:	6105                	addi	sp,sp,32
    8000287c:	8082                	ret

000000008000287e <sys_exit>:
#include "proc.h"
#include "vm.h"

uint64
sys_exit(void)
{
    8000287e:	1101                	addi	sp,sp,-32
    80002880:	ec06                	sd	ra,24(sp)
    80002882:	e822                	sd	s0,16(sp)
    80002884:	1000                	addi	s0,sp,32
  int n;
  argint(0, &n);
    80002886:	fec40593          	addi	a1,s0,-20
    8000288a:	4501                	li	a0,0
    8000288c:	f27ff0ef          	jal	800027b2 <argint>
  kexit(n);
    80002890:	fec42503          	lw	a0,-20(s0)
    80002894:	f26ff0ef          	jal	80001fba <kexit>
  return 0; // not reached
}
    80002898:	4501                	li	a0,0
    8000289a:	60e2                	ld	ra,24(sp)
    8000289c:	6442                	ld	s0,16(sp)
    8000289e:	6105                	addi	sp,sp,32
    800028a0:	8082                	ret

00000000800028a2 <sys_getpid>:

uint64
sys_getpid(void)
{
    800028a2:	1141                	addi	sp,sp,-16
    800028a4:	e406                	sd	ra,8(sp)
    800028a6:	e022                	sd	s0,0(sp)
    800028a8:	0800                	addi	s0,sp,16
  return myproc()->pid;
    800028aa:	ffbfe0ef          	jal	800018a4 <myproc>
}
    800028ae:	5908                	lw	a0,48(a0)
    800028b0:	60a2                	ld	ra,8(sp)
    800028b2:	6402                	ld	s0,0(sp)
    800028b4:	0141                	addi	sp,sp,16
    800028b6:	8082                	ret

00000000800028b8 <sys_fork>:

uint64
sys_fork(void)
{
    800028b8:	1141                	addi	sp,sp,-16
    800028ba:	e406                	sd	ra,8(sp)
    800028bc:	e022                	sd	s0,0(sp)
    800028be:	0800                	addi	s0,sp,16
  return kfork();
    800028c0:	b48ff0ef          	jal	80001c08 <kfork>
}
    800028c4:	60a2                	ld	ra,8(sp)
    800028c6:	6402                	ld	s0,0(sp)
    800028c8:	0141                	addi	sp,sp,16
    800028ca:	8082                	ret

00000000800028cc <sys_wait>:

uint64
sys_wait(void)
{
    800028cc:	1101                	addi	sp,sp,-32
    800028ce:	ec06                	sd	ra,24(sp)
    800028d0:	e822                	sd	s0,16(sp)
    800028d2:	1000                	addi	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    800028d4:	fe840593          	addi	a1,s0,-24
    800028d8:	4501                	li	a0,0
    800028da:	ef5ff0ef          	jal	800027ce <argaddr>
  return kwait(p);
    800028de:	fe843503          	ld	a0,-24(s0)
    800028e2:	82fff0ef          	jal	80002110 <kwait>
}
    800028e6:	60e2                	ld	ra,24(sp)
    800028e8:	6442                	ld	s0,16(sp)
    800028ea:	6105                	addi	sp,sp,32
    800028ec:	8082                	ret

00000000800028ee <sys_sbrk>:

uint64
sys_sbrk(void)
{
    800028ee:	7179                	addi	sp,sp,-48
    800028f0:	f406                	sd	ra,40(sp)
    800028f2:	f022                	sd	s0,32(sp)
    800028f4:	ec26                	sd	s1,24(sp)
    800028f6:	1800                	addi	s0,sp,48
  uint64 addr;
  int t;
  int n;

  argint(0, &n);
    800028f8:	fd840593          	addi	a1,s0,-40
    800028fc:	4501                	li	a0,0
    800028fe:	eb5ff0ef          	jal	800027b2 <argint>
  argint(1, &t);
    80002902:	fdc40593          	addi	a1,s0,-36
    80002906:	4505                	li	a0,1
    80002908:	eabff0ef          	jal	800027b2 <argint>
  addr = myproc()->sz;
    8000290c:	f99fe0ef          	jal	800018a4 <myproc>
    80002910:	6524                	ld	s1,72(a0)

  if (t == SBRK_EAGER || n < 0) {
    80002912:	fdc42703          	lw	a4,-36(s0)
    80002916:	4785                	li	a5,1
    80002918:	02f70763          	beq	a4,a5,80002946 <sys_sbrk+0x58>
    8000291c:	fd842783          	lw	a5,-40(s0)
    80002920:	0207c363          	bltz	a5,80002946 <sys_sbrk+0x58>
    }
  } else {
    // Lazily allocate memory for this process: increase its memory
    // size but don't allocate memory. If the processes uses the
    // memory, vmfault() will allocate it.
    if (addr + n < addr)
    80002924:	97a6                	add	a5,a5,s1
    80002926:	0297ee63          	bltu	a5,s1,80002962 <sys_sbrk+0x74>
      return -1;
    if (addr + n > TRAPFRAME)
    8000292a:	02000737          	lui	a4,0x2000
    8000292e:	177d                	addi	a4,a4,-1 # 1ffffff <_entry-0x7e000001>
    80002930:	0736                	slli	a4,a4,0xd
    80002932:	02f76a63          	bltu	a4,a5,80002966 <sys_sbrk+0x78>
      return -1;
    myproc()->sz += n;
    80002936:	f6ffe0ef          	jal	800018a4 <myproc>
    8000293a:	fd842703          	lw	a4,-40(s0)
    8000293e:	653c                	ld	a5,72(a0)
    80002940:	97ba                	add	a5,a5,a4
    80002942:	e53c                	sd	a5,72(a0)
    80002944:	a039                	j	80002952 <sys_sbrk+0x64>
    if (growproc(n) < 0) {
    80002946:	fd842503          	lw	a0,-40(s0)
    8000294a:	a5cff0ef          	jal	80001ba6 <growproc>
    8000294e:	00054863          	bltz	a0,8000295e <sys_sbrk+0x70>
  }
  return addr;
}
    80002952:	8526                	mv	a0,s1
    80002954:	70a2                	ld	ra,40(sp)
    80002956:	7402                	ld	s0,32(sp)
    80002958:	64e2                	ld	s1,24(sp)
    8000295a:	6145                	addi	sp,sp,48
    8000295c:	8082                	ret
      return -1;
    8000295e:	54fd                	li	s1,-1
    80002960:	bfcd                	j	80002952 <sys_sbrk+0x64>
      return -1;
    80002962:	54fd                	li	s1,-1
    80002964:	b7fd                	j	80002952 <sys_sbrk+0x64>
      return -1;
    80002966:	54fd                	li	s1,-1
    80002968:	b7ed                	j	80002952 <sys_sbrk+0x64>

000000008000296a <sys_pause>:

uint64
sys_pause(void)
{
    8000296a:	7139                	addi	sp,sp,-64
    8000296c:	fc06                	sd	ra,56(sp)
    8000296e:	f822                	sd	s0,48(sp)
    80002970:	f04a                	sd	s2,32(sp)
    80002972:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    80002974:	fcc40593          	addi	a1,s0,-52
    80002978:	4501                	li	a0,0
    8000297a:	e39ff0ef          	jal	800027b2 <argint>
  if (n < 0)
    8000297e:	fcc42783          	lw	a5,-52(s0)
    80002982:	0607c763          	bltz	a5,800029f0 <sys_pause+0x86>
    n = 0;
  acquire(&tickslock);
    80002986:	00015517          	auipc	a0,0x15
    8000298a:	77250513          	addi	a0,a0,1906 # 800180f8 <tickslock>
    8000298e:	a1efe0ef          	jal	80000bac <acquire>
  ticks0 = ticks;
    80002992:	00008917          	auipc	s2,0x8
    80002996:	83692903          	lw	s2,-1994(s2) # 8000a1c8 <ticks>
  while (ticks - ticks0 < n) {
    8000299a:	fcc42783          	lw	a5,-52(s0)
    8000299e:	cf8d                	beqz	a5,800029d8 <sys_pause+0x6e>
    800029a0:	f426                	sd	s1,40(sp)
    800029a2:	ec4e                	sd	s3,24(sp)
    if (killed(myproc())) {
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    800029a4:	00015997          	auipc	s3,0x15
    800029a8:	75498993          	addi	s3,s3,1876 # 800180f8 <tickslock>
    800029ac:	00008497          	auipc	s1,0x8
    800029b0:	81c48493          	addi	s1,s1,-2020 # 8000a1c8 <ticks>
    if (killed(myproc())) {
    800029b4:	ef1fe0ef          	jal	800018a4 <myproc>
    800029b8:	f2eff0ef          	jal	800020e6 <killed>
    800029bc:	ed0d                	bnez	a0,800029f6 <sys_pause+0x8c>
    sleep(&ticks, &tickslock);
    800029be:	85ce                	mv	a1,s3
    800029c0:	8526                	mv	a0,s1
    800029c2:	cecff0ef          	jal	80001eae <sleep>
  while (ticks - ticks0 < n) {
    800029c6:	409c                	lw	a5,0(s1)
    800029c8:	412787bb          	subw	a5,a5,s2
    800029cc:	fcc42703          	lw	a4,-52(s0)
    800029d0:	fee7e2e3          	bltu	a5,a4,800029b4 <sys_pause+0x4a>
    800029d4:	74a2                	ld	s1,40(sp)
    800029d6:	69e2                	ld	s3,24(sp)
  }
  release(&tickslock);
    800029d8:	00015517          	auipc	a0,0x15
    800029dc:	72050513          	addi	a0,a0,1824 # 800180f8 <tickslock>
    800029e0:	a60fe0ef          	jal	80000c40 <release>
  return 0;
    800029e4:	4501                	li	a0,0
}
    800029e6:	70e2                	ld	ra,56(sp)
    800029e8:	7442                	ld	s0,48(sp)
    800029ea:	7902                	ld	s2,32(sp)
    800029ec:	6121                	addi	sp,sp,64
    800029ee:	8082                	ret
    n = 0;
    800029f0:	fc042623          	sw	zero,-52(s0)
    800029f4:	bf49                	j	80002986 <sys_pause+0x1c>
      release(&tickslock);
    800029f6:	00015517          	auipc	a0,0x15
    800029fa:	70250513          	addi	a0,a0,1794 # 800180f8 <tickslock>
    800029fe:	a42fe0ef          	jal	80000c40 <release>
      return -1;
    80002a02:	557d                	li	a0,-1
    80002a04:	74a2                	ld	s1,40(sp)
    80002a06:	69e2                	ld	s3,24(sp)
    80002a08:	bff9                	j	800029e6 <sys_pause+0x7c>

0000000080002a0a <sys_kill>:

uint64
sys_kill(void)
{
    80002a0a:	1101                	addi	sp,sp,-32
    80002a0c:	ec06                	sd	ra,24(sp)
    80002a0e:	e822                	sd	s0,16(sp)
    80002a10:	1000                	addi	s0,sp,32
  int pid;

  argint(0, &pid);
    80002a12:	fec40593          	addi	a1,s0,-20
    80002a16:	4501                	li	a0,0
    80002a18:	d9bff0ef          	jal	800027b2 <argint>
  return kkill(pid);
    80002a1c:	fec42503          	lw	a0,-20(s0)
    80002a20:	e3cff0ef          	jal	8000205c <kkill>
}
    80002a24:	60e2                	ld	ra,24(sp)
    80002a26:	6442                	ld	s0,16(sp)
    80002a28:	6105                	addi	sp,sp,32
    80002a2a:	8082                	ret

0000000080002a2c <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80002a2c:	1101                	addi	sp,sp,-32
    80002a2e:	ec06                	sd	ra,24(sp)
    80002a30:	e822                	sd	s0,16(sp)
    80002a32:	e426                	sd	s1,8(sp)
    80002a34:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80002a36:	00015517          	auipc	a0,0x15
    80002a3a:	6c250513          	addi	a0,a0,1730 # 800180f8 <tickslock>
    80002a3e:	96efe0ef          	jal	80000bac <acquire>
  xticks = ticks;
    80002a42:	00007497          	auipc	s1,0x7
    80002a46:	7864a483          	lw	s1,1926(s1) # 8000a1c8 <ticks>
  release(&tickslock);
    80002a4a:	00015517          	auipc	a0,0x15
    80002a4e:	6ae50513          	addi	a0,a0,1710 # 800180f8 <tickslock>
    80002a52:	9eefe0ef          	jal	80000c40 <release>
  return xticks;
}
    80002a56:	02049513          	slli	a0,s1,0x20
    80002a5a:	9101                	srli	a0,a0,0x20
    80002a5c:	60e2                	ld	ra,24(sp)
    80002a5e:	6442                	ld	s0,16(sp)
    80002a60:	64a2                	ld	s1,8(sp)
    80002a62:	6105                	addi	sp,sp,32
    80002a64:	8082                	ret

0000000080002a66 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80002a66:	7179                	addi	sp,sp,-48
    80002a68:	f406                	sd	ra,40(sp)
    80002a6a:	f022                	sd	s0,32(sp)
    80002a6c:	ec26                	sd	s1,24(sp)
    80002a6e:	e84a                	sd	s2,16(sp)
    80002a70:	e44e                	sd	s3,8(sp)
    80002a72:	e052                	sd	s4,0(sp)
    80002a74:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80002a76:	00005597          	auipc	a1,0x5
    80002a7a:	91a58593          	addi	a1,a1,-1766 # 80007390 <etext+0x390>
    80002a7e:	00015517          	auipc	a0,0x15
    80002a82:	69250513          	addi	a0,a0,1682 # 80018110 <bcache>
    80002a86:	8a6fe0ef          	jal	80000b2c <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80002a8a:	0001d797          	auipc	a5,0x1d
    80002a8e:	68678793          	addi	a5,a5,1670 # 80020110 <bcache+0x8000>
    80002a92:	0001e717          	auipc	a4,0x1e
    80002a96:	8e670713          	addi	a4,a4,-1818 # 80020378 <bcache+0x8268>
    80002a9a:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80002a9e:	2ae7bc23          	sd	a4,696(a5)
  for (b = bcache.buf; b < bcache.buf + NBUF; b++) {
    80002aa2:	00015497          	auipc	s1,0x15
    80002aa6:	68648493          	addi	s1,s1,1670 # 80018128 <bcache+0x18>
    b->next = bcache.head.next;
    80002aaa:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80002aac:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80002aae:	00005a17          	auipc	s4,0x5
    80002ab2:	8eaa0a13          	addi	s4,s4,-1814 # 80007398 <etext+0x398>
    b->next = bcache.head.next;
    80002ab6:	2b893783          	ld	a5,696(s2)
    80002aba:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80002abc:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80002ac0:	85d2                	mv	a1,s4
    80002ac2:	01048513          	addi	a0,s1,16
    80002ac6:	38a010ef          	jal	80003e50 <initsleeplock>
    bcache.head.next->prev = b;
    80002aca:	2b893783          	ld	a5,696(s2)
    80002ace:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    80002ad0:	2a993c23          	sd	s1,696(s2)
  for (b = bcache.buf; b < bcache.buf + NBUF; b++) {
    80002ad4:	45848493          	addi	s1,s1,1112
    80002ad8:	fd349fe3          	bne	s1,s3,80002ab6 <binit+0x50>
  }
}
    80002adc:	70a2                	ld	ra,40(sp)
    80002ade:	7402                	ld	s0,32(sp)
    80002ae0:	64e2                	ld	s1,24(sp)
    80002ae2:	6942                	ld	s2,16(sp)
    80002ae4:	69a2                	ld	s3,8(sp)
    80002ae6:	6a02                	ld	s4,0(sp)
    80002ae8:	6145                	addi	sp,sp,48
    80002aea:	8082                	ret

0000000080002aec <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf *
bread(uint dev, uint blockno)
{
    80002aec:	7179                	addi	sp,sp,-48
    80002aee:	f406                	sd	ra,40(sp)
    80002af0:	f022                	sd	s0,32(sp)
    80002af2:	ec26                	sd	s1,24(sp)
    80002af4:	e84a                	sd	s2,16(sp)
    80002af6:	e44e                	sd	s3,8(sp)
    80002af8:	1800                	addi	s0,sp,48
    80002afa:	892a                	mv	s2,a0
    80002afc:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    80002afe:	00015517          	auipc	a0,0x15
    80002b02:	61250513          	addi	a0,a0,1554 # 80018110 <bcache>
    80002b06:	8a6fe0ef          	jal	80000bac <acquire>
  for (b = bcache.head.next; b != &bcache.head; b = b->next) {
    80002b0a:	0001e497          	auipc	s1,0x1e
    80002b0e:	8be4b483          	ld	s1,-1858(s1) # 800203c8 <bcache+0x82b8>
    80002b12:	0001e797          	auipc	a5,0x1e
    80002b16:	86678793          	addi	a5,a5,-1946 # 80020378 <bcache+0x8268>
    80002b1a:	02f48b63          	beq	s1,a5,80002b50 <bread+0x64>
    80002b1e:	873e                	mv	a4,a5
    80002b20:	a021                	j	80002b28 <bread+0x3c>
    80002b22:	68a4                	ld	s1,80(s1)
    80002b24:	02e48663          	beq	s1,a4,80002b50 <bread+0x64>
    if (b->dev == dev && b->blockno == blockno) {
    80002b28:	449c                	lw	a5,8(s1)
    80002b2a:	ff279ce3          	bne	a5,s2,80002b22 <bread+0x36>
    80002b2e:	44dc                	lw	a5,12(s1)
    80002b30:	ff3799e3          	bne	a5,s3,80002b22 <bread+0x36>
      b->refcnt++;
    80002b34:	40bc                	lw	a5,64(s1)
    80002b36:	2785                	addiw	a5,a5,1
    80002b38:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002b3a:	00015517          	auipc	a0,0x15
    80002b3e:	5d650513          	addi	a0,a0,1494 # 80018110 <bcache>
    80002b42:	8fefe0ef          	jal	80000c40 <release>
      acquiresleep(&b->lock);
    80002b46:	01048513          	addi	a0,s1,16
    80002b4a:	33c010ef          	jal	80003e86 <acquiresleep>
      return b;
    80002b4e:	a889                	j	80002ba0 <bread+0xb4>
  for (b = bcache.head.prev; b != &bcache.head; b = b->prev) {
    80002b50:	0001e497          	auipc	s1,0x1e
    80002b54:	8704b483          	ld	s1,-1936(s1) # 800203c0 <bcache+0x82b0>
    80002b58:	0001e797          	auipc	a5,0x1e
    80002b5c:	82078793          	addi	a5,a5,-2016 # 80020378 <bcache+0x8268>
    80002b60:	00f48863          	beq	s1,a5,80002b70 <bread+0x84>
    80002b64:	873e                	mv	a4,a5
    if (b->refcnt == 0) {
    80002b66:	40bc                	lw	a5,64(s1)
    80002b68:	cb91                	beqz	a5,80002b7c <bread+0x90>
  for (b = bcache.head.prev; b != &bcache.head; b = b->prev) {
    80002b6a:	64a4                	ld	s1,72(s1)
    80002b6c:	fee49de3          	bne	s1,a4,80002b66 <bread+0x7a>
  panic("bget: no buffers");
    80002b70:	00005517          	auipc	a0,0x5
    80002b74:	83050513          	addi	a0,a0,-2000 # 800073a0 <etext+0x3a0>
    80002b78:	c5dfd0ef          	jal	800007d4 <panic>
      b->dev = dev;
    80002b7c:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    80002b80:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    80002b84:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80002b88:	4785                	li	a5,1
    80002b8a:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002b8c:	00015517          	auipc	a0,0x15
    80002b90:	58450513          	addi	a0,a0,1412 # 80018110 <bcache>
    80002b94:	8acfe0ef          	jal	80000c40 <release>
      acquiresleep(&b->lock);
    80002b98:	01048513          	addi	a0,s1,16
    80002b9c:	2ea010ef          	jal	80003e86 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if (!b->valid) {
    80002ba0:	409c                	lw	a5,0(s1)
    80002ba2:	cb89                	beqz	a5,80002bb4 <bread+0xc8>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    80002ba4:	8526                	mv	a0,s1
    80002ba6:	70a2                	ld	ra,40(sp)
    80002ba8:	7402                	ld	s0,32(sp)
    80002baa:	64e2                	ld	s1,24(sp)
    80002bac:	6942                	ld	s2,16(sp)
    80002bae:	69a2                	ld	s3,8(sp)
    80002bb0:	6145                	addi	sp,sp,48
    80002bb2:	8082                	ret
    virtio_disk_rw(b, 0);
    80002bb4:	4581                	li	a1,0
    80002bb6:	8526                	mv	a0,s1
    80002bb8:	339020ef          	jal	800056f0 <virtio_disk_rw>
    b->valid = 1;
    80002bbc:	4785                	li	a5,1
    80002bbe:	c09c                	sw	a5,0(s1)
  return b;
    80002bc0:	b7d5                	j	80002ba4 <bread+0xb8>

0000000080002bc2 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    80002bc2:	1101                	addi	sp,sp,-32
    80002bc4:	ec06                	sd	ra,24(sp)
    80002bc6:	e822                	sd	s0,16(sp)
    80002bc8:	e426                	sd	s1,8(sp)
    80002bca:	1000                	addi	s0,sp,32
    80002bcc:	84aa                	mv	s1,a0
  if (!holdingsleep(&b->lock))
    80002bce:	0541                	addi	a0,a0,16
    80002bd0:	334010ef          	jal	80003f04 <holdingsleep>
    80002bd4:	c911                	beqz	a0,80002be8 <bwrite+0x26>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    80002bd6:	4585                	li	a1,1
    80002bd8:	8526                	mv	a0,s1
    80002bda:	317020ef          	jal	800056f0 <virtio_disk_rw>
}
    80002bde:	60e2                	ld	ra,24(sp)
    80002be0:	6442                	ld	s0,16(sp)
    80002be2:	64a2                	ld	s1,8(sp)
    80002be4:	6105                	addi	sp,sp,32
    80002be6:	8082                	ret
    panic("bwrite");
    80002be8:	00004517          	auipc	a0,0x4
    80002bec:	7d050513          	addi	a0,a0,2000 # 800073b8 <etext+0x3b8>
    80002bf0:	be5fd0ef          	jal	800007d4 <panic>

0000000080002bf4 <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    80002bf4:	1101                	addi	sp,sp,-32
    80002bf6:	ec06                	sd	ra,24(sp)
    80002bf8:	e822                	sd	s0,16(sp)
    80002bfa:	e426                	sd	s1,8(sp)
    80002bfc:	e04a                	sd	s2,0(sp)
    80002bfe:	1000                	addi	s0,sp,32
    80002c00:	84aa                	mv	s1,a0
  if (!holdingsleep(&b->lock))
    80002c02:	01050913          	addi	s2,a0,16
    80002c06:	854a                	mv	a0,s2
    80002c08:	2fc010ef          	jal	80003f04 <holdingsleep>
    80002c0c:	c135                	beqz	a0,80002c70 <brelse+0x7c>
    panic("brelse");

  releasesleep(&b->lock);
    80002c0e:	854a                	mv	a0,s2
    80002c10:	2bc010ef          	jal	80003ecc <releasesleep>

  acquire(&bcache.lock);
    80002c14:	00015517          	auipc	a0,0x15
    80002c18:	4fc50513          	addi	a0,a0,1276 # 80018110 <bcache>
    80002c1c:	f91fd0ef          	jal	80000bac <acquire>
  b->refcnt--;
    80002c20:	40bc                	lw	a5,64(s1)
    80002c22:	37fd                	addiw	a5,a5,-1
    80002c24:	0007871b          	sext.w	a4,a5
    80002c28:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    80002c2a:	e71d                	bnez	a4,80002c58 <brelse+0x64>
    // no one is waiting for it.
    b->next->prev = b->prev;
    80002c2c:	68b8                	ld	a4,80(s1)
    80002c2e:	64bc                	ld	a5,72(s1)
    80002c30:	e73c                	sd	a5,72(a4)
    b->prev->next = b->next;
    80002c32:	68b8                	ld	a4,80(s1)
    80002c34:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    80002c36:	0001d797          	auipc	a5,0x1d
    80002c3a:	4da78793          	addi	a5,a5,1242 # 80020110 <bcache+0x8000>
    80002c3e:	2b87b703          	ld	a4,696(a5)
    80002c42:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    80002c44:	0001d717          	auipc	a4,0x1d
    80002c48:	73470713          	addi	a4,a4,1844 # 80020378 <bcache+0x8268>
    80002c4c:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    80002c4e:	2b87b703          	ld	a4,696(a5)
    80002c52:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    80002c54:	2a97bc23          	sd	s1,696(a5)
  }

  release(&bcache.lock);
    80002c58:	00015517          	auipc	a0,0x15
    80002c5c:	4b850513          	addi	a0,a0,1208 # 80018110 <bcache>
    80002c60:	fe1fd0ef          	jal	80000c40 <release>
}
    80002c64:	60e2                	ld	ra,24(sp)
    80002c66:	6442                	ld	s0,16(sp)
    80002c68:	64a2                	ld	s1,8(sp)
    80002c6a:	6902                	ld	s2,0(sp)
    80002c6c:	6105                	addi	sp,sp,32
    80002c6e:	8082                	ret
    panic("brelse");
    80002c70:	00004517          	auipc	a0,0x4
    80002c74:	75050513          	addi	a0,a0,1872 # 800073c0 <etext+0x3c0>
    80002c78:	b5dfd0ef          	jal	800007d4 <panic>

0000000080002c7c <bpin>:

void
bpin(struct buf *b)
{
    80002c7c:	1101                	addi	sp,sp,-32
    80002c7e:	ec06                	sd	ra,24(sp)
    80002c80:	e822                	sd	s0,16(sp)
    80002c82:	e426                	sd	s1,8(sp)
    80002c84:	1000                	addi	s0,sp,32
    80002c86:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80002c88:	00015517          	auipc	a0,0x15
    80002c8c:	48850513          	addi	a0,a0,1160 # 80018110 <bcache>
    80002c90:	f1dfd0ef          	jal	80000bac <acquire>
  b->refcnt++;
    80002c94:	40bc                	lw	a5,64(s1)
    80002c96:	2785                	addiw	a5,a5,1
    80002c98:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80002c9a:	00015517          	auipc	a0,0x15
    80002c9e:	47650513          	addi	a0,a0,1142 # 80018110 <bcache>
    80002ca2:	f9ffd0ef          	jal	80000c40 <release>
}
    80002ca6:	60e2                	ld	ra,24(sp)
    80002ca8:	6442                	ld	s0,16(sp)
    80002caa:	64a2                	ld	s1,8(sp)
    80002cac:	6105                	addi	sp,sp,32
    80002cae:	8082                	ret

0000000080002cb0 <bunpin>:

void
bunpin(struct buf *b)
{
    80002cb0:	1101                	addi	sp,sp,-32
    80002cb2:	ec06                	sd	ra,24(sp)
    80002cb4:	e822                	sd	s0,16(sp)
    80002cb6:	e426                	sd	s1,8(sp)
    80002cb8:	1000                	addi	s0,sp,32
    80002cba:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80002cbc:	00015517          	auipc	a0,0x15
    80002cc0:	45450513          	addi	a0,a0,1108 # 80018110 <bcache>
    80002cc4:	ee9fd0ef          	jal	80000bac <acquire>
  b->refcnt--;
    80002cc8:	40bc                	lw	a5,64(s1)
    80002cca:	37fd                	addiw	a5,a5,-1
    80002ccc:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80002cce:	00015517          	auipc	a0,0x15
    80002cd2:	44250513          	addi	a0,a0,1090 # 80018110 <bcache>
    80002cd6:	f6bfd0ef          	jal	80000c40 <release>
}
    80002cda:	60e2                	ld	ra,24(sp)
    80002cdc:	6442                	ld	s0,16(sp)
    80002cde:	64a2                	ld	s1,8(sp)
    80002ce0:	6105                	addi	sp,sp,32
    80002ce2:	8082                	ret

0000000080002ce4 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    80002ce4:	1101                	addi	sp,sp,-32
    80002ce6:	ec06                	sd	ra,24(sp)
    80002ce8:	e822                	sd	s0,16(sp)
    80002cea:	e426                	sd	s1,8(sp)
    80002cec:	e04a                	sd	s2,0(sp)
    80002cee:	1000                	addi	s0,sp,32
    80002cf0:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    80002cf2:	00d5d59b          	srliw	a1,a1,0xd
    80002cf6:	0001e797          	auipc	a5,0x1e
    80002cfa:	af67a783          	lw	a5,-1290(a5) # 800207ec <sb+0x1c>
    80002cfe:	9dbd                	addw	a1,a1,a5
    80002d00:	dedff0ef          	jal	80002aec <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    80002d04:	0074f713          	andi	a4,s1,7
    80002d08:	4785                	li	a5,1
    80002d0a:	00e797bb          	sllw	a5,a5,a4
  if ((bp->data[bi / 8] & m) == 0)
    80002d0e:	14ce                	slli	s1,s1,0x33
    80002d10:	90d9                	srli	s1,s1,0x36
    80002d12:	00950733          	add	a4,a0,s1
    80002d16:	05874703          	lbu	a4,88(a4)
    80002d1a:	00e7f6b3          	and	a3,a5,a4
    80002d1e:	c29d                	beqz	a3,80002d44 <bfree+0x60>
    80002d20:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi / 8] &= ~m;
    80002d22:	94aa                	add	s1,s1,a0
    80002d24:	fff7c793          	not	a5,a5
    80002d28:	8f7d                	and	a4,a4,a5
    80002d2a:	04e48c23          	sb	a4,88(s1)
  log_write(bp);
    80002d2e:	7ff000ef          	jal	80003d2c <log_write>
  brelse(bp);
    80002d32:	854a                	mv	a0,s2
    80002d34:	ec1ff0ef          	jal	80002bf4 <brelse>
}
    80002d38:	60e2                	ld	ra,24(sp)
    80002d3a:	6442                	ld	s0,16(sp)
    80002d3c:	64a2                	ld	s1,8(sp)
    80002d3e:	6902                	ld	s2,0(sp)
    80002d40:	6105                	addi	sp,sp,32
    80002d42:	8082                	ret
    panic("freeing free block");
    80002d44:	00004517          	auipc	a0,0x4
    80002d48:	68450513          	addi	a0,a0,1668 # 800073c8 <etext+0x3c8>
    80002d4c:	a89fd0ef          	jal	800007d4 <panic>

0000000080002d50 <balloc>:
{
    80002d50:	711d                	addi	sp,sp,-96
    80002d52:	ec86                	sd	ra,88(sp)
    80002d54:	e8a2                	sd	s0,80(sp)
    80002d56:	e4a6                	sd	s1,72(sp)
    80002d58:	1080                	addi	s0,sp,96
  for (b = 0; b < sb.size; b += BPB) {
    80002d5a:	0001e797          	auipc	a5,0x1e
    80002d5e:	a7a7a783          	lw	a5,-1414(a5) # 800207d4 <sb+0x4>
    80002d62:	0e078f63          	beqz	a5,80002e60 <balloc+0x110>
    80002d66:	e0ca                	sd	s2,64(sp)
    80002d68:	fc4e                	sd	s3,56(sp)
    80002d6a:	f852                	sd	s4,48(sp)
    80002d6c:	f456                	sd	s5,40(sp)
    80002d6e:	f05a                	sd	s6,32(sp)
    80002d70:	ec5e                	sd	s7,24(sp)
    80002d72:	e862                	sd	s8,16(sp)
    80002d74:	e466                	sd	s9,8(sp)
    80002d76:	8baa                	mv	s7,a0
    80002d78:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    80002d7a:	0001eb17          	auipc	s6,0x1e
    80002d7e:	a56b0b13          	addi	s6,s6,-1450 # 800207d0 <sb>
    for (bi = 0; bi < BPB && b + bi < sb.size; bi++) {
    80002d82:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    80002d84:	4985                	li	s3,1
    for (bi = 0; bi < BPB && b + bi < sb.size; bi++) {
    80002d86:	6a09                	lui	s4,0x2
  for (b = 0; b < sb.size; b += BPB) {
    80002d88:	6c89                	lui	s9,0x2
    80002d8a:	a0b5                	j	80002df6 <balloc+0xa6>
        bp->data[bi / 8] |= m;           // Mark block in use.
    80002d8c:	97ca                	add	a5,a5,s2
    80002d8e:	8e55                	or	a2,a2,a3
    80002d90:	04c78c23          	sb	a2,88(a5)
        log_write(bp);
    80002d94:	854a                	mv	a0,s2
    80002d96:	797000ef          	jal	80003d2c <log_write>
        brelse(bp);
    80002d9a:	854a                	mv	a0,s2
    80002d9c:	e59ff0ef          	jal	80002bf4 <brelse>
  bp = bread(dev, bno);
    80002da0:	85a6                	mv	a1,s1
    80002da2:	855e                	mv	a0,s7
    80002da4:	d49ff0ef          	jal	80002aec <bread>
    80002da8:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    80002daa:	40000613          	li	a2,1024
    80002dae:	4581                	li	a1,0
    80002db0:	05850513          	addi	a0,a0,88
    80002db4:	ec5fd0ef          	jal	80000c78 <memset>
  log_write(bp);
    80002db8:	854a                	mv	a0,s2
    80002dba:	773000ef          	jal	80003d2c <log_write>
  brelse(bp);
    80002dbe:	854a                	mv	a0,s2
    80002dc0:	e35ff0ef          	jal	80002bf4 <brelse>
}
    80002dc4:	6906                	ld	s2,64(sp)
    80002dc6:	79e2                	ld	s3,56(sp)
    80002dc8:	7a42                	ld	s4,48(sp)
    80002dca:	7aa2                	ld	s5,40(sp)
    80002dcc:	7b02                	ld	s6,32(sp)
    80002dce:	6be2                	ld	s7,24(sp)
    80002dd0:	6c42                	ld	s8,16(sp)
    80002dd2:	6ca2                	ld	s9,8(sp)
}
    80002dd4:	8526                	mv	a0,s1
    80002dd6:	60e6                	ld	ra,88(sp)
    80002dd8:	6446                	ld	s0,80(sp)
    80002dda:	64a6                	ld	s1,72(sp)
    80002ddc:	6125                	addi	sp,sp,96
    80002dde:	8082                	ret
    brelse(bp);
    80002de0:	854a                	mv	a0,s2
    80002de2:	e13ff0ef          	jal	80002bf4 <brelse>
  for (b = 0; b < sb.size; b += BPB) {
    80002de6:	015c87bb          	addw	a5,s9,s5
    80002dea:	00078a9b          	sext.w	s5,a5
    80002dee:	004b2703          	lw	a4,4(s6)
    80002df2:	04eaff63          	bgeu	s5,a4,80002e50 <balloc+0x100>
    bp = bread(dev, BBLOCK(b, sb));
    80002df6:	41fad79b          	sraiw	a5,s5,0x1f
    80002dfa:	0137d79b          	srliw	a5,a5,0x13
    80002dfe:	015787bb          	addw	a5,a5,s5
    80002e02:	40d7d79b          	sraiw	a5,a5,0xd
    80002e06:	01cb2583          	lw	a1,28(s6)
    80002e0a:	9dbd                	addw	a1,a1,a5
    80002e0c:	855e                	mv	a0,s7
    80002e0e:	cdfff0ef          	jal	80002aec <bread>
    80002e12:	892a                	mv	s2,a0
    for (bi = 0; bi < BPB && b + bi < sb.size; bi++) {
    80002e14:	004b2503          	lw	a0,4(s6)
    80002e18:	000a849b          	sext.w	s1,s5
    80002e1c:	8762                	mv	a4,s8
    80002e1e:	fca4f1e3          	bgeu	s1,a0,80002de0 <balloc+0x90>
      m = 1 << (bi % 8);
    80002e22:	00777693          	andi	a3,a4,7
    80002e26:	00d996bb          	sllw	a3,s3,a3
      if ((bp->data[bi / 8] & m) == 0) { // Is block free?
    80002e2a:	41f7579b          	sraiw	a5,a4,0x1f
    80002e2e:	01d7d79b          	srliw	a5,a5,0x1d
    80002e32:	9fb9                	addw	a5,a5,a4
    80002e34:	4037d79b          	sraiw	a5,a5,0x3
    80002e38:	00f90633          	add	a2,s2,a5
    80002e3c:	05864603          	lbu	a2,88(a2)
    80002e40:	00c6f5b3          	and	a1,a3,a2
    80002e44:	d5a1                	beqz	a1,80002d8c <balloc+0x3c>
    for (bi = 0; bi < BPB && b + bi < sb.size; bi++) {
    80002e46:	2705                	addiw	a4,a4,1
    80002e48:	2485                	addiw	s1,s1,1
    80002e4a:	fd471ae3          	bne	a4,s4,80002e1e <balloc+0xce>
    80002e4e:	bf49                	j	80002de0 <balloc+0x90>
    80002e50:	6906                	ld	s2,64(sp)
    80002e52:	79e2                	ld	s3,56(sp)
    80002e54:	7a42                	ld	s4,48(sp)
    80002e56:	7aa2                	ld	s5,40(sp)
    80002e58:	7b02                	ld	s6,32(sp)
    80002e5a:	6be2                	ld	s7,24(sp)
    80002e5c:	6c42                	ld	s8,16(sp)
    80002e5e:	6ca2                	ld	s9,8(sp)
  printk("balloc: out of blocks\n");
    80002e60:	00004517          	auipc	a0,0x4
    80002e64:	58050513          	addi	a0,a0,1408 # 800073e0 <etext+0x3e0>
    80002e68:	e86fd0ef          	jal	800004ee <printk>
  return 0;
    80002e6c:	4481                	li	s1,0
    80002e6e:	b79d                	j	80002dd4 <balloc+0x84>

0000000080002e70 <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    80002e70:	7179                	addi	sp,sp,-48
    80002e72:	f406                	sd	ra,40(sp)
    80002e74:	f022                	sd	s0,32(sp)
    80002e76:	ec26                	sd	s1,24(sp)
    80002e78:	e84a                	sd	s2,16(sp)
    80002e7a:	e44e                	sd	s3,8(sp)
    80002e7c:	1800                	addi	s0,sp,48
    80002e7e:	89aa                	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if (bn < NDIRECT) {
    80002e80:	47ad                	li	a5,11
    80002e82:	02b7e663          	bltu	a5,a1,80002eae <bmap+0x3e>
    if ((addr = ip->addrs[bn]) == 0) {
    80002e86:	02059793          	slli	a5,a1,0x20
    80002e8a:	01e7d593          	srli	a1,a5,0x1e
    80002e8e:	00b504b3          	add	s1,a0,a1
    80002e92:	0504a903          	lw	s2,80(s1)
    80002e96:	06091a63          	bnez	s2,80002f0a <bmap+0x9a>
      addr = balloc(ip->dev);
    80002e9a:	4108                	lw	a0,0(a0)
    80002e9c:	eb5ff0ef          	jal	80002d50 <balloc>
    80002ea0:	0005091b          	sext.w	s2,a0
      if (addr == 0)
    80002ea4:	06090363          	beqz	s2,80002f0a <bmap+0x9a>
        return 0;
      ip->addrs[bn] = addr;
    80002ea8:	0524a823          	sw	s2,80(s1)
    80002eac:	a8b9                	j	80002f0a <bmap+0x9a>
    }
    return addr;
  }
  bn -= NDIRECT;
    80002eae:	ff45849b          	addiw	s1,a1,-12
    80002eb2:	0004871b          	sext.w	a4,s1

  if (bn < NINDIRECT) {
    80002eb6:	0ff00793          	li	a5,255
    80002eba:	06e7ee63          	bltu	a5,a4,80002f36 <bmap+0xc6>
    // Load indirect block, allocating if necessary.
    if ((addr = ip->addrs[NDIRECT]) == 0) {
    80002ebe:	08052903          	lw	s2,128(a0)
    80002ec2:	00091d63          	bnez	s2,80002edc <bmap+0x6c>
      addr = balloc(ip->dev);
    80002ec6:	4108                	lw	a0,0(a0)
    80002ec8:	e89ff0ef          	jal	80002d50 <balloc>
    80002ecc:	0005091b          	sext.w	s2,a0
      if (addr == 0)
    80002ed0:	02090d63          	beqz	s2,80002f0a <bmap+0x9a>
    80002ed4:	e052                	sd	s4,0(sp)
        return 0;
      ip->addrs[NDIRECT] = addr;
    80002ed6:	0929a023          	sw	s2,128(s3)
    80002eda:	a011                	j	80002ede <bmap+0x6e>
    80002edc:	e052                	sd	s4,0(sp)
    }
    bp = bread(ip->dev, addr);
    80002ede:	85ca                	mv	a1,s2
    80002ee0:	0009a503          	lw	a0,0(s3)
    80002ee4:	c09ff0ef          	jal	80002aec <bread>
    80002ee8:	8a2a                	mv	s4,a0
    a = (uint *)bp->data;
    80002eea:	05850793          	addi	a5,a0,88
    if ((addr = a[bn]) == 0) {
    80002eee:	02049713          	slli	a4,s1,0x20
    80002ef2:	01e75593          	srli	a1,a4,0x1e
    80002ef6:	00b784b3          	add	s1,a5,a1
    80002efa:	0004a903          	lw	s2,0(s1)
    80002efe:	00090e63          	beqz	s2,80002f1a <bmap+0xaa>
      if (addr) {
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    80002f02:	8552                	mv	a0,s4
    80002f04:	cf1ff0ef          	jal	80002bf4 <brelse>
    return addr;
    80002f08:	6a02                	ld	s4,0(sp)
  }

  panic("bmap: out of range");
}
    80002f0a:	854a                	mv	a0,s2
    80002f0c:	70a2                	ld	ra,40(sp)
    80002f0e:	7402                	ld	s0,32(sp)
    80002f10:	64e2                	ld	s1,24(sp)
    80002f12:	6942                	ld	s2,16(sp)
    80002f14:	69a2                	ld	s3,8(sp)
    80002f16:	6145                	addi	sp,sp,48
    80002f18:	8082                	ret
      addr = balloc(ip->dev);
    80002f1a:	0009a503          	lw	a0,0(s3)
    80002f1e:	e33ff0ef          	jal	80002d50 <balloc>
    80002f22:	0005091b          	sext.w	s2,a0
      if (addr) {
    80002f26:	fc090ee3          	beqz	s2,80002f02 <bmap+0x92>
        a[bn] = addr;
    80002f2a:	0124a023          	sw	s2,0(s1)
        log_write(bp);
    80002f2e:	8552                	mv	a0,s4
    80002f30:	5fd000ef          	jal	80003d2c <log_write>
    80002f34:	b7f9                	j	80002f02 <bmap+0x92>
    80002f36:	e052                	sd	s4,0(sp)
  panic("bmap: out of range");
    80002f38:	00004517          	auipc	a0,0x4
    80002f3c:	4c050513          	addi	a0,a0,1216 # 800073f8 <etext+0x3f8>
    80002f40:	895fd0ef          	jal	800007d4 <panic>

0000000080002f44 <iget>:
{
    80002f44:	7179                	addi	sp,sp,-48
    80002f46:	f406                	sd	ra,40(sp)
    80002f48:	f022                	sd	s0,32(sp)
    80002f4a:	ec26                	sd	s1,24(sp)
    80002f4c:	e84a                	sd	s2,16(sp)
    80002f4e:	e44e                	sd	s3,8(sp)
    80002f50:	e052                	sd	s4,0(sp)
    80002f52:	1800                	addi	s0,sp,48
    80002f54:	89aa                	mv	s3,a0
    80002f56:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    80002f58:	0001e517          	auipc	a0,0x1e
    80002f5c:	89850513          	addi	a0,a0,-1896 # 800207f0 <itable>
    80002f60:	c4dfd0ef          	jal	80000bac <acquire>
  empty = 0;
    80002f64:	4901                	li	s2,0
  for (ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++) {
    80002f66:	0001e497          	auipc	s1,0x1e
    80002f6a:	8a248493          	addi	s1,s1,-1886 # 80020808 <itable+0x18>
    80002f6e:	0001f697          	auipc	a3,0x1f
    80002f72:	32a68693          	addi	a3,a3,810 # 80022298 <log>
    80002f76:	a039                	j	80002f84 <iget+0x40>
    if (empty == 0 && ip->ref == 0) // Remember empty slot.
    80002f78:	02090963          	beqz	s2,80002faa <iget+0x66>
  for (ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++) {
    80002f7c:	08848493          	addi	s1,s1,136
    80002f80:	02d48863          	beq	s1,a3,80002fb0 <iget+0x6c>
    if (ip->ref > 0 && ip->dev == dev && ip->inum == inum) {
    80002f84:	449c                	lw	a5,8(s1)
    80002f86:	fef059e3          	blez	a5,80002f78 <iget+0x34>
    80002f8a:	4098                	lw	a4,0(s1)
    80002f8c:	ff3716e3          	bne	a4,s3,80002f78 <iget+0x34>
    80002f90:	40d8                	lw	a4,4(s1)
    80002f92:	ff4713e3          	bne	a4,s4,80002f78 <iget+0x34>
      ip->ref++;
    80002f96:	2785                	addiw	a5,a5,1
    80002f98:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    80002f9a:	0001e517          	auipc	a0,0x1e
    80002f9e:	85650513          	addi	a0,a0,-1962 # 800207f0 <itable>
    80002fa2:	c9ffd0ef          	jal	80000c40 <release>
      return ip;
    80002fa6:	8926                	mv	s2,s1
    80002fa8:	a02d                	j	80002fd2 <iget+0x8e>
    if (empty == 0 && ip->ref == 0) // Remember empty slot.
    80002faa:	fbe9                	bnez	a5,80002f7c <iget+0x38>
      empty = ip;
    80002fac:	8926                	mv	s2,s1
    80002fae:	b7f9                	j	80002f7c <iget+0x38>
  if (empty == 0)
    80002fb0:	02090a63          	beqz	s2,80002fe4 <iget+0xa0>
  ip->dev = dev;
    80002fb4:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    80002fb8:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    80002fbc:	4785                	li	a5,1
    80002fbe:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    80002fc2:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    80002fc6:	0001e517          	auipc	a0,0x1e
    80002fca:	82a50513          	addi	a0,a0,-2006 # 800207f0 <itable>
    80002fce:	c73fd0ef          	jal	80000c40 <release>
}
    80002fd2:	854a                	mv	a0,s2
    80002fd4:	70a2                	ld	ra,40(sp)
    80002fd6:	7402                	ld	s0,32(sp)
    80002fd8:	64e2                	ld	s1,24(sp)
    80002fda:	6942                	ld	s2,16(sp)
    80002fdc:	69a2                	ld	s3,8(sp)
    80002fde:	6a02                	ld	s4,0(sp)
    80002fe0:	6145                	addi	sp,sp,48
    80002fe2:	8082                	ret
    panic("iget: no inodes");
    80002fe4:	00004517          	auipc	a0,0x4
    80002fe8:	42c50513          	addi	a0,a0,1068 # 80007410 <etext+0x410>
    80002fec:	fe8fd0ef          	jal	800007d4 <panic>

0000000080002ff0 <iinit>:
{
    80002ff0:	7179                	addi	sp,sp,-48
    80002ff2:	f406                	sd	ra,40(sp)
    80002ff4:	f022                	sd	s0,32(sp)
    80002ff6:	ec26                	sd	s1,24(sp)
    80002ff8:	e84a                	sd	s2,16(sp)
    80002ffa:	e44e                	sd	s3,8(sp)
    80002ffc:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    80002ffe:	00004597          	auipc	a1,0x4
    80003002:	42258593          	addi	a1,a1,1058 # 80007420 <etext+0x420>
    80003006:	0001d517          	auipc	a0,0x1d
    8000300a:	7ea50513          	addi	a0,a0,2026 # 800207f0 <itable>
    8000300e:	b1ffd0ef          	jal	80000b2c <initlock>
  for (i = 0; i < NINODE; i++) {
    80003012:	0001e497          	auipc	s1,0x1e
    80003016:	80648493          	addi	s1,s1,-2042 # 80020818 <itable+0x28>
    8000301a:	0001f997          	auipc	s3,0x1f
    8000301e:	28e98993          	addi	s3,s3,654 # 800222a8 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    80003022:	00004917          	auipc	s2,0x4
    80003026:	40690913          	addi	s2,s2,1030 # 80007428 <etext+0x428>
    8000302a:	85ca                	mv	a1,s2
    8000302c:	8526                	mv	a0,s1
    8000302e:	623000ef          	jal	80003e50 <initsleeplock>
  for (i = 0; i < NINODE; i++) {
    80003032:	08848493          	addi	s1,s1,136
    80003036:	ff349ae3          	bne	s1,s3,8000302a <iinit+0x3a>
}
    8000303a:	70a2                	ld	ra,40(sp)
    8000303c:	7402                	ld	s0,32(sp)
    8000303e:	64e2                	ld	s1,24(sp)
    80003040:	6942                	ld	s2,16(sp)
    80003042:	69a2                	ld	s3,8(sp)
    80003044:	6145                	addi	sp,sp,48
    80003046:	8082                	ret

0000000080003048 <ialloc>:
{
    80003048:	7139                	addi	sp,sp,-64
    8000304a:	fc06                	sd	ra,56(sp)
    8000304c:	f822                	sd	s0,48(sp)
    8000304e:	0080                	addi	s0,sp,64
  for (inum = 1; inum < sb.ninodes; inum++) {
    80003050:	0001d717          	auipc	a4,0x1d
    80003054:	78c72703          	lw	a4,1932(a4) # 800207dc <sb+0xc>
    80003058:	4785                	li	a5,1
    8000305a:	06e7f063          	bgeu	a5,a4,800030ba <ialloc+0x72>
    8000305e:	f426                	sd	s1,40(sp)
    80003060:	f04a                	sd	s2,32(sp)
    80003062:	ec4e                	sd	s3,24(sp)
    80003064:	e852                	sd	s4,16(sp)
    80003066:	e456                	sd	s5,8(sp)
    80003068:	e05a                	sd	s6,0(sp)
    8000306a:	8aaa                	mv	s5,a0
    8000306c:	8b2e                	mv	s6,a1
    8000306e:	4905                	li	s2,1
    bp = bread(dev, IBLOCK(inum, sb));
    80003070:	0001da17          	auipc	s4,0x1d
    80003074:	760a0a13          	addi	s4,s4,1888 # 800207d0 <sb>
    80003078:	00495593          	srli	a1,s2,0x4
    8000307c:	018a2783          	lw	a5,24(s4)
    80003080:	9dbd                	addw	a1,a1,a5
    80003082:	8556                	mv	a0,s5
    80003084:	a69ff0ef          	jal	80002aec <bread>
    80003088:	84aa                	mv	s1,a0
    dip = (struct dinode *)bp->data + inum % IPB;
    8000308a:	05850993          	addi	s3,a0,88
    8000308e:	00f97793          	andi	a5,s2,15
    80003092:	079a                	slli	a5,a5,0x6
    80003094:	99be                	add	s3,s3,a5
    if (dip->type == 0) { // a free inode
    80003096:	00099783          	lh	a5,0(s3)
    8000309a:	cb9d                	beqz	a5,800030d0 <ialloc+0x88>
    brelse(bp);
    8000309c:	b59ff0ef          	jal	80002bf4 <brelse>
  for (inum = 1; inum < sb.ninodes; inum++) {
    800030a0:	0905                	addi	s2,s2,1
    800030a2:	00ca2703          	lw	a4,12(s4)
    800030a6:	0009079b          	sext.w	a5,s2
    800030aa:	fce7e7e3          	bltu	a5,a4,80003078 <ialloc+0x30>
    800030ae:	74a2                	ld	s1,40(sp)
    800030b0:	7902                	ld	s2,32(sp)
    800030b2:	69e2                	ld	s3,24(sp)
    800030b4:	6a42                	ld	s4,16(sp)
    800030b6:	6aa2                	ld	s5,8(sp)
    800030b8:	6b02                	ld	s6,0(sp)
  printk("ialloc: no inodes\n");
    800030ba:	00004517          	auipc	a0,0x4
    800030be:	37650513          	addi	a0,a0,886 # 80007430 <etext+0x430>
    800030c2:	c2cfd0ef          	jal	800004ee <printk>
  return 0;
    800030c6:	4501                	li	a0,0
}
    800030c8:	70e2                	ld	ra,56(sp)
    800030ca:	7442                	ld	s0,48(sp)
    800030cc:	6121                	addi	sp,sp,64
    800030ce:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    800030d0:	04000613          	li	a2,64
    800030d4:	4581                	li	a1,0
    800030d6:	854e                	mv	a0,s3
    800030d8:	ba1fd0ef          	jal	80000c78 <memset>
      dip->type = type;
    800030dc:	01699023          	sh	s6,0(s3)
      log_write(bp); // mark it allocated on the disk
    800030e0:	8526                	mv	a0,s1
    800030e2:	44b000ef          	jal	80003d2c <log_write>
      brelse(bp);
    800030e6:	8526                	mv	a0,s1
    800030e8:	b0dff0ef          	jal	80002bf4 <brelse>
      return iget(dev, inum);
    800030ec:	0009059b          	sext.w	a1,s2
    800030f0:	8556                	mv	a0,s5
    800030f2:	e53ff0ef          	jal	80002f44 <iget>
    800030f6:	74a2                	ld	s1,40(sp)
    800030f8:	7902                	ld	s2,32(sp)
    800030fa:	69e2                	ld	s3,24(sp)
    800030fc:	6a42                	ld	s4,16(sp)
    800030fe:	6aa2                	ld	s5,8(sp)
    80003100:	6b02                	ld	s6,0(sp)
    80003102:	b7d9                	j	800030c8 <ialloc+0x80>

0000000080003104 <iupdate>:
{
    80003104:	1101                	addi	sp,sp,-32
    80003106:	ec06                	sd	ra,24(sp)
    80003108:	e822                	sd	s0,16(sp)
    8000310a:	e426                	sd	s1,8(sp)
    8000310c:	e04a                	sd	s2,0(sp)
    8000310e:	1000                	addi	s0,sp,32
    80003110:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003112:	415c                	lw	a5,4(a0)
    80003114:	0047d79b          	srliw	a5,a5,0x4
    80003118:	0001d597          	auipc	a1,0x1d
    8000311c:	6d05a583          	lw	a1,1744(a1) # 800207e8 <sb+0x18>
    80003120:	9dbd                	addw	a1,a1,a5
    80003122:	4108                	lw	a0,0(a0)
    80003124:	9c9ff0ef          	jal	80002aec <bread>
    80003128:	892a                	mv	s2,a0
  dip = (struct dinode *)bp->data + ip->inum % IPB;
    8000312a:	05850793          	addi	a5,a0,88
    8000312e:	40d8                	lw	a4,4(s1)
    80003130:	8b3d                	andi	a4,a4,15
    80003132:	071a                	slli	a4,a4,0x6
    80003134:	97ba                	add	a5,a5,a4
  dip->type = ip->type;
    80003136:	04449703          	lh	a4,68(s1)
    8000313a:	00e79023          	sh	a4,0(a5)
  dip->major = ip->major;
    8000313e:	04649703          	lh	a4,70(s1)
    80003142:	00e79123          	sh	a4,2(a5)
  dip->minor = ip->minor;
    80003146:	04849703          	lh	a4,72(s1)
    8000314a:	00e79223          	sh	a4,4(a5)
  dip->nlink = ip->nlink;
    8000314e:	04a49703          	lh	a4,74(s1)
    80003152:	00e79323          	sh	a4,6(a5)
  dip->size = ip->size;
    80003156:	44f8                	lw	a4,76(s1)
    80003158:	c798                	sw	a4,8(a5)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    8000315a:	03400613          	li	a2,52
    8000315e:	05048593          	addi	a1,s1,80
    80003162:	00c78513          	addi	a0,a5,12
    80003166:	b6ffd0ef          	jal	80000cd4 <memmove>
  log_write(bp);
    8000316a:	854a                	mv	a0,s2
    8000316c:	3c1000ef          	jal	80003d2c <log_write>
  brelse(bp);
    80003170:	854a                	mv	a0,s2
    80003172:	a83ff0ef          	jal	80002bf4 <brelse>
}
    80003176:	60e2                	ld	ra,24(sp)
    80003178:	6442                	ld	s0,16(sp)
    8000317a:	64a2                	ld	s1,8(sp)
    8000317c:	6902                	ld	s2,0(sp)
    8000317e:	6105                	addi	sp,sp,32
    80003180:	8082                	ret

0000000080003182 <idup>:
{
    80003182:	1101                	addi	sp,sp,-32
    80003184:	ec06                	sd	ra,24(sp)
    80003186:	e822                	sd	s0,16(sp)
    80003188:	e426                	sd	s1,8(sp)
    8000318a:	1000                	addi	s0,sp,32
    8000318c:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    8000318e:	0001d517          	auipc	a0,0x1d
    80003192:	66250513          	addi	a0,a0,1634 # 800207f0 <itable>
    80003196:	a17fd0ef          	jal	80000bac <acquire>
  ip->ref++;
    8000319a:	449c                	lw	a5,8(s1)
    8000319c:	2785                	addiw	a5,a5,1
    8000319e:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    800031a0:	0001d517          	auipc	a0,0x1d
    800031a4:	65050513          	addi	a0,a0,1616 # 800207f0 <itable>
    800031a8:	a99fd0ef          	jal	80000c40 <release>
}
    800031ac:	8526                	mv	a0,s1
    800031ae:	60e2                	ld	ra,24(sp)
    800031b0:	6442                	ld	s0,16(sp)
    800031b2:	64a2                	ld	s1,8(sp)
    800031b4:	6105                	addi	sp,sp,32
    800031b6:	8082                	ret

00000000800031b8 <ilock>:
{
    800031b8:	1101                	addi	sp,sp,-32
    800031ba:	ec06                	sd	ra,24(sp)
    800031bc:	e822                	sd	s0,16(sp)
    800031be:	e426                	sd	s1,8(sp)
    800031c0:	1000                	addi	s0,sp,32
  if (ip == 0 || ip->ref < 1)
    800031c2:	cd19                	beqz	a0,800031e0 <ilock+0x28>
    800031c4:	84aa                	mv	s1,a0
    800031c6:	451c                	lw	a5,8(a0)
    800031c8:	00f05c63          	blez	a5,800031e0 <ilock+0x28>
  acquiresleep(&ip->lock);
    800031cc:	0541                	addi	a0,a0,16
    800031ce:	4b9000ef          	jal	80003e86 <acquiresleep>
  if (ip->valid == 0) {
    800031d2:	40bc                	lw	a5,64(s1)
    800031d4:	cf89                	beqz	a5,800031ee <ilock+0x36>
}
    800031d6:	60e2                	ld	ra,24(sp)
    800031d8:	6442                	ld	s0,16(sp)
    800031da:	64a2                	ld	s1,8(sp)
    800031dc:	6105                	addi	sp,sp,32
    800031de:	8082                	ret
    800031e0:	e04a                	sd	s2,0(sp)
    panic("ilock");
    800031e2:	00004517          	auipc	a0,0x4
    800031e6:	26650513          	addi	a0,a0,614 # 80007448 <etext+0x448>
    800031ea:	deafd0ef          	jal	800007d4 <panic>
    800031ee:	e04a                	sd	s2,0(sp)
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    800031f0:	40dc                	lw	a5,4(s1)
    800031f2:	0047d79b          	srliw	a5,a5,0x4
    800031f6:	0001d597          	auipc	a1,0x1d
    800031fa:	5f25a583          	lw	a1,1522(a1) # 800207e8 <sb+0x18>
    800031fe:	9dbd                	addw	a1,a1,a5
    80003200:	4088                	lw	a0,0(s1)
    80003202:	8ebff0ef          	jal	80002aec <bread>
    80003206:	892a                	mv	s2,a0
    dip = (struct dinode *)bp->data + ip->inum % IPB;
    80003208:	05850593          	addi	a1,a0,88
    8000320c:	40dc                	lw	a5,4(s1)
    8000320e:	8bbd                	andi	a5,a5,15
    80003210:	079a                	slli	a5,a5,0x6
    80003212:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    80003214:	00059783          	lh	a5,0(a1)
    80003218:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    8000321c:	00259783          	lh	a5,2(a1)
    80003220:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    80003224:	00459783          	lh	a5,4(a1)
    80003228:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    8000322c:	00659783          	lh	a5,6(a1)
    80003230:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    80003234:	459c                	lw	a5,8(a1)
    80003236:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80003238:	03400613          	li	a2,52
    8000323c:	05b1                	addi	a1,a1,12
    8000323e:	05048513          	addi	a0,s1,80
    80003242:	a93fd0ef          	jal	80000cd4 <memmove>
    brelse(bp);
    80003246:	854a                	mv	a0,s2
    80003248:	9adff0ef          	jal	80002bf4 <brelse>
    ip->valid = 1;
    8000324c:	4785                	li	a5,1
    8000324e:	c0bc                	sw	a5,64(s1)
    if (ip->type == 0)
    80003250:	04449783          	lh	a5,68(s1)
    80003254:	c399                	beqz	a5,8000325a <ilock+0xa2>
    80003256:	6902                	ld	s2,0(sp)
    80003258:	bfbd                	j	800031d6 <ilock+0x1e>
      panic("ilock: no type");
    8000325a:	00004517          	auipc	a0,0x4
    8000325e:	1f650513          	addi	a0,a0,502 # 80007450 <etext+0x450>
    80003262:	d72fd0ef          	jal	800007d4 <panic>

0000000080003266 <iunlock>:
{
    80003266:	1101                	addi	sp,sp,-32
    80003268:	ec06                	sd	ra,24(sp)
    8000326a:	e822                	sd	s0,16(sp)
    8000326c:	e426                	sd	s1,8(sp)
    8000326e:	e04a                	sd	s2,0(sp)
    80003270:	1000                	addi	s0,sp,32
  if (ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80003272:	c505                	beqz	a0,8000329a <iunlock+0x34>
    80003274:	84aa                	mv	s1,a0
    80003276:	01050913          	addi	s2,a0,16
    8000327a:	854a                	mv	a0,s2
    8000327c:	489000ef          	jal	80003f04 <holdingsleep>
    80003280:	cd09                	beqz	a0,8000329a <iunlock+0x34>
    80003282:	449c                	lw	a5,8(s1)
    80003284:	00f05b63          	blez	a5,8000329a <iunlock+0x34>
  releasesleep(&ip->lock);
    80003288:	854a                	mv	a0,s2
    8000328a:	443000ef          	jal	80003ecc <releasesleep>
}
    8000328e:	60e2                	ld	ra,24(sp)
    80003290:	6442                	ld	s0,16(sp)
    80003292:	64a2                	ld	s1,8(sp)
    80003294:	6902                	ld	s2,0(sp)
    80003296:	6105                	addi	sp,sp,32
    80003298:	8082                	ret
    panic("iunlock");
    8000329a:	00004517          	auipc	a0,0x4
    8000329e:	1c650513          	addi	a0,a0,454 # 80007460 <etext+0x460>
    800032a2:	d32fd0ef          	jal	800007d4 <panic>

00000000800032a6 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    800032a6:	7179                	addi	sp,sp,-48
    800032a8:	f406                	sd	ra,40(sp)
    800032aa:	f022                	sd	s0,32(sp)
    800032ac:	ec26                	sd	s1,24(sp)
    800032ae:	e84a                	sd	s2,16(sp)
    800032b0:	e44e                	sd	s3,8(sp)
    800032b2:	1800                	addi	s0,sp,48
    800032b4:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for (i = 0; i < NDIRECT; i++) {
    800032b6:	05050493          	addi	s1,a0,80
    800032ba:	08050913          	addi	s2,a0,128
    800032be:	a021                	j	800032c6 <itrunc+0x20>
    800032c0:	0491                	addi	s1,s1,4
    800032c2:	01248b63          	beq	s1,s2,800032d8 <itrunc+0x32>
    if (ip->addrs[i]) {
    800032c6:	408c                	lw	a1,0(s1)
    800032c8:	dde5                	beqz	a1,800032c0 <itrunc+0x1a>
      bfree(ip->dev, ip->addrs[i]);
    800032ca:	0009a503          	lw	a0,0(s3)
    800032ce:	a17ff0ef          	jal	80002ce4 <bfree>
      ip->addrs[i] = 0;
    800032d2:	0004a023          	sw	zero,0(s1)
    800032d6:	b7ed                	j	800032c0 <itrunc+0x1a>
    }
  }

  if (ip->addrs[NDIRECT]) {
    800032d8:	0809a583          	lw	a1,128(s3)
    800032dc:	ed89                	bnez	a1,800032f6 <itrunc+0x50>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    800032de:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    800032e2:	854e                	mv	a0,s3
    800032e4:	e21ff0ef          	jal	80003104 <iupdate>
}
    800032e8:	70a2                	ld	ra,40(sp)
    800032ea:	7402                	ld	s0,32(sp)
    800032ec:	64e2                	ld	s1,24(sp)
    800032ee:	6942                	ld	s2,16(sp)
    800032f0:	69a2                	ld	s3,8(sp)
    800032f2:	6145                	addi	sp,sp,48
    800032f4:	8082                	ret
    800032f6:	e052                	sd	s4,0(sp)
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    800032f8:	0009a503          	lw	a0,0(s3)
    800032fc:	ff0ff0ef          	jal	80002aec <bread>
    80003300:	8a2a                	mv	s4,a0
    for (j = 0; j < NINDIRECT; j++) {
    80003302:	05850493          	addi	s1,a0,88
    80003306:	45850913          	addi	s2,a0,1112
    8000330a:	a021                	j	80003312 <itrunc+0x6c>
    8000330c:	0491                	addi	s1,s1,4
    8000330e:	01248963          	beq	s1,s2,80003320 <itrunc+0x7a>
      if (a[j])
    80003312:	408c                	lw	a1,0(s1)
    80003314:	dde5                	beqz	a1,8000330c <itrunc+0x66>
        bfree(ip->dev, a[j]);
    80003316:	0009a503          	lw	a0,0(s3)
    8000331a:	9cbff0ef          	jal	80002ce4 <bfree>
    8000331e:	b7fd                	j	8000330c <itrunc+0x66>
    brelse(bp);
    80003320:	8552                	mv	a0,s4
    80003322:	8d3ff0ef          	jal	80002bf4 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80003326:	0809a583          	lw	a1,128(s3)
    8000332a:	0009a503          	lw	a0,0(s3)
    8000332e:	9b7ff0ef          	jal	80002ce4 <bfree>
    ip->addrs[NDIRECT] = 0;
    80003332:	0809a023          	sw	zero,128(s3)
    80003336:	6a02                	ld	s4,0(sp)
    80003338:	b75d                	j	800032de <itrunc+0x38>

000000008000333a <iput>:
{
    8000333a:	1101                	addi	sp,sp,-32
    8000333c:	ec06                	sd	ra,24(sp)
    8000333e:	e822                	sd	s0,16(sp)
    80003340:	e426                	sd	s1,8(sp)
    80003342:	1000                	addi	s0,sp,32
    80003344:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003346:	0001d517          	auipc	a0,0x1d
    8000334a:	4aa50513          	addi	a0,a0,1194 # 800207f0 <itable>
    8000334e:	85ffd0ef          	jal	80000bac <acquire>
  if (ip->ref == 1 && ip->valid && ip->nlink == 0) {
    80003352:	4498                	lw	a4,8(s1)
    80003354:	4785                	li	a5,1
    80003356:	02f70063          	beq	a4,a5,80003376 <iput+0x3c>
  ip->ref--;
    8000335a:	449c                	lw	a5,8(s1)
    8000335c:	37fd                	addiw	a5,a5,-1
    8000335e:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003360:	0001d517          	auipc	a0,0x1d
    80003364:	49050513          	addi	a0,a0,1168 # 800207f0 <itable>
    80003368:	8d9fd0ef          	jal	80000c40 <release>
}
    8000336c:	60e2                	ld	ra,24(sp)
    8000336e:	6442                	ld	s0,16(sp)
    80003370:	64a2                	ld	s1,8(sp)
    80003372:	6105                	addi	sp,sp,32
    80003374:	8082                	ret
  if (ip->ref == 1 && ip->valid && ip->nlink == 0) {
    80003376:	40bc                	lw	a5,64(s1)
    80003378:	d3ed                	beqz	a5,8000335a <iput+0x20>
    8000337a:	04a49783          	lh	a5,74(s1)
    8000337e:	fff1                	bnez	a5,8000335a <iput+0x20>
    80003380:	e04a                	sd	s2,0(sp)
    acquiresleep(&ip->lock);
    80003382:	01048913          	addi	s2,s1,16
    80003386:	854a                	mv	a0,s2
    80003388:	2ff000ef          	jal	80003e86 <acquiresleep>
    release(&itable.lock);
    8000338c:	0001d517          	auipc	a0,0x1d
    80003390:	46450513          	addi	a0,a0,1124 # 800207f0 <itable>
    80003394:	8adfd0ef          	jal	80000c40 <release>
    itrunc(ip);
    80003398:	8526                	mv	a0,s1
    8000339a:	f0dff0ef          	jal	800032a6 <itrunc>
    ip->type = 0;
    8000339e:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    800033a2:	8526                	mv	a0,s1
    800033a4:	d61ff0ef          	jal	80003104 <iupdate>
    ip->valid = 0;
    800033a8:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    800033ac:	854a                	mv	a0,s2
    800033ae:	31f000ef          	jal	80003ecc <releasesleep>
    acquire(&itable.lock);
    800033b2:	0001d517          	auipc	a0,0x1d
    800033b6:	43e50513          	addi	a0,a0,1086 # 800207f0 <itable>
    800033ba:	ff2fd0ef          	jal	80000bac <acquire>
    800033be:	6902                	ld	s2,0(sp)
    800033c0:	bf69                	j	8000335a <iput+0x20>

00000000800033c2 <iunlockput>:
{
    800033c2:	1101                	addi	sp,sp,-32
    800033c4:	ec06                	sd	ra,24(sp)
    800033c6:	e822                	sd	s0,16(sp)
    800033c8:	e426                	sd	s1,8(sp)
    800033ca:	1000                	addi	s0,sp,32
    800033cc:	84aa                	mv	s1,a0
  iunlock(ip);
    800033ce:	e99ff0ef          	jal	80003266 <iunlock>
  iput(ip);
    800033d2:	8526                	mv	a0,s1
    800033d4:	f67ff0ef          	jal	8000333a <iput>
}
    800033d8:	60e2                	ld	ra,24(sp)
    800033da:	6442                	ld	s0,16(sp)
    800033dc:	64a2                	ld	s1,8(sp)
    800033de:	6105                	addi	sp,sp,32
    800033e0:	8082                	ret

00000000800033e2 <ireclaim>:
  for (int inum = 1; inum < sb.ninodes; inum++) {
    800033e2:	0001d717          	auipc	a4,0x1d
    800033e6:	3fa72703          	lw	a4,1018(a4) # 800207dc <sb+0xc>
    800033ea:	4785                	li	a5,1
    800033ec:	0ae7ff63          	bgeu	a5,a4,800034aa <ireclaim+0xc8>
{
    800033f0:	7139                	addi	sp,sp,-64
    800033f2:	fc06                	sd	ra,56(sp)
    800033f4:	f822                	sd	s0,48(sp)
    800033f6:	f426                	sd	s1,40(sp)
    800033f8:	f04a                	sd	s2,32(sp)
    800033fa:	ec4e                	sd	s3,24(sp)
    800033fc:	e852                	sd	s4,16(sp)
    800033fe:	e456                	sd	s5,8(sp)
    80003400:	e05a                	sd	s6,0(sp)
    80003402:	0080                	addi	s0,sp,64
  for (int inum = 1; inum < sb.ninodes; inum++) {
    80003404:	4485                	li	s1,1
    struct buf *bp = bread(dev, IBLOCK(inum, sb));
    80003406:	00050a1b          	sext.w	s4,a0
    8000340a:	0001da97          	auipc	s5,0x1d
    8000340e:	3c6a8a93          	addi	s5,s5,966 # 800207d0 <sb>
      printk("ireclaim: orphaned inode %d\n", inum);
    80003412:	00004b17          	auipc	s6,0x4
    80003416:	056b0b13          	addi	s6,s6,86 # 80007468 <etext+0x468>
    8000341a:	a099                	j	80003460 <ireclaim+0x7e>
    8000341c:	85ce                	mv	a1,s3
    8000341e:	855a                	mv	a0,s6
    80003420:	8cefd0ef          	jal	800004ee <printk>
      ip = iget(dev, inum);
    80003424:	85ce                	mv	a1,s3
    80003426:	8552                	mv	a0,s4
    80003428:	b1dff0ef          	jal	80002f44 <iget>
    8000342c:	89aa                	mv	s3,a0
    brelse(bp);
    8000342e:	854a                	mv	a0,s2
    80003430:	fc4ff0ef          	jal	80002bf4 <brelse>
    if (ip) {
    80003434:	00098f63          	beqz	s3,80003452 <ireclaim+0x70>
      begin_op();
    80003438:	76a000ef          	jal	80003ba2 <begin_op>
      ilock(ip);
    8000343c:	854e                	mv	a0,s3
    8000343e:	d7bff0ef          	jal	800031b8 <ilock>
      iunlock(ip);
    80003442:	854e                	mv	a0,s3
    80003444:	e23ff0ef          	jal	80003266 <iunlock>
      iput(ip);
    80003448:	854e                	mv	a0,s3
    8000344a:	ef1ff0ef          	jal	8000333a <iput>
      end_op();
    8000344e:	7be000ef          	jal	80003c0c <end_op>
  for (int inum = 1; inum < sb.ninodes; inum++) {
    80003452:	0485                	addi	s1,s1,1
    80003454:	00caa703          	lw	a4,12(s5)
    80003458:	0004879b          	sext.w	a5,s1
    8000345c:	02e7fd63          	bgeu	a5,a4,80003496 <ireclaim+0xb4>
    80003460:	0004899b          	sext.w	s3,s1
    struct buf *bp = bread(dev, IBLOCK(inum, sb));
    80003464:	0044d593          	srli	a1,s1,0x4
    80003468:	018aa783          	lw	a5,24(s5)
    8000346c:	9dbd                	addw	a1,a1,a5
    8000346e:	8552                	mv	a0,s4
    80003470:	e7cff0ef          	jal	80002aec <bread>
    80003474:	892a                	mv	s2,a0
    struct dinode *dip = (struct dinode *)bp->data + inum % IPB;
    80003476:	05850793          	addi	a5,a0,88
    8000347a:	00f9f713          	andi	a4,s3,15
    8000347e:	071a                	slli	a4,a4,0x6
    80003480:	97ba                	add	a5,a5,a4
    if (dip->type != 0 && dip->nlink == 0) { // is an orphaned inode
    80003482:	00079703          	lh	a4,0(a5)
    80003486:	c701                	beqz	a4,8000348e <ireclaim+0xac>
    80003488:	00679783          	lh	a5,6(a5)
    8000348c:	dbc1                	beqz	a5,8000341c <ireclaim+0x3a>
    brelse(bp);
    8000348e:	854a                	mv	a0,s2
    80003490:	f64ff0ef          	jal	80002bf4 <brelse>
    if (ip) {
    80003494:	bf7d                	j	80003452 <ireclaim+0x70>
}
    80003496:	70e2                	ld	ra,56(sp)
    80003498:	7442                	ld	s0,48(sp)
    8000349a:	74a2                	ld	s1,40(sp)
    8000349c:	7902                	ld	s2,32(sp)
    8000349e:	69e2                	ld	s3,24(sp)
    800034a0:	6a42                	ld	s4,16(sp)
    800034a2:	6aa2                	ld	s5,8(sp)
    800034a4:	6b02                	ld	s6,0(sp)
    800034a6:	6121                	addi	sp,sp,64
    800034a8:	8082                	ret
    800034aa:	8082                	ret

00000000800034ac <fsinit>:
{
    800034ac:	7179                	addi	sp,sp,-48
    800034ae:	f406                	sd	ra,40(sp)
    800034b0:	f022                	sd	s0,32(sp)
    800034b2:	ec26                	sd	s1,24(sp)
    800034b4:	e84a                	sd	s2,16(sp)
    800034b6:	e44e                	sd	s3,8(sp)
    800034b8:	1800                	addi	s0,sp,48
    800034ba:	84aa                	mv	s1,a0
  bp = bread(dev, 1);
    800034bc:	4585                	li	a1,1
    800034be:	e2eff0ef          	jal	80002aec <bread>
    800034c2:	892a                	mv	s2,a0
  memmove(sb, bp->data, sizeof(*sb));
    800034c4:	0001d997          	auipc	s3,0x1d
    800034c8:	30c98993          	addi	s3,s3,780 # 800207d0 <sb>
    800034cc:	02000613          	li	a2,32
    800034d0:	05850593          	addi	a1,a0,88
    800034d4:	854e                	mv	a0,s3
    800034d6:	ffefd0ef          	jal	80000cd4 <memmove>
  brelse(bp);
    800034da:	854a                	mv	a0,s2
    800034dc:	f18ff0ef          	jal	80002bf4 <brelse>
  if (sb.magic != FSMAGIC)
    800034e0:	0009a703          	lw	a4,0(s3)
    800034e4:	102037b7          	lui	a5,0x10203
    800034e8:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    800034ec:	02f71363          	bne	a4,a5,80003512 <fsinit+0x66>
  initlog(dev, &sb);
    800034f0:	0001d597          	auipc	a1,0x1d
    800034f4:	2e058593          	addi	a1,a1,736 # 800207d0 <sb>
    800034f8:	8526                	mv	a0,s1
    800034fa:	62a000ef          	jal	80003b24 <initlog>
  ireclaim(dev);
    800034fe:	8526                	mv	a0,s1
    80003500:	ee3ff0ef          	jal	800033e2 <ireclaim>
}
    80003504:	70a2                	ld	ra,40(sp)
    80003506:	7402                	ld	s0,32(sp)
    80003508:	64e2                	ld	s1,24(sp)
    8000350a:	6942                	ld	s2,16(sp)
    8000350c:	69a2                	ld	s3,8(sp)
    8000350e:	6145                	addi	sp,sp,48
    80003510:	8082                	ret
    panic("invalid file system");
    80003512:	00004517          	auipc	a0,0x4
    80003516:	f7650513          	addi	a0,a0,-138 # 80007488 <etext+0x488>
    8000351a:	abafd0ef          	jal	800007d4 <panic>

000000008000351e <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    8000351e:	1141                	addi	sp,sp,-16
    80003520:	e422                	sd	s0,8(sp)
    80003522:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80003524:	411c                	lw	a5,0(a0)
    80003526:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80003528:	415c                	lw	a5,4(a0)
    8000352a:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    8000352c:	04451783          	lh	a5,68(a0)
    80003530:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80003534:	04a51783          	lh	a5,74(a0)
    80003538:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    8000353c:	04c56783          	lwu	a5,76(a0)
    80003540:	e99c                	sd	a5,16(a1)
}
    80003542:	6422                	ld	s0,8(sp)
    80003544:	0141                	addi	sp,sp,16
    80003546:	8082                	ret

0000000080003548 <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if (off > ip->size || off + n < off)
    80003548:	457c                	lw	a5,76(a0)
    8000354a:	0ed7eb63          	bltu	a5,a3,80003640 <readi+0xf8>
{
    8000354e:	7159                	addi	sp,sp,-112
    80003550:	f486                	sd	ra,104(sp)
    80003552:	f0a2                	sd	s0,96(sp)
    80003554:	eca6                	sd	s1,88(sp)
    80003556:	e0d2                	sd	s4,64(sp)
    80003558:	fc56                	sd	s5,56(sp)
    8000355a:	f85a                	sd	s6,48(sp)
    8000355c:	f45e                	sd	s7,40(sp)
    8000355e:	1880                	addi	s0,sp,112
    80003560:	8b2a                	mv	s6,a0
    80003562:	8bae                	mv	s7,a1
    80003564:	8a32                	mv	s4,a2
    80003566:	84b6                	mv	s1,a3
    80003568:	8aba                	mv	s5,a4
  if (off > ip->size || off + n < off)
    8000356a:	9f35                	addw	a4,a4,a3
    return 0;
    8000356c:	4501                	li	a0,0
  if (off > ip->size || off + n < off)
    8000356e:	0cd76063          	bltu	a4,a3,8000362e <readi+0xe6>
    80003572:	e4ce                	sd	s3,72(sp)
  if (off + n > ip->size)
    80003574:	00e7f463          	bgeu	a5,a4,8000357c <readi+0x34>
    n = ip->size - off;
    80003578:	40d78abb          	subw	s5,a5,a3

  for (tot = 0; tot < n; tot += m, off += m, dst += m) {
    8000357c:	080a8f63          	beqz	s5,8000361a <readi+0xd2>
    80003580:	e8ca                	sd	s2,80(sp)
    80003582:	f062                	sd	s8,32(sp)
    80003584:	ec66                	sd	s9,24(sp)
    80003586:	e86a                	sd	s10,16(sp)
    80003588:	e46e                	sd	s11,8(sp)
    8000358a:	4981                	li	s3,0
    uint addr = bmap(ip, off / BSIZE);
    if (addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off % BSIZE);
    8000358c:	40000c93          	li	s9,1024
    if (either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80003590:	5c7d                	li	s8,-1
    80003592:	a80d                	j	800035c4 <readi+0x7c>
    80003594:	020d1d93          	slli	s11,s10,0x20
    80003598:	020ddd93          	srli	s11,s11,0x20
    8000359c:	05890613          	addi	a2,s2,88
    800035a0:	86ee                	mv	a3,s11
    800035a2:	963a                	add	a2,a2,a4
    800035a4:	85d2                	mv	a1,s4
    800035a6:	855e                	mv	a0,s7
    800035a8:	c63fe0ef          	jal	8000220a <either_copyout>
    800035ac:	05850763          	beq	a0,s8,800035fa <readi+0xb2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    800035b0:	854a                	mv	a0,s2
    800035b2:	e42ff0ef          	jal	80002bf4 <brelse>
  for (tot = 0; tot < n; tot += m, off += m, dst += m) {
    800035b6:	013d09bb          	addw	s3,s10,s3
    800035ba:	009d04bb          	addw	s1,s10,s1
    800035be:	9a6e                	add	s4,s4,s11
    800035c0:	0559f763          	bgeu	s3,s5,8000360e <readi+0xc6>
    uint addr = bmap(ip, off / BSIZE);
    800035c4:	00a4d59b          	srliw	a1,s1,0xa
    800035c8:	855a                	mv	a0,s6
    800035ca:	8a7ff0ef          	jal	80002e70 <bmap>
    800035ce:	0005059b          	sext.w	a1,a0
    if (addr == 0)
    800035d2:	c5b1                	beqz	a1,8000361e <readi+0xd6>
    bp = bread(ip->dev, addr);
    800035d4:	000b2503          	lw	a0,0(s6)
    800035d8:	d14ff0ef          	jal	80002aec <bread>
    800035dc:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off % BSIZE);
    800035de:	3ff4f713          	andi	a4,s1,1023
    800035e2:	40ec87bb          	subw	a5,s9,a4
    800035e6:	413a86bb          	subw	a3,s5,s3
    800035ea:	8d3e                	mv	s10,a5
    800035ec:	2781                	sext.w	a5,a5
    800035ee:	0006861b          	sext.w	a2,a3
    800035f2:	faf671e3          	bgeu	a2,a5,80003594 <readi+0x4c>
    800035f6:	8d36                	mv	s10,a3
    800035f8:	bf71                	j	80003594 <readi+0x4c>
      brelse(bp);
    800035fa:	854a                	mv	a0,s2
    800035fc:	df8ff0ef          	jal	80002bf4 <brelse>
      tot = -1;
    80003600:	59fd                	li	s3,-1
      break;
    80003602:	6946                	ld	s2,80(sp)
    80003604:	7c02                	ld	s8,32(sp)
    80003606:	6ce2                	ld	s9,24(sp)
    80003608:	6d42                	ld	s10,16(sp)
    8000360a:	6da2                	ld	s11,8(sp)
    8000360c:	a831                	j	80003628 <readi+0xe0>
    8000360e:	6946                	ld	s2,80(sp)
    80003610:	7c02                	ld	s8,32(sp)
    80003612:	6ce2                	ld	s9,24(sp)
    80003614:	6d42                	ld	s10,16(sp)
    80003616:	6da2                	ld	s11,8(sp)
    80003618:	a801                	j	80003628 <readi+0xe0>
  for (tot = 0; tot < n; tot += m, off += m, dst += m) {
    8000361a:	89d6                	mv	s3,s5
    8000361c:	a031                	j	80003628 <readi+0xe0>
    8000361e:	6946                	ld	s2,80(sp)
    80003620:	7c02                	ld	s8,32(sp)
    80003622:	6ce2                	ld	s9,24(sp)
    80003624:	6d42                	ld	s10,16(sp)
    80003626:	6da2                	ld	s11,8(sp)
  }
  return tot;
    80003628:	0009851b          	sext.w	a0,s3
    8000362c:	69a6                	ld	s3,72(sp)
}
    8000362e:	70a6                	ld	ra,104(sp)
    80003630:	7406                	ld	s0,96(sp)
    80003632:	64e6                	ld	s1,88(sp)
    80003634:	6a06                	ld	s4,64(sp)
    80003636:	7ae2                	ld	s5,56(sp)
    80003638:	7b42                	ld	s6,48(sp)
    8000363a:	7ba2                	ld	s7,40(sp)
    8000363c:	6165                	addi	sp,sp,112
    8000363e:	8082                	ret
    return 0;
    80003640:	4501                	li	a0,0
}
    80003642:	8082                	ret

0000000080003644 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if (off > ip->size || off + n < off)
    80003644:	457c                	lw	a5,76(a0)
    80003646:	10d7e063          	bltu	a5,a3,80003746 <writei+0x102>
{
    8000364a:	7159                	addi	sp,sp,-112
    8000364c:	f486                	sd	ra,104(sp)
    8000364e:	f0a2                	sd	s0,96(sp)
    80003650:	e8ca                	sd	s2,80(sp)
    80003652:	e0d2                	sd	s4,64(sp)
    80003654:	fc56                	sd	s5,56(sp)
    80003656:	f85a                	sd	s6,48(sp)
    80003658:	f45e                	sd	s7,40(sp)
    8000365a:	1880                	addi	s0,sp,112
    8000365c:	8aaa                	mv	s5,a0
    8000365e:	8bae                	mv	s7,a1
    80003660:	8a32                	mv	s4,a2
    80003662:	8936                	mv	s2,a3
    80003664:	8b3a                	mv	s6,a4
  if (off > ip->size || off + n < off)
    80003666:	00e687bb          	addw	a5,a3,a4
    8000366a:	0ed7e063          	bltu	a5,a3,8000374a <writei+0x106>
    return -1;
  if (off + n > MAXFILE * BSIZE)
    8000366e:	00043737          	lui	a4,0x43
    80003672:	0cf76e63          	bltu	a4,a5,8000374e <writei+0x10a>
    80003676:	e4ce                	sd	s3,72(sp)
    return -1;

  for (tot = 0; tot < n; tot += m, off += m, src += m) {
    80003678:	0a0b0f63          	beqz	s6,80003736 <writei+0xf2>
    8000367c:	eca6                	sd	s1,88(sp)
    8000367e:	f062                	sd	s8,32(sp)
    80003680:	ec66                	sd	s9,24(sp)
    80003682:	e86a                	sd	s10,16(sp)
    80003684:	e46e                	sd	s11,8(sp)
    80003686:	4981                	li	s3,0
    uint addr = bmap(ip, off / BSIZE);
    if (addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off % BSIZE);
    80003688:	40000c93          	li	s9,1024
    if (either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    8000368c:	5c7d                	li	s8,-1
    8000368e:	a825                	j	800036c6 <writei+0x82>
    80003690:	020d1d93          	slli	s11,s10,0x20
    80003694:	020ddd93          	srli	s11,s11,0x20
    80003698:	05848513          	addi	a0,s1,88
    8000369c:	86ee                	mv	a3,s11
    8000369e:	8652                	mv	a2,s4
    800036a0:	85de                	mv	a1,s7
    800036a2:	953a                	add	a0,a0,a4
    800036a4:	bb1fe0ef          	jal	80002254 <either_copyin>
    800036a8:	05850a63          	beq	a0,s8,800036fc <writei+0xb8>
      brelse(bp);
      break;
    }
    log_write(bp);
    800036ac:	8526                	mv	a0,s1
    800036ae:	67e000ef          	jal	80003d2c <log_write>
    brelse(bp);
    800036b2:	8526                	mv	a0,s1
    800036b4:	d40ff0ef          	jal	80002bf4 <brelse>
  for (tot = 0; tot < n; tot += m, off += m, src += m) {
    800036b8:	013d09bb          	addw	s3,s10,s3
    800036bc:	012d093b          	addw	s2,s10,s2
    800036c0:	9a6e                	add	s4,s4,s11
    800036c2:	0569f063          	bgeu	s3,s6,80003702 <writei+0xbe>
    uint addr = bmap(ip, off / BSIZE);
    800036c6:	00a9559b          	srliw	a1,s2,0xa
    800036ca:	8556                	mv	a0,s5
    800036cc:	fa4ff0ef          	jal	80002e70 <bmap>
    800036d0:	0005059b          	sext.w	a1,a0
    if (addr == 0)
    800036d4:	c59d                	beqz	a1,80003702 <writei+0xbe>
    bp = bread(ip->dev, addr);
    800036d6:	000aa503          	lw	a0,0(s5)
    800036da:	c12ff0ef          	jal	80002aec <bread>
    800036de:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off % BSIZE);
    800036e0:	3ff97713          	andi	a4,s2,1023
    800036e4:	40ec87bb          	subw	a5,s9,a4
    800036e8:	413b06bb          	subw	a3,s6,s3
    800036ec:	8d3e                	mv	s10,a5
    800036ee:	2781                	sext.w	a5,a5
    800036f0:	0006861b          	sext.w	a2,a3
    800036f4:	f8f67ee3          	bgeu	a2,a5,80003690 <writei+0x4c>
    800036f8:	8d36                	mv	s10,a3
    800036fa:	bf59                	j	80003690 <writei+0x4c>
      brelse(bp);
    800036fc:	8526                	mv	a0,s1
    800036fe:	cf6ff0ef          	jal	80002bf4 <brelse>
  }

  if (off > ip->size)
    80003702:	04caa783          	lw	a5,76(s5)
    80003706:	0327fa63          	bgeu	a5,s2,8000373a <writei+0xf6>
    ip->size = off;
    8000370a:	052aa623          	sw	s2,76(s5)
    8000370e:	64e6                	ld	s1,88(sp)
    80003710:	7c02                	ld	s8,32(sp)
    80003712:	6ce2                	ld	s9,24(sp)
    80003714:	6d42                	ld	s10,16(sp)
    80003716:	6da2                	ld	s11,8(sp)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    80003718:	8556                	mv	a0,s5
    8000371a:	9ebff0ef          	jal	80003104 <iupdate>

  return tot;
    8000371e:	0009851b          	sext.w	a0,s3
    80003722:	69a6                	ld	s3,72(sp)
}
    80003724:	70a6                	ld	ra,104(sp)
    80003726:	7406                	ld	s0,96(sp)
    80003728:	6946                	ld	s2,80(sp)
    8000372a:	6a06                	ld	s4,64(sp)
    8000372c:	7ae2                	ld	s5,56(sp)
    8000372e:	7b42                	ld	s6,48(sp)
    80003730:	7ba2                	ld	s7,40(sp)
    80003732:	6165                	addi	sp,sp,112
    80003734:	8082                	ret
  for (tot = 0; tot < n; tot += m, off += m, src += m) {
    80003736:	89da                	mv	s3,s6
    80003738:	b7c5                	j	80003718 <writei+0xd4>
    8000373a:	64e6                	ld	s1,88(sp)
    8000373c:	7c02                	ld	s8,32(sp)
    8000373e:	6ce2                	ld	s9,24(sp)
    80003740:	6d42                	ld	s10,16(sp)
    80003742:	6da2                	ld	s11,8(sp)
    80003744:	bfd1                	j	80003718 <writei+0xd4>
    return -1;
    80003746:	557d                	li	a0,-1
}
    80003748:	8082                	ret
    return -1;
    8000374a:	557d                	li	a0,-1
    8000374c:	bfe1                	j	80003724 <writei+0xe0>
    return -1;
    8000374e:	557d                	li	a0,-1
    80003750:	bfd1                	j	80003724 <writei+0xe0>

0000000080003752 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80003752:	1141                	addi	sp,sp,-16
    80003754:	e406                	sd	ra,8(sp)
    80003756:	e022                	sd	s0,0(sp)
    80003758:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    8000375a:	4639                	li	a2,14
    8000375c:	de8fd0ef          	jal	80000d44 <strncmp>
}
    80003760:	60a2                	ld	ra,8(sp)
    80003762:	6402                	ld	s0,0(sp)
    80003764:	0141                	addi	sp,sp,16
    80003766:	8082                	ret

0000000080003768 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode *
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80003768:	7139                	addi	sp,sp,-64
    8000376a:	fc06                	sd	ra,56(sp)
    8000376c:	f822                	sd	s0,48(sp)
    8000376e:	f426                	sd	s1,40(sp)
    80003770:	f04a                	sd	s2,32(sp)
    80003772:	ec4e                	sd	s3,24(sp)
    80003774:	e852                	sd	s4,16(sp)
    80003776:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if (dp->type != T_DIR)
    80003778:	04451703          	lh	a4,68(a0)
    8000377c:	4785                	li	a5,1
    8000377e:	00f71a63          	bne	a4,a5,80003792 <dirlookup+0x2a>
    80003782:	892a                	mv	s2,a0
    80003784:	89ae                	mv	s3,a1
    80003786:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for (off = 0; off < dp->size; off += sizeof(de)) {
    80003788:	457c                	lw	a5,76(a0)
    8000378a:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    8000378c:	4501                	li	a0,0
  for (off = 0; off < dp->size; off += sizeof(de)) {
    8000378e:	e39d                	bnez	a5,800037b4 <dirlookup+0x4c>
    80003790:	a095                	j	800037f4 <dirlookup+0x8c>
    panic("dirlookup not DIR");
    80003792:	00004517          	auipc	a0,0x4
    80003796:	d0e50513          	addi	a0,a0,-754 # 800074a0 <etext+0x4a0>
    8000379a:	83afd0ef          	jal	800007d4 <panic>
      panic("dirlookup read");
    8000379e:	00004517          	auipc	a0,0x4
    800037a2:	d1a50513          	addi	a0,a0,-742 # 800074b8 <etext+0x4b8>
    800037a6:	82efd0ef          	jal	800007d4 <panic>
  for (off = 0; off < dp->size; off += sizeof(de)) {
    800037aa:	24c1                	addiw	s1,s1,16
    800037ac:	04c92783          	lw	a5,76(s2)
    800037b0:	04f4f163          	bgeu	s1,a5,800037f2 <dirlookup+0x8a>
    if (readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800037b4:	4741                	li	a4,16
    800037b6:	86a6                	mv	a3,s1
    800037b8:	fc040613          	addi	a2,s0,-64
    800037bc:	4581                	li	a1,0
    800037be:	854a                	mv	a0,s2
    800037c0:	d89ff0ef          	jal	80003548 <readi>
    800037c4:	47c1                	li	a5,16
    800037c6:	fcf51ce3          	bne	a0,a5,8000379e <dirlookup+0x36>
    if (de.inum == 0)
    800037ca:	fc045783          	lhu	a5,-64(s0)
    800037ce:	dff1                	beqz	a5,800037aa <dirlookup+0x42>
    if (namecmp(name, de.name) == 0) {
    800037d0:	fc240593          	addi	a1,s0,-62
    800037d4:	854e                	mv	a0,s3
    800037d6:	f7dff0ef          	jal	80003752 <namecmp>
    800037da:	f961                	bnez	a0,800037aa <dirlookup+0x42>
      if (poff)
    800037dc:	000a0463          	beqz	s4,800037e4 <dirlookup+0x7c>
        *poff = off;
    800037e0:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    800037e4:	fc045583          	lhu	a1,-64(s0)
    800037e8:	00092503          	lw	a0,0(s2)
    800037ec:	f58ff0ef          	jal	80002f44 <iget>
    800037f0:	a011                	j	800037f4 <dirlookup+0x8c>
  return 0;
    800037f2:	4501                	li	a0,0
}
    800037f4:	70e2                	ld	ra,56(sp)
    800037f6:	7442                	ld	s0,48(sp)
    800037f8:	74a2                	ld	s1,40(sp)
    800037fa:	7902                	ld	s2,32(sp)
    800037fc:	69e2                	ld	s3,24(sp)
    800037fe:	6a42                	ld	s4,16(sp)
    80003800:	6121                	addi	sp,sp,64
    80003802:	8082                	ret

0000000080003804 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode *
namex(char *path, int nameiparent, char *name)
{
    80003804:	711d                	addi	sp,sp,-96
    80003806:	ec86                	sd	ra,88(sp)
    80003808:	e8a2                	sd	s0,80(sp)
    8000380a:	e4a6                	sd	s1,72(sp)
    8000380c:	e0ca                	sd	s2,64(sp)
    8000380e:	fc4e                	sd	s3,56(sp)
    80003810:	f852                	sd	s4,48(sp)
    80003812:	f456                	sd	s5,40(sp)
    80003814:	f05a                	sd	s6,32(sp)
    80003816:	ec5e                	sd	s7,24(sp)
    80003818:	e862                	sd	s8,16(sp)
    8000381a:	e466                	sd	s9,8(sp)
    8000381c:	1080                	addi	s0,sp,96
    8000381e:	84aa                	mv	s1,a0
    80003820:	8b2e                	mv	s6,a1
    80003822:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if (*path == '/')
    80003824:	00054703          	lbu	a4,0(a0)
    80003828:	02f00793          	li	a5,47
    8000382c:	00f70e63          	beq	a4,a5,80003848 <namex+0x44>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80003830:	874fe0ef          	jal	800018a4 <myproc>
    80003834:	15053503          	ld	a0,336(a0)
    80003838:	94bff0ef          	jal	80003182 <idup>
    8000383c:	8a2a                	mv	s4,a0
  while (*path == '/')
    8000383e:	02f00913          	li	s2,47
  if (len >= DIRSIZ)
    80003842:	4c35                	li	s8,13

  while ((path = skipelem(path, name)) != 0) {
    ilock(ip);
    if (ip->type != T_DIR) {
    80003844:	4b85                	li	s7,1
    80003846:	a871                	j	800038e2 <namex+0xde>
    ip = iget(ROOTDEV, ROOTINO);
    80003848:	4585                	li	a1,1
    8000384a:	4505                	li	a0,1
    8000384c:	ef8ff0ef          	jal	80002f44 <iget>
    80003850:	8a2a                	mv	s4,a0
    80003852:	b7f5                	j	8000383e <namex+0x3a>
      iunlockput(ip);
    80003854:	8552                	mv	a0,s4
    80003856:	b6dff0ef          	jal	800033c2 <iunlockput>
      return 0;
    8000385a:	4a01                	li	s4,0
  if (nameiparent) {
    iput(ip);
    return 0;
  }
  return ip;
}
    8000385c:	8552                	mv	a0,s4
    8000385e:	60e6                	ld	ra,88(sp)
    80003860:	6446                	ld	s0,80(sp)
    80003862:	64a6                	ld	s1,72(sp)
    80003864:	6906                	ld	s2,64(sp)
    80003866:	79e2                	ld	s3,56(sp)
    80003868:	7a42                	ld	s4,48(sp)
    8000386a:	7aa2                	ld	s5,40(sp)
    8000386c:	7b02                	ld	s6,32(sp)
    8000386e:	6be2                	ld	s7,24(sp)
    80003870:	6c42                	ld	s8,16(sp)
    80003872:	6ca2                	ld	s9,8(sp)
    80003874:	6125                	addi	sp,sp,96
    80003876:	8082                	ret
      iunlock(ip);
    80003878:	8552                	mv	a0,s4
    8000387a:	9edff0ef          	jal	80003266 <iunlock>
      return ip;
    8000387e:	bff9                	j	8000385c <namex+0x58>
      iunlockput(ip);
    80003880:	8552                	mv	a0,s4
    80003882:	b41ff0ef          	jal	800033c2 <iunlockput>
      return 0;
    80003886:	8a4e                	mv	s4,s3
    80003888:	bfd1                	j	8000385c <namex+0x58>
  len = path - s;
    8000388a:	40998633          	sub	a2,s3,s1
    8000388e:	00060c9b          	sext.w	s9,a2
  if (len >= DIRSIZ)
    80003892:	099c5063          	bge	s8,s9,80003912 <namex+0x10e>
    memmove(name, s, DIRSIZ);
    80003896:	4639                	li	a2,14
    80003898:	85a6                	mv	a1,s1
    8000389a:	8556                	mv	a0,s5
    8000389c:	c38fd0ef          	jal	80000cd4 <memmove>
    800038a0:	84ce                	mv	s1,s3
  while (*path == '/')
    800038a2:	0004c783          	lbu	a5,0(s1)
    800038a6:	01279763          	bne	a5,s2,800038b4 <namex+0xb0>
    path++;
    800038aa:	0485                	addi	s1,s1,1
  while (*path == '/')
    800038ac:	0004c783          	lbu	a5,0(s1)
    800038b0:	ff278de3          	beq	a5,s2,800038aa <namex+0xa6>
    ilock(ip);
    800038b4:	8552                	mv	a0,s4
    800038b6:	903ff0ef          	jal	800031b8 <ilock>
    if (ip->type != T_DIR) {
    800038ba:	044a1783          	lh	a5,68(s4)
    800038be:	f9779be3          	bne	a5,s7,80003854 <namex+0x50>
    if (nameiparent && *path == '\0') {
    800038c2:	000b0563          	beqz	s6,800038cc <namex+0xc8>
    800038c6:	0004c783          	lbu	a5,0(s1)
    800038ca:	d7dd                	beqz	a5,80003878 <namex+0x74>
    if ((next = dirlookup(ip, name, 0)) == 0) {
    800038cc:	4601                	li	a2,0
    800038ce:	85d6                	mv	a1,s5
    800038d0:	8552                	mv	a0,s4
    800038d2:	e97ff0ef          	jal	80003768 <dirlookup>
    800038d6:	89aa                	mv	s3,a0
    800038d8:	d545                	beqz	a0,80003880 <namex+0x7c>
    iunlockput(ip);
    800038da:	8552                	mv	a0,s4
    800038dc:	ae7ff0ef          	jal	800033c2 <iunlockput>
    ip = next;
    800038e0:	8a4e                	mv	s4,s3
  while (*path == '/')
    800038e2:	0004c783          	lbu	a5,0(s1)
    800038e6:	01279763          	bne	a5,s2,800038f4 <namex+0xf0>
    path++;
    800038ea:	0485                	addi	s1,s1,1
  while (*path == '/')
    800038ec:	0004c783          	lbu	a5,0(s1)
    800038f0:	ff278de3          	beq	a5,s2,800038ea <namex+0xe6>
  if (*path == 0)
    800038f4:	cb8d                	beqz	a5,80003926 <namex+0x122>
  while (*path != '/' && *path != 0)
    800038f6:	0004c783          	lbu	a5,0(s1)
    800038fa:	89a6                	mv	s3,s1
  len = path - s;
    800038fc:	4c81                	li	s9,0
    800038fe:	4601                	li	a2,0
  while (*path != '/' && *path != 0)
    80003900:	01278963          	beq	a5,s2,80003912 <namex+0x10e>
    80003904:	d3d9                	beqz	a5,8000388a <namex+0x86>
    path++;
    80003906:	0985                	addi	s3,s3,1
  while (*path != '/' && *path != 0)
    80003908:	0009c783          	lbu	a5,0(s3)
    8000390c:	ff279ce3          	bne	a5,s2,80003904 <namex+0x100>
    80003910:	bfad                	j	8000388a <namex+0x86>
    memmove(name, s, len);
    80003912:	2601                	sext.w	a2,a2
    80003914:	85a6                	mv	a1,s1
    80003916:	8556                	mv	a0,s5
    80003918:	bbcfd0ef          	jal	80000cd4 <memmove>
    name[len] = 0;
    8000391c:	9cd6                	add	s9,s9,s5
    8000391e:	000c8023          	sb	zero,0(s9) # 2000 <_entry-0x7fffe000>
    80003922:	84ce                	mv	s1,s3
    80003924:	bfbd                	j	800038a2 <namex+0x9e>
  if (nameiparent) {
    80003926:	f20b0be3          	beqz	s6,8000385c <namex+0x58>
    iput(ip);
    8000392a:	8552                	mv	a0,s4
    8000392c:	a0fff0ef          	jal	8000333a <iput>
    return 0;
    80003930:	4a01                	li	s4,0
    80003932:	b72d                	j	8000385c <namex+0x58>

0000000080003934 <dirlink>:
{
    80003934:	7139                	addi	sp,sp,-64
    80003936:	fc06                	sd	ra,56(sp)
    80003938:	f822                	sd	s0,48(sp)
    8000393a:	f04a                	sd	s2,32(sp)
    8000393c:	ec4e                	sd	s3,24(sp)
    8000393e:	e852                	sd	s4,16(sp)
    80003940:	0080                	addi	s0,sp,64
    80003942:	892a                	mv	s2,a0
    80003944:	8a2e                	mv	s4,a1
    80003946:	89b2                	mv	s3,a2
  if ((ip = dirlookup(dp, name, 0)) != 0) {
    80003948:	4601                	li	a2,0
    8000394a:	e1fff0ef          	jal	80003768 <dirlookup>
    8000394e:	e535                	bnez	a0,800039ba <dirlink+0x86>
    80003950:	f426                	sd	s1,40(sp)
  for (off = 0; off < dp->size; off += sizeof(de)) {
    80003952:	04c92483          	lw	s1,76(s2)
    80003956:	c48d                	beqz	s1,80003980 <dirlink+0x4c>
    80003958:	4481                	li	s1,0
    if (readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000395a:	4741                	li	a4,16
    8000395c:	86a6                	mv	a3,s1
    8000395e:	fc040613          	addi	a2,s0,-64
    80003962:	4581                	li	a1,0
    80003964:	854a                	mv	a0,s2
    80003966:	be3ff0ef          	jal	80003548 <readi>
    8000396a:	47c1                	li	a5,16
    8000396c:	04f51b63          	bne	a0,a5,800039c2 <dirlink+0x8e>
    if (de.inum == 0)
    80003970:	fc045783          	lhu	a5,-64(s0)
    80003974:	c791                	beqz	a5,80003980 <dirlink+0x4c>
  for (off = 0; off < dp->size; off += sizeof(de)) {
    80003976:	24c1                	addiw	s1,s1,16
    80003978:	04c92783          	lw	a5,76(s2)
    8000397c:	fcf4efe3          	bltu	s1,a5,8000395a <dirlink+0x26>
  strncpy(de.name, name, DIRSIZ);
    80003980:	4639                	li	a2,14
    80003982:	85d2                	mv	a1,s4
    80003984:	fc240513          	addi	a0,s0,-62
    80003988:	bf2fd0ef          	jal	80000d7a <strncpy>
  de.inum = inum;
    8000398c:	fd341023          	sh	s3,-64(s0)
  if (writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003990:	4741                	li	a4,16
    80003992:	86a6                	mv	a3,s1
    80003994:	fc040613          	addi	a2,s0,-64
    80003998:	4581                	li	a1,0
    8000399a:	854a                	mv	a0,s2
    8000399c:	ca9ff0ef          	jal	80003644 <writei>
    800039a0:	1541                	addi	a0,a0,-16
    800039a2:	00a03533          	snez	a0,a0
    800039a6:	40a00533          	neg	a0,a0
    800039aa:	74a2                	ld	s1,40(sp)
}
    800039ac:	70e2                	ld	ra,56(sp)
    800039ae:	7442                	ld	s0,48(sp)
    800039b0:	7902                	ld	s2,32(sp)
    800039b2:	69e2                	ld	s3,24(sp)
    800039b4:	6a42                	ld	s4,16(sp)
    800039b6:	6121                	addi	sp,sp,64
    800039b8:	8082                	ret
    iput(ip);
    800039ba:	981ff0ef          	jal	8000333a <iput>
    return -1;
    800039be:	557d                	li	a0,-1
    800039c0:	b7f5                	j	800039ac <dirlink+0x78>
      panic("dirlink read");
    800039c2:	00004517          	auipc	a0,0x4
    800039c6:	b0650513          	addi	a0,a0,-1274 # 800074c8 <etext+0x4c8>
    800039ca:	e0bfc0ef          	jal	800007d4 <panic>

00000000800039ce <namei>:

struct inode *
namei(char *path)
{
    800039ce:	1101                	addi	sp,sp,-32
    800039d0:	ec06                	sd	ra,24(sp)
    800039d2:	e822                	sd	s0,16(sp)
    800039d4:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    800039d6:	fe040613          	addi	a2,s0,-32
    800039da:	4581                	li	a1,0
    800039dc:	e29ff0ef          	jal	80003804 <namex>
}
    800039e0:	60e2                	ld	ra,24(sp)
    800039e2:	6442                	ld	s0,16(sp)
    800039e4:	6105                	addi	sp,sp,32
    800039e6:	8082                	ret

00000000800039e8 <nameiparent>:

struct inode *
nameiparent(char *path, char *name)
{
    800039e8:	1141                	addi	sp,sp,-16
    800039ea:	e406                	sd	ra,8(sp)
    800039ec:	e022                	sd	s0,0(sp)
    800039ee:	0800                	addi	s0,sp,16
    800039f0:	862e                	mv	a2,a1
  return namex(path, 1, name);
    800039f2:	4585                	li	a1,1
    800039f4:	e11ff0ef          	jal	80003804 <namex>
}
    800039f8:	60a2                	ld	ra,8(sp)
    800039fa:	6402                	ld	s0,0(sp)
    800039fc:	0141                	addi	sp,sp,16
    800039fe:	8082                	ret

0000000080003a00 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    80003a00:	1101                	addi	sp,sp,-32
    80003a02:	ec06                	sd	ra,24(sp)
    80003a04:	e822                	sd	s0,16(sp)
    80003a06:	e426                	sd	s1,8(sp)
    80003a08:	e04a                	sd	s2,0(sp)
    80003a0a:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80003a0c:	0001f917          	auipc	s2,0x1f
    80003a10:	88c90913          	addi	s2,s2,-1908 # 80022298 <log>
    80003a14:	01892583          	lw	a1,24(s2)
    80003a18:	02492503          	lw	a0,36(s2)
    80003a1c:	8d0ff0ef          	jal	80002aec <bread>
    80003a20:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *)(buf->data);
  int i;
  hb->n = log.lh.n;
    80003a22:	02c92603          	lw	a2,44(s2)
    80003a26:	cd30                	sw	a2,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80003a28:	00c05f63          	blez	a2,80003a46 <write_head+0x46>
    80003a2c:	0001f717          	auipc	a4,0x1f
    80003a30:	89c70713          	addi	a4,a4,-1892 # 800222c8 <log+0x30>
    80003a34:	87aa                	mv	a5,a0
    80003a36:	060a                	slli	a2,a2,0x2
    80003a38:	962a                	add	a2,a2,a0
    hb->block[i] = log.lh.block[i];
    80003a3a:	4314                	lw	a3,0(a4)
    80003a3c:	cff4                	sw	a3,92(a5)
  for (i = 0; i < log.lh.n; i++) {
    80003a3e:	0711                	addi	a4,a4,4
    80003a40:	0791                	addi	a5,a5,4
    80003a42:	fec79ce3          	bne	a5,a2,80003a3a <write_head+0x3a>
  }
  bwrite(buf);
    80003a46:	8526                	mv	a0,s1
    80003a48:	97aff0ef          	jal	80002bc2 <bwrite>
  brelse(buf);
    80003a4c:	8526                	mv	a0,s1
    80003a4e:	9a6ff0ef          	jal	80002bf4 <brelse>
}
    80003a52:	60e2                	ld	ra,24(sp)
    80003a54:	6442                	ld	s0,16(sp)
    80003a56:	64a2                	ld	s1,8(sp)
    80003a58:	6902                	ld	s2,0(sp)
    80003a5a:	6105                	addi	sp,sp,32
    80003a5c:	8082                	ret

0000000080003a5e <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80003a5e:	0001f797          	auipc	a5,0x1f
    80003a62:	8667a783          	lw	a5,-1946(a5) # 800222c4 <log+0x2c>
    80003a66:	0af05e63          	blez	a5,80003b22 <install_trans+0xc4>
{
    80003a6a:	715d                	addi	sp,sp,-80
    80003a6c:	e486                	sd	ra,72(sp)
    80003a6e:	e0a2                	sd	s0,64(sp)
    80003a70:	fc26                	sd	s1,56(sp)
    80003a72:	f84a                	sd	s2,48(sp)
    80003a74:	f44e                	sd	s3,40(sp)
    80003a76:	f052                	sd	s4,32(sp)
    80003a78:	ec56                	sd	s5,24(sp)
    80003a7a:	e85a                	sd	s6,16(sp)
    80003a7c:	e45e                	sd	s7,8(sp)
    80003a7e:	0880                	addi	s0,sp,80
    80003a80:	8b2a                	mv	s6,a0
    80003a82:	0001fa97          	auipc	s5,0x1f
    80003a86:	846a8a93          	addi	s5,s5,-1978 # 800222c8 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003a8a:	4981                	li	s3,0
      printk("recovering tail %d dst %d\n", tail, log.lh.block[tail]);
    80003a8c:	00004b97          	auipc	s7,0x4
    80003a90:	a4cb8b93          	addi	s7,s7,-1460 # 800074d8 <etext+0x4d8>
    struct buf *lbuf = bread(log.dev, log.start + tail + 1); // read log block
    80003a94:	0001fa17          	auipc	s4,0x1f
    80003a98:	804a0a13          	addi	s4,s4,-2044 # 80022298 <log>
    80003a9c:	a025                	j	80003ac4 <install_trans+0x66>
      printk("recovering tail %d dst %d\n", tail, log.lh.block[tail]);
    80003a9e:	000aa603          	lw	a2,0(s5)
    80003aa2:	85ce                	mv	a1,s3
    80003aa4:	855e                	mv	a0,s7
    80003aa6:	a49fc0ef          	jal	800004ee <printk>
    80003aaa:	a839                	j	80003ac8 <install_trans+0x6a>
    brelse(lbuf);
    80003aac:	854a                	mv	a0,s2
    80003aae:	946ff0ef          	jal	80002bf4 <brelse>
    brelse(dbuf);
    80003ab2:	8526                	mv	a0,s1
    80003ab4:	940ff0ef          	jal	80002bf4 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003ab8:	2985                	addiw	s3,s3,1
    80003aba:	0a91                	addi	s5,s5,4
    80003abc:	02ca2783          	lw	a5,44(s4)
    80003ac0:	04f9d663          	bge	s3,a5,80003b0c <install_trans+0xae>
    if (recovering) {
    80003ac4:	fc0b1de3          	bnez	s6,80003a9e <install_trans+0x40>
    struct buf *lbuf = bread(log.dev, log.start + tail + 1); // read log block
    80003ac8:	018a2583          	lw	a1,24(s4)
    80003acc:	013585bb          	addw	a1,a1,s3
    80003ad0:	2585                	addiw	a1,a1,1
    80003ad2:	024a2503          	lw	a0,36(s4)
    80003ad6:	816ff0ef          	jal	80002aec <bread>
    80003ada:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]);   // read dst
    80003adc:	000aa583          	lw	a1,0(s5)
    80003ae0:	024a2503          	lw	a0,36(s4)
    80003ae4:	808ff0ef          	jal	80002aec <bread>
    80003ae8:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE); // copy block to dst
    80003aea:	40000613          	li	a2,1024
    80003aee:	05890593          	addi	a1,s2,88
    80003af2:	05850513          	addi	a0,a0,88
    80003af6:	9defd0ef          	jal	80000cd4 <memmove>
    bwrite(dbuf);                           // write dst to disk
    80003afa:	8526                	mv	a0,s1
    80003afc:	8c6ff0ef          	jal	80002bc2 <bwrite>
    if (recovering == 0)
    80003b00:	fa0b16e3          	bnez	s6,80003aac <install_trans+0x4e>
      bunpin(dbuf);
    80003b04:	8526                	mv	a0,s1
    80003b06:	9aaff0ef          	jal	80002cb0 <bunpin>
    80003b0a:	b74d                	j	80003aac <install_trans+0x4e>
}
    80003b0c:	60a6                	ld	ra,72(sp)
    80003b0e:	6406                	ld	s0,64(sp)
    80003b10:	74e2                	ld	s1,56(sp)
    80003b12:	7942                	ld	s2,48(sp)
    80003b14:	79a2                	ld	s3,40(sp)
    80003b16:	7a02                	ld	s4,32(sp)
    80003b18:	6ae2                	ld	s5,24(sp)
    80003b1a:	6b42                	ld	s6,16(sp)
    80003b1c:	6ba2                	ld	s7,8(sp)
    80003b1e:	6161                	addi	sp,sp,80
    80003b20:	8082                	ret
    80003b22:	8082                	ret

0000000080003b24 <initlog>:
{
    80003b24:	7179                	addi	sp,sp,-48
    80003b26:	f406                	sd	ra,40(sp)
    80003b28:	f022                	sd	s0,32(sp)
    80003b2a:	ec26                	sd	s1,24(sp)
    80003b2c:	e84a                	sd	s2,16(sp)
    80003b2e:	e44e                	sd	s3,8(sp)
    80003b30:	1800                	addi	s0,sp,48
    80003b32:	892a                	mv	s2,a0
    80003b34:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    80003b36:	0001e497          	auipc	s1,0x1e
    80003b3a:	76248493          	addi	s1,s1,1890 # 80022298 <log>
    80003b3e:	00004597          	auipc	a1,0x4
    80003b42:	9ba58593          	addi	a1,a1,-1606 # 800074f8 <etext+0x4f8>
    80003b46:	8526                	mv	a0,s1
    80003b48:	fe5fc0ef          	jal	80000b2c <initlock>
  log.start = sb->logstart;
    80003b4c:	0149a583          	lw	a1,20(s3)
    80003b50:	cc8c                	sw	a1,24(s1)
  log.dev = dev;
    80003b52:	0324a223          	sw	s2,36(s1)
  struct buf *buf = bread(log.dev, log.start);
    80003b56:	854a                	mv	a0,s2
    80003b58:	f95fe0ef          	jal	80002aec <bread>
  log.lh.n = lh->n;
    80003b5c:	4d30                	lw	a2,88(a0)
    80003b5e:	d4d0                	sw	a2,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    80003b60:	00c05f63          	blez	a2,80003b7e <initlog+0x5a>
    80003b64:	87aa                	mv	a5,a0
    80003b66:	0001e717          	auipc	a4,0x1e
    80003b6a:	76270713          	addi	a4,a4,1890 # 800222c8 <log+0x30>
    80003b6e:	060a                	slli	a2,a2,0x2
    80003b70:	962a                	add	a2,a2,a0
    log.lh.block[i] = lh->block[i];
    80003b72:	4ff4                	lw	a3,92(a5)
    80003b74:	c314                	sw	a3,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80003b76:	0791                	addi	a5,a5,4
    80003b78:	0711                	addi	a4,a4,4
    80003b7a:	fec79ce3          	bne	a5,a2,80003b72 <initlog+0x4e>
  brelse(buf);
    80003b7e:	876ff0ef          	jal	80002bf4 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    80003b82:	4505                	li	a0,1
    80003b84:	edbff0ef          	jal	80003a5e <install_trans>
  log.lh.n = 0;
    80003b88:	0001e797          	auipc	a5,0x1e
    80003b8c:	7207ae23          	sw	zero,1852(a5) # 800222c4 <log+0x2c>
  write_head(); // clear the log
    80003b90:	e71ff0ef          	jal	80003a00 <write_head>
}
    80003b94:	70a2                	ld	ra,40(sp)
    80003b96:	7402                	ld	s0,32(sp)
    80003b98:	64e2                	ld	s1,24(sp)
    80003b9a:	6942                	ld	s2,16(sp)
    80003b9c:	69a2                	ld	s3,8(sp)
    80003b9e:	6145                	addi	sp,sp,48
    80003ba0:	8082                	ret

0000000080003ba2 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    80003ba2:	1101                	addi	sp,sp,-32
    80003ba4:	ec06                	sd	ra,24(sp)
    80003ba6:	e822                	sd	s0,16(sp)
    80003ba8:	e426                	sd	s1,8(sp)
    80003baa:	e04a                	sd	s2,0(sp)
    80003bac:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    80003bae:	0001e517          	auipc	a0,0x1e
    80003bb2:	6ea50513          	addi	a0,a0,1770 # 80022298 <log>
    80003bb6:	ff7fc0ef          	jal	80000bac <acquire>
  while (1) {
    if (log.committing) {
    80003bba:	0001e497          	auipc	s1,0x1e
    80003bbe:	6de48493          	addi	s1,s1,1758 # 80022298 <log>
      sleep(&log, &log.lock);
    } else if (log.lh.n + (log.outstanding + 1) * MAXOPBLOCKS > LOGBLOCKS) {
    80003bc2:	4979                	li	s2,30
    80003bc4:	a029                	j	80003bce <begin_op+0x2c>
      sleep(&log, &log.lock);
    80003bc6:	85a6                	mv	a1,s1
    80003bc8:	8526                	mv	a0,s1
    80003bca:	ae4fe0ef          	jal	80001eae <sleep>
    if (log.committing) {
    80003bce:	509c                	lw	a5,32(s1)
    80003bd0:	fbfd                	bnez	a5,80003bc6 <begin_op+0x24>
    } else if (log.lh.n + (log.outstanding + 1) * MAXOPBLOCKS > LOGBLOCKS) {
    80003bd2:	4cd8                	lw	a4,28(s1)
    80003bd4:	2705                	addiw	a4,a4,1
    80003bd6:	0027179b          	slliw	a5,a4,0x2
    80003bda:	9fb9                	addw	a5,a5,a4
    80003bdc:	0017979b          	slliw	a5,a5,0x1
    80003be0:	54d4                	lw	a3,44(s1)
    80003be2:	9fb5                	addw	a5,a5,a3
    80003be4:	00f95763          	bge	s2,a5,80003bf2 <begin_op+0x50>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    80003be8:	85a6                	mv	a1,s1
    80003bea:	8526                	mv	a0,s1
    80003bec:	ac2fe0ef          	jal	80001eae <sleep>
    80003bf0:	bff9                	j	80003bce <begin_op+0x2c>
    } else {
      log.outstanding += 1;
    80003bf2:	0001e517          	auipc	a0,0x1e
    80003bf6:	6a650513          	addi	a0,a0,1702 # 80022298 <log>
    80003bfa:	cd58                	sw	a4,28(a0)
      release(&log.lock);
    80003bfc:	844fd0ef          	jal	80000c40 <release>
      break;
    }
  }
}
    80003c00:	60e2                	ld	ra,24(sp)
    80003c02:	6442                	ld	s0,16(sp)
    80003c04:	64a2                	ld	s1,8(sp)
    80003c06:	6902                	ld	s2,0(sp)
    80003c08:	6105                	addi	sp,sp,32
    80003c0a:	8082                	ret

0000000080003c0c <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    80003c0c:	7139                	addi	sp,sp,-64
    80003c0e:	fc06                	sd	ra,56(sp)
    80003c10:	f822                	sd	s0,48(sp)
    80003c12:	f426                	sd	s1,40(sp)
    80003c14:	f04a                	sd	s2,32(sp)
    80003c16:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    80003c18:	0001e497          	auipc	s1,0x1e
    80003c1c:	68048493          	addi	s1,s1,1664 # 80022298 <log>
    80003c20:	8526                	mv	a0,s1
    80003c22:	f8bfc0ef          	jal	80000bac <acquire>
  log.outstanding -= 1;
    80003c26:	4cdc                	lw	a5,28(s1)
    80003c28:	37fd                	addiw	a5,a5,-1
    80003c2a:	0007891b          	sext.w	s2,a5
    80003c2e:	ccdc                	sw	a5,28(s1)
  if (log.committing)
    80003c30:	509c                	lw	a5,32(s1)
    80003c32:	e3b1                	bnez	a5,80003c76 <end_op+0x6a>
    panic("log.committing");
  if (log.outstanding == 0) {
    80003c34:	04091a63          	bnez	s2,80003c88 <end_op+0x7c>
    do_commit = 1;
    log.committing = 1;
    80003c38:	0001e497          	auipc	s1,0x1e
    80003c3c:	66048493          	addi	s1,s1,1632 # 80022298 <log>
    80003c40:	4785                	li	a5,1
    80003c42:	d09c                	sw	a5,32(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    80003c44:	8526                	mv	a0,s1
    80003c46:	ffbfc0ef          	jal	80000c40 <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    80003c4a:	54dc                	lw	a5,44(s1)
    80003c4c:	04f04e63          	bgtz	a5,80003ca8 <end_op+0x9c>
    acquire(&log.lock);
    80003c50:	0001e497          	auipc	s1,0x1e
    80003c54:	64848493          	addi	s1,s1,1608 # 80022298 <log>
    80003c58:	8526                	mv	a0,s1
    80003c5a:	f53fc0ef          	jal	80000bac <acquire>
    log.committing = 0;
    80003c5e:	0204a023          	sw	zero,32(s1)
    log.ncommit += 1;
    80003c62:	549c                	lw	a5,40(s1)
    80003c64:	2785                	addiw	a5,a5,1
    80003c66:	d49c                	sw	a5,40(s1)
    wakeup(&log);
    80003c68:	8526                	mv	a0,s1
    80003c6a:	a90fe0ef          	jal	80001efa <wakeup>
    release(&log.lock);
    80003c6e:	8526                	mv	a0,s1
    80003c70:	fd1fc0ef          	jal	80000c40 <release>
}
    80003c74:	a025                	j	80003c9c <end_op+0x90>
    80003c76:	ec4e                	sd	s3,24(sp)
    80003c78:	e852                	sd	s4,16(sp)
    80003c7a:	e456                	sd	s5,8(sp)
    panic("log.committing");
    80003c7c:	00004517          	auipc	a0,0x4
    80003c80:	88450513          	addi	a0,a0,-1916 # 80007500 <etext+0x500>
    80003c84:	b51fc0ef          	jal	800007d4 <panic>
    wakeup(&log);
    80003c88:	0001e497          	auipc	s1,0x1e
    80003c8c:	61048493          	addi	s1,s1,1552 # 80022298 <log>
    80003c90:	8526                	mv	a0,s1
    80003c92:	a68fe0ef          	jal	80001efa <wakeup>
  release(&log.lock);
    80003c96:	8526                	mv	a0,s1
    80003c98:	fa9fc0ef          	jal	80000c40 <release>
}
    80003c9c:	70e2                	ld	ra,56(sp)
    80003c9e:	7442                	ld	s0,48(sp)
    80003ca0:	74a2                	ld	s1,40(sp)
    80003ca2:	7902                	ld	s2,32(sp)
    80003ca4:	6121                	addi	sp,sp,64
    80003ca6:	8082                	ret
    80003ca8:	ec4e                	sd	s3,24(sp)
    80003caa:	e852                	sd	s4,16(sp)
    80003cac:	e456                	sd	s5,8(sp)
  for (tail = 0; tail < log.lh.n; tail++) {
    80003cae:	0001ea97          	auipc	s5,0x1e
    80003cb2:	61aa8a93          	addi	s5,s5,1562 # 800222c8 <log+0x30>
    struct buf *to = bread(log.dev, log.start + tail + 1); // log block
    80003cb6:	0001ea17          	auipc	s4,0x1e
    80003cba:	5e2a0a13          	addi	s4,s4,1506 # 80022298 <log>
    80003cbe:	018a2583          	lw	a1,24(s4)
    80003cc2:	012585bb          	addw	a1,a1,s2
    80003cc6:	2585                	addiw	a1,a1,1
    80003cc8:	024a2503          	lw	a0,36(s4)
    80003ccc:	e21fe0ef          	jal	80002aec <bread>
    80003cd0:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    80003cd2:	000aa583          	lw	a1,0(s5)
    80003cd6:	024a2503          	lw	a0,36(s4)
    80003cda:	e13fe0ef          	jal	80002aec <bread>
    80003cde:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    80003ce0:	40000613          	li	a2,1024
    80003ce4:	05850593          	addi	a1,a0,88
    80003ce8:	05848513          	addi	a0,s1,88
    80003cec:	fe9fc0ef          	jal	80000cd4 <memmove>
    bwrite(to); // write the log
    80003cf0:	8526                	mv	a0,s1
    80003cf2:	ed1fe0ef          	jal	80002bc2 <bwrite>
    brelse(from);
    80003cf6:	854e                	mv	a0,s3
    80003cf8:	efdfe0ef          	jal	80002bf4 <brelse>
    brelse(to);
    80003cfc:	8526                	mv	a0,s1
    80003cfe:	ef7fe0ef          	jal	80002bf4 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003d02:	2905                	addiw	s2,s2,1
    80003d04:	0a91                	addi	s5,s5,4
    80003d06:	02ca2783          	lw	a5,44(s4)
    80003d0a:	faf94ae3          	blt	s2,a5,80003cbe <end_op+0xb2>
    write_log();      // Write modified blocks from cache to log
    write_head();     // Write header to disk -- the real commit
    80003d0e:	cf3ff0ef          	jal	80003a00 <write_head>
    install_trans(0); // Now install writes to home locations
    80003d12:	4501                	li	a0,0
    80003d14:	d4bff0ef          	jal	80003a5e <install_trans>
    log.lh.n = 0;
    80003d18:	0001e797          	auipc	a5,0x1e
    80003d1c:	5a07a623          	sw	zero,1452(a5) # 800222c4 <log+0x2c>
    write_head(); // Erase the transaction from the log
    80003d20:	ce1ff0ef          	jal	80003a00 <write_head>
    80003d24:	69e2                	ld	s3,24(sp)
    80003d26:	6a42                	ld	s4,16(sp)
    80003d28:	6aa2                	ld	s5,8(sp)
    80003d2a:	b71d                	j	80003c50 <end_op+0x44>

0000000080003d2c <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    80003d2c:	1101                	addi	sp,sp,-32
    80003d2e:	ec06                	sd	ra,24(sp)
    80003d30:	e822                	sd	s0,16(sp)
    80003d32:	e426                	sd	s1,8(sp)
    80003d34:	e04a                	sd	s2,0(sp)
    80003d36:	1000                	addi	s0,sp,32
    80003d38:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    80003d3a:	0001e917          	auipc	s2,0x1e
    80003d3e:	55e90913          	addi	s2,s2,1374 # 80022298 <log>
    80003d42:	854a                	mv	a0,s2
    80003d44:	e69fc0ef          	jal	80000bac <acquire>
  if (log.lh.n >= LOGBLOCKS)
    80003d48:	02c92603          	lw	a2,44(s2)
    80003d4c:	47f5                	li	a5,29
    80003d4e:	04c7cc63          	blt	a5,a2,80003da6 <log_write+0x7a>
    panic("too big a transaction");
  if (log.outstanding < 1)
    80003d52:	0001e797          	auipc	a5,0x1e
    80003d56:	5627a783          	lw	a5,1378(a5) # 800222b4 <log+0x1c>
    80003d5a:	04f05c63          	blez	a5,80003db2 <log_write+0x86>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    80003d5e:	4781                	li	a5,0
    80003d60:	04c05f63          	blez	a2,80003dbe <log_write+0x92>
    if (log.lh.block[i] == b->blockno) // log absorption
    80003d64:	44cc                	lw	a1,12(s1)
    80003d66:	0001e717          	auipc	a4,0x1e
    80003d6a:	56270713          	addi	a4,a4,1378 # 800222c8 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    80003d6e:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno) // log absorption
    80003d70:	4314                	lw	a3,0(a4)
    80003d72:	04b68663          	beq	a3,a1,80003dbe <log_write+0x92>
  for (i = 0; i < log.lh.n; i++) {
    80003d76:	2785                	addiw	a5,a5,1
    80003d78:	0711                	addi	a4,a4,4
    80003d7a:	fef61be3          	bne	a2,a5,80003d70 <log_write+0x44>
      break;
  }
  log.lh.block[i] = b->blockno;
    80003d7e:	0621                	addi	a2,a2,8
    80003d80:	060a                	slli	a2,a2,0x2
    80003d82:	0001e797          	auipc	a5,0x1e
    80003d86:	51678793          	addi	a5,a5,1302 # 80022298 <log>
    80003d8a:	97b2                	add	a5,a5,a2
    80003d8c:	44d8                	lw	a4,12(s1)
    80003d8e:	cb98                	sw	a4,16(a5)
  if (i == log.lh.n) { // Add new block to log?
    bpin(b);
    80003d90:	8526                	mv	a0,s1
    80003d92:	eebfe0ef          	jal	80002c7c <bpin>
    log.lh.n++;
    80003d96:	0001e717          	auipc	a4,0x1e
    80003d9a:	50270713          	addi	a4,a4,1282 # 80022298 <log>
    80003d9e:	575c                	lw	a5,44(a4)
    80003da0:	2785                	addiw	a5,a5,1
    80003da2:	d75c                	sw	a5,44(a4)
    80003da4:	a80d                	j	80003dd6 <log_write+0xaa>
    panic("too big a transaction");
    80003da6:	00003517          	auipc	a0,0x3
    80003daa:	76a50513          	addi	a0,a0,1898 # 80007510 <etext+0x510>
    80003dae:	a27fc0ef          	jal	800007d4 <panic>
    panic("log_write outside of trans");
    80003db2:	00003517          	auipc	a0,0x3
    80003db6:	77650513          	addi	a0,a0,1910 # 80007528 <etext+0x528>
    80003dba:	a1bfc0ef          	jal	800007d4 <panic>
  log.lh.block[i] = b->blockno;
    80003dbe:	00878693          	addi	a3,a5,8
    80003dc2:	068a                	slli	a3,a3,0x2
    80003dc4:	0001e717          	auipc	a4,0x1e
    80003dc8:	4d470713          	addi	a4,a4,1236 # 80022298 <log>
    80003dcc:	9736                	add	a4,a4,a3
    80003dce:	44d4                	lw	a3,12(s1)
    80003dd0:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) { // Add new block to log?
    80003dd2:	faf60fe3          	beq	a2,a5,80003d90 <log_write+0x64>
  }
  release(&log.lock);
    80003dd6:	0001e517          	auipc	a0,0x1e
    80003dda:	4c250513          	addi	a0,a0,1218 # 80022298 <log>
    80003dde:	e63fc0ef          	jal	80000c40 <release>
}
    80003de2:	60e2                	ld	ra,24(sp)
    80003de4:	6442                	ld	s0,16(sp)
    80003de6:	64a2                	ld	s1,8(sp)
    80003de8:	6902                	ld	s2,0(sp)
    80003dea:	6105                	addi	sp,sp,32
    80003dec:	8082                	ret

0000000080003dee <sys_sync>:

uint64
sys_sync(void)
{
    80003dee:	1101                	addi	sp,sp,-32
    80003df0:	ec06                	sd	ra,24(sp)
    80003df2:	e822                	sd	s0,16(sp)
    80003df4:	e426                	sd	s1,8(sp)
    80003df6:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    80003df8:	0001e497          	auipc	s1,0x1e
    80003dfc:	4a048493          	addi	s1,s1,1184 # 80022298 <log>
    80003e00:	8526                	mv	a0,s1
    80003e02:	dabfc0ef          	jal	80000bac <acquire>
  if (log.committing || log.outstanding > 0) {
    80003e06:	509c                	lw	a5,32(s1)
    80003e08:	e799                	bnez	a5,80003e16 <sys_sync+0x28>
    80003e0a:	0001e797          	auipc	a5,0x1e
    80003e0e:	4aa7a783          	lw	a5,1194(a5) # 800222b4 <log+0x1c>
    80003e12:	02f05363          	blez	a5,80003e38 <sys_sync+0x4a>
    80003e16:	e04a                	sd	s2,0(sp)
    int n = log.ncommit + 1;
    80003e18:	0001e917          	auipc	s2,0x1e
    80003e1c:	4a892903          	lw	s2,1192(s2) # 800222c0 <log+0x28>
    while (log.ncommit < n) {
      sleep(&log, &log.lock);
    80003e20:	0001e497          	auipc	s1,0x1e
    80003e24:	47848493          	addi	s1,s1,1144 # 80022298 <log>
    80003e28:	85a6                	mv	a1,s1
    80003e2a:	8526                	mv	a0,s1
    80003e2c:	882fe0ef          	jal	80001eae <sleep>
    while (log.ncommit < n) {
    80003e30:	549c                	lw	a5,40(s1)
    80003e32:	fef95be3          	bge	s2,a5,80003e28 <sys_sync+0x3a>
    80003e36:	6902                	ld	s2,0(sp)
    }
  }
  release(&log.lock);
    80003e38:	0001e517          	auipc	a0,0x1e
    80003e3c:	46050513          	addi	a0,a0,1120 # 80022298 <log>
    80003e40:	e01fc0ef          	jal	80000c40 <release>
  return 0;
}
    80003e44:	4501                	li	a0,0
    80003e46:	60e2                	ld	ra,24(sp)
    80003e48:	6442                	ld	s0,16(sp)
    80003e4a:	64a2                	ld	s1,8(sp)
    80003e4c:	6105                	addi	sp,sp,32
    80003e4e:	8082                	ret

0000000080003e50 <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    80003e50:	1101                	addi	sp,sp,-32
    80003e52:	ec06                	sd	ra,24(sp)
    80003e54:	e822                	sd	s0,16(sp)
    80003e56:	e426                	sd	s1,8(sp)
    80003e58:	e04a                	sd	s2,0(sp)
    80003e5a:	1000                	addi	s0,sp,32
    80003e5c:	84aa                	mv	s1,a0
    80003e5e:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    80003e60:	00003597          	auipc	a1,0x3
    80003e64:	6e858593          	addi	a1,a1,1768 # 80007548 <etext+0x548>
    80003e68:	0521                	addi	a0,a0,8
    80003e6a:	cc3fc0ef          	jal	80000b2c <initlock>
  lk->name = name;
    80003e6e:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    80003e72:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80003e76:	0204a423          	sw	zero,40(s1)
}
    80003e7a:	60e2                	ld	ra,24(sp)
    80003e7c:	6442                	ld	s0,16(sp)
    80003e7e:	64a2                	ld	s1,8(sp)
    80003e80:	6902                	ld	s2,0(sp)
    80003e82:	6105                	addi	sp,sp,32
    80003e84:	8082                	ret

0000000080003e86 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    80003e86:	1101                	addi	sp,sp,-32
    80003e88:	ec06                	sd	ra,24(sp)
    80003e8a:	e822                	sd	s0,16(sp)
    80003e8c:	e426                	sd	s1,8(sp)
    80003e8e:	e04a                	sd	s2,0(sp)
    80003e90:	1000                	addi	s0,sp,32
    80003e92:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80003e94:	00850913          	addi	s2,a0,8
    80003e98:	854a                	mv	a0,s2
    80003e9a:	d13fc0ef          	jal	80000bac <acquire>
  while (lk->locked) {
    80003e9e:	409c                	lw	a5,0(s1)
    80003ea0:	c799                	beqz	a5,80003eae <acquiresleep+0x28>
    sleep(lk, &lk->lk);
    80003ea2:	85ca                	mv	a1,s2
    80003ea4:	8526                	mv	a0,s1
    80003ea6:	808fe0ef          	jal	80001eae <sleep>
  while (lk->locked) {
    80003eaa:	409c                	lw	a5,0(s1)
    80003eac:	fbfd                	bnez	a5,80003ea2 <acquiresleep+0x1c>
  }
  lk->locked = 1;
    80003eae:	4785                	li	a5,1
    80003eb0:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    80003eb2:	9f3fd0ef          	jal	800018a4 <myproc>
    80003eb6:	591c                	lw	a5,48(a0)
    80003eb8:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    80003eba:	854a                	mv	a0,s2
    80003ebc:	d85fc0ef          	jal	80000c40 <release>
}
    80003ec0:	60e2                	ld	ra,24(sp)
    80003ec2:	6442                	ld	s0,16(sp)
    80003ec4:	64a2                	ld	s1,8(sp)
    80003ec6:	6902                	ld	s2,0(sp)
    80003ec8:	6105                	addi	sp,sp,32
    80003eca:	8082                	ret

0000000080003ecc <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    80003ecc:	1101                	addi	sp,sp,-32
    80003ece:	ec06                	sd	ra,24(sp)
    80003ed0:	e822                	sd	s0,16(sp)
    80003ed2:	e426                	sd	s1,8(sp)
    80003ed4:	e04a                	sd	s2,0(sp)
    80003ed6:	1000                	addi	s0,sp,32
    80003ed8:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80003eda:	00850913          	addi	s2,a0,8
    80003ede:	854a                	mv	a0,s2
    80003ee0:	ccdfc0ef          	jal	80000bac <acquire>
  lk->locked = 0;
    80003ee4:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80003ee8:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    80003eec:	8526                	mv	a0,s1
    80003eee:	80cfe0ef          	jal	80001efa <wakeup>
  release(&lk->lk);
    80003ef2:	854a                	mv	a0,s2
    80003ef4:	d4dfc0ef          	jal	80000c40 <release>
}
    80003ef8:	60e2                	ld	ra,24(sp)
    80003efa:	6442                	ld	s0,16(sp)
    80003efc:	64a2                	ld	s1,8(sp)
    80003efe:	6902                	ld	s2,0(sp)
    80003f00:	6105                	addi	sp,sp,32
    80003f02:	8082                	ret

0000000080003f04 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    80003f04:	7179                	addi	sp,sp,-48
    80003f06:	f406                	sd	ra,40(sp)
    80003f08:	f022                	sd	s0,32(sp)
    80003f0a:	ec26                	sd	s1,24(sp)
    80003f0c:	e84a                	sd	s2,16(sp)
    80003f0e:	1800                	addi	s0,sp,48
    80003f10:	84aa                	mv	s1,a0
  int r;

  acquire(&lk->lk);
    80003f12:	00850913          	addi	s2,a0,8
    80003f16:	854a                	mv	a0,s2
    80003f18:	c95fc0ef          	jal	80000bac <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    80003f1c:	409c                	lw	a5,0(s1)
    80003f1e:	ef81                	bnez	a5,80003f36 <holdingsleep+0x32>
    80003f20:	4481                	li	s1,0
  release(&lk->lk);
    80003f22:	854a                	mv	a0,s2
    80003f24:	d1dfc0ef          	jal	80000c40 <release>
  return r;
}
    80003f28:	8526                	mv	a0,s1
    80003f2a:	70a2                	ld	ra,40(sp)
    80003f2c:	7402                	ld	s0,32(sp)
    80003f2e:	64e2                	ld	s1,24(sp)
    80003f30:	6942                	ld	s2,16(sp)
    80003f32:	6145                	addi	sp,sp,48
    80003f34:	8082                	ret
    80003f36:	e44e                	sd	s3,8(sp)
  r = lk->locked && (lk->pid == myproc()->pid);
    80003f38:	0284a983          	lw	s3,40(s1)
    80003f3c:	969fd0ef          	jal	800018a4 <myproc>
    80003f40:	5904                	lw	s1,48(a0)
    80003f42:	413484b3          	sub	s1,s1,s3
    80003f46:	0014b493          	seqz	s1,s1
    80003f4a:	69a2                	ld	s3,8(sp)
    80003f4c:	bfd9                	j	80003f22 <holdingsleep+0x1e>

0000000080003f4e <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    80003f4e:	1141                	addi	sp,sp,-16
    80003f50:	e406                	sd	ra,8(sp)
    80003f52:	e022                	sd	s0,0(sp)
    80003f54:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    80003f56:	00003597          	auipc	a1,0x3
    80003f5a:	60258593          	addi	a1,a1,1538 # 80007558 <etext+0x558>
    80003f5e:	0001e517          	auipc	a0,0x1e
    80003f62:	48250513          	addi	a0,a0,1154 # 800223e0 <ftable>
    80003f66:	bc7fc0ef          	jal	80000b2c <initlock>
}
    80003f6a:	60a2                	ld	ra,8(sp)
    80003f6c:	6402                	ld	s0,0(sp)
    80003f6e:	0141                	addi	sp,sp,16
    80003f70:	8082                	ret

0000000080003f72 <filealloc>:

// Allocate a file structure.
struct file *
filealloc(void)
{
    80003f72:	1101                	addi	sp,sp,-32
    80003f74:	ec06                	sd	ra,24(sp)
    80003f76:	e822                	sd	s0,16(sp)
    80003f78:	e426                	sd	s1,8(sp)
    80003f7a:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    80003f7c:	0001e517          	auipc	a0,0x1e
    80003f80:	46450513          	addi	a0,a0,1124 # 800223e0 <ftable>
    80003f84:	c29fc0ef          	jal	80000bac <acquire>
  for (f = ftable.file; f < ftable.file + NFILE; f++) {
    80003f88:	0001e497          	auipc	s1,0x1e
    80003f8c:	47048493          	addi	s1,s1,1136 # 800223f8 <ftable+0x18>
    80003f90:	0001f717          	auipc	a4,0x1f
    80003f94:	40870713          	addi	a4,a4,1032 # 80023398 <disk>
    if (f->ref == 0) {
    80003f98:	40dc                	lw	a5,4(s1)
    80003f9a:	cf89                	beqz	a5,80003fb4 <filealloc+0x42>
  for (f = ftable.file; f < ftable.file + NFILE; f++) {
    80003f9c:	02848493          	addi	s1,s1,40
    80003fa0:	fee49ce3          	bne	s1,a4,80003f98 <filealloc+0x26>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    80003fa4:	0001e517          	auipc	a0,0x1e
    80003fa8:	43c50513          	addi	a0,a0,1084 # 800223e0 <ftable>
    80003fac:	c95fc0ef          	jal	80000c40 <release>
  return 0;
    80003fb0:	4481                	li	s1,0
    80003fb2:	a809                	j	80003fc4 <filealloc+0x52>
      f->ref = 1;
    80003fb4:	4785                	li	a5,1
    80003fb6:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    80003fb8:	0001e517          	auipc	a0,0x1e
    80003fbc:	42850513          	addi	a0,a0,1064 # 800223e0 <ftable>
    80003fc0:	c81fc0ef          	jal	80000c40 <release>
}
    80003fc4:	8526                	mv	a0,s1
    80003fc6:	60e2                	ld	ra,24(sp)
    80003fc8:	6442                	ld	s0,16(sp)
    80003fca:	64a2                	ld	s1,8(sp)
    80003fcc:	6105                	addi	sp,sp,32
    80003fce:	8082                	ret

0000000080003fd0 <filedup>:

// Increment ref count for file f.
struct file *
filedup(struct file *f)
{
    80003fd0:	1101                	addi	sp,sp,-32
    80003fd2:	ec06                	sd	ra,24(sp)
    80003fd4:	e822                	sd	s0,16(sp)
    80003fd6:	e426                	sd	s1,8(sp)
    80003fd8:	1000                	addi	s0,sp,32
    80003fda:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    80003fdc:	0001e517          	auipc	a0,0x1e
    80003fe0:	40450513          	addi	a0,a0,1028 # 800223e0 <ftable>
    80003fe4:	bc9fc0ef          	jal	80000bac <acquire>
  if (f->ref < 1)
    80003fe8:	40dc                	lw	a5,4(s1)
    80003fea:	02f05063          	blez	a5,8000400a <filedup+0x3a>
    panic("filedup");
  f->ref++;
    80003fee:	2785                	addiw	a5,a5,1
    80003ff0:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    80003ff2:	0001e517          	auipc	a0,0x1e
    80003ff6:	3ee50513          	addi	a0,a0,1006 # 800223e0 <ftable>
    80003ffa:	c47fc0ef          	jal	80000c40 <release>
  return f;
}
    80003ffe:	8526                	mv	a0,s1
    80004000:	60e2                	ld	ra,24(sp)
    80004002:	6442                	ld	s0,16(sp)
    80004004:	64a2                	ld	s1,8(sp)
    80004006:	6105                	addi	sp,sp,32
    80004008:	8082                	ret
    panic("filedup");
    8000400a:	00003517          	auipc	a0,0x3
    8000400e:	55650513          	addi	a0,a0,1366 # 80007560 <etext+0x560>
    80004012:	fc2fc0ef          	jal	800007d4 <panic>

0000000080004016 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    80004016:	7139                	addi	sp,sp,-64
    80004018:	fc06                	sd	ra,56(sp)
    8000401a:	f822                	sd	s0,48(sp)
    8000401c:	f426                	sd	s1,40(sp)
    8000401e:	0080                	addi	s0,sp,64
    80004020:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    80004022:	0001e517          	auipc	a0,0x1e
    80004026:	3be50513          	addi	a0,a0,958 # 800223e0 <ftable>
    8000402a:	b83fc0ef          	jal	80000bac <acquire>
  if (f->ref < 1)
    8000402e:	40dc                	lw	a5,4(s1)
    80004030:	04f05a63          	blez	a5,80004084 <fileclose+0x6e>
    panic("fileclose");
  if (--f->ref > 0) {
    80004034:	37fd                	addiw	a5,a5,-1
    80004036:	0007871b          	sext.w	a4,a5
    8000403a:	c0dc                	sw	a5,4(s1)
    8000403c:	04e04e63          	bgtz	a4,80004098 <fileclose+0x82>
    80004040:	f04a                	sd	s2,32(sp)
    80004042:	ec4e                	sd	s3,24(sp)
    80004044:	e852                	sd	s4,16(sp)
    80004046:	e456                	sd	s5,8(sp)
    release(&ftable.lock);
    return;
  }
  ff = *f;
    80004048:	0004a903          	lw	s2,0(s1)
    8000404c:	0094ca83          	lbu	s5,9(s1)
    80004050:	0104ba03          	ld	s4,16(s1)
    80004054:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    80004058:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    8000405c:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    80004060:	0001e517          	auipc	a0,0x1e
    80004064:	38050513          	addi	a0,a0,896 # 800223e0 <ftable>
    80004068:	bd9fc0ef          	jal	80000c40 <release>

  if (ff.type == FD_PIPE) {
    8000406c:	4785                	li	a5,1
    8000406e:	04f90063          	beq	s2,a5,800040ae <fileclose+0x98>
    pipeclose(ff.pipe, ff.writable);
  } else if (ff.type == FD_INODE || ff.type == FD_DEVICE) {
    80004072:	3979                	addiw	s2,s2,-2
    80004074:	4785                	li	a5,1
    80004076:	0527f563          	bgeu	a5,s2,800040c0 <fileclose+0xaa>
    8000407a:	7902                	ld	s2,32(sp)
    8000407c:	69e2                	ld	s3,24(sp)
    8000407e:	6a42                	ld	s4,16(sp)
    80004080:	6aa2                	ld	s5,8(sp)
    80004082:	a00d                	j	800040a4 <fileclose+0x8e>
    80004084:	f04a                	sd	s2,32(sp)
    80004086:	ec4e                	sd	s3,24(sp)
    80004088:	e852                	sd	s4,16(sp)
    8000408a:	e456                	sd	s5,8(sp)
    panic("fileclose");
    8000408c:	00003517          	auipc	a0,0x3
    80004090:	4dc50513          	addi	a0,a0,1244 # 80007568 <etext+0x568>
    80004094:	f40fc0ef          	jal	800007d4 <panic>
    release(&ftable.lock);
    80004098:	0001e517          	auipc	a0,0x1e
    8000409c:	34850513          	addi	a0,a0,840 # 800223e0 <ftable>
    800040a0:	ba1fc0ef          	jal	80000c40 <release>
    begin_op();
    iput(ff.ip);
    end_op();
  }
}
    800040a4:	70e2                	ld	ra,56(sp)
    800040a6:	7442                	ld	s0,48(sp)
    800040a8:	74a2                	ld	s1,40(sp)
    800040aa:	6121                	addi	sp,sp,64
    800040ac:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    800040ae:	85d6                	mv	a1,s5
    800040b0:	8552                	mv	a0,s4
    800040b2:	336000ef          	jal	800043e8 <pipeclose>
    800040b6:	7902                	ld	s2,32(sp)
    800040b8:	69e2                	ld	s3,24(sp)
    800040ba:	6a42                	ld	s4,16(sp)
    800040bc:	6aa2                	ld	s5,8(sp)
    800040be:	b7dd                	j	800040a4 <fileclose+0x8e>
    begin_op();
    800040c0:	ae3ff0ef          	jal	80003ba2 <begin_op>
    iput(ff.ip);
    800040c4:	854e                	mv	a0,s3
    800040c6:	a74ff0ef          	jal	8000333a <iput>
    end_op();
    800040ca:	b43ff0ef          	jal	80003c0c <end_op>
    800040ce:	7902                	ld	s2,32(sp)
    800040d0:	69e2                	ld	s3,24(sp)
    800040d2:	6a42                	ld	s4,16(sp)
    800040d4:	6aa2                	ld	s5,8(sp)
    800040d6:	b7f9                	j	800040a4 <fileclose+0x8e>

00000000800040d8 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    800040d8:	715d                	addi	sp,sp,-80
    800040da:	e486                	sd	ra,72(sp)
    800040dc:	e0a2                	sd	s0,64(sp)
    800040de:	fc26                	sd	s1,56(sp)
    800040e0:	f44e                	sd	s3,40(sp)
    800040e2:	0880                	addi	s0,sp,80
    800040e4:	84aa                	mv	s1,a0
    800040e6:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    800040e8:	fbcfd0ef          	jal	800018a4 <myproc>
  struct stat st;

  if (f->type == FD_INODE || f->type == FD_DEVICE) {
    800040ec:	409c                	lw	a5,0(s1)
    800040ee:	37f9                	addiw	a5,a5,-2
    800040f0:	4705                	li	a4,1
    800040f2:	04f76063          	bltu	a4,a5,80004132 <filestat+0x5a>
    800040f6:	f84a                	sd	s2,48(sp)
    800040f8:	892a                	mv	s2,a0
    ilock(f->ip);
    800040fa:	6c88                	ld	a0,24(s1)
    800040fc:	8bcff0ef          	jal	800031b8 <ilock>
    stati(f->ip, &st);
    80004100:	fb840593          	addi	a1,s0,-72
    80004104:	6c88                	ld	a0,24(s1)
    80004106:	c18ff0ef          	jal	8000351e <stati>
    iunlock(f->ip);
    8000410a:	6c88                	ld	a0,24(s1)
    8000410c:	95aff0ef          	jal	80003266 <iunlock>
    if (copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    80004110:	46e1                	li	a3,24
    80004112:	fb840613          	addi	a2,s0,-72
    80004116:	85ce                	mv	a1,s3
    80004118:	05093503          	ld	a0,80(s2)
    8000411c:	c9cfd0ef          	jal	800015b8 <copyout>
    80004120:	41f5551b          	sraiw	a0,a0,0x1f
    80004124:	7942                	ld	s2,48(sp)
      return -1;
    return 0;
  }
  return -1;
}
    80004126:	60a6                	ld	ra,72(sp)
    80004128:	6406                	ld	s0,64(sp)
    8000412a:	74e2                	ld	s1,56(sp)
    8000412c:	79a2                	ld	s3,40(sp)
    8000412e:	6161                	addi	sp,sp,80
    80004130:	8082                	ret
  return -1;
    80004132:	557d                	li	a0,-1
    80004134:	bfcd                	j	80004126 <filestat+0x4e>

0000000080004136 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    80004136:	7179                	addi	sp,sp,-48
    80004138:	f406                	sd	ra,40(sp)
    8000413a:	f022                	sd	s0,32(sp)
    8000413c:	e84a                	sd	s2,16(sp)
    8000413e:	1800                	addi	s0,sp,48
  int r = 0;

  if (f->readable == 0)
    80004140:	00854783          	lbu	a5,8(a0)
    80004144:	cfd1                	beqz	a5,800041e0 <fileread+0xaa>
    80004146:	ec26                	sd	s1,24(sp)
    80004148:	e44e                	sd	s3,8(sp)
    8000414a:	84aa                	mv	s1,a0
    8000414c:	89ae                	mv	s3,a1
    8000414e:	8932                	mv	s2,a2
    return -1;

  if (f->type == FD_PIPE) {
    80004150:	411c                	lw	a5,0(a0)
    80004152:	4705                	li	a4,1
    80004154:	04e78363          	beq	a5,a4,8000419a <fileread+0x64>
    r = piperead(f->pipe, addr, n);
  } else if (f->type == FD_DEVICE) {
    80004158:	470d                	li	a4,3
    8000415a:	04e78763          	beq	a5,a4,800041a8 <fileread+0x72>
    if (f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if (f->type == FD_INODE) {
    8000415e:	4709                	li	a4,2
    80004160:	06e79a63          	bne	a5,a4,800041d4 <fileread+0x9e>
    ilock(f->ip);
    80004164:	6d08                	ld	a0,24(a0)
    80004166:	852ff0ef          	jal	800031b8 <ilock>
    if ((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    8000416a:	874a                	mv	a4,s2
    8000416c:	5094                	lw	a3,32(s1)
    8000416e:	864e                	mv	a2,s3
    80004170:	4585                	li	a1,1
    80004172:	6c88                	ld	a0,24(s1)
    80004174:	bd4ff0ef          	jal	80003548 <readi>
    80004178:	892a                	mv	s2,a0
    8000417a:	00a05563          	blez	a0,80004184 <fileread+0x4e>
      f->off += r;
    8000417e:	509c                	lw	a5,32(s1)
    80004180:	9fa9                	addw	a5,a5,a0
    80004182:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    80004184:	6c88                	ld	a0,24(s1)
    80004186:	8e0ff0ef          	jal	80003266 <iunlock>
    8000418a:	64e2                	ld	s1,24(sp)
    8000418c:	69a2                	ld	s3,8(sp)
  } else {
    panic("fileread");
  }

  return r;
}
    8000418e:	854a                	mv	a0,s2
    80004190:	70a2                	ld	ra,40(sp)
    80004192:	7402                	ld	s0,32(sp)
    80004194:	6942                	ld	s2,16(sp)
    80004196:	6145                	addi	sp,sp,48
    80004198:	8082                	ret
    r = piperead(f->pipe, addr, n);
    8000419a:	6908                	ld	a0,16(a0)
    8000419c:	388000ef          	jal	80004524 <piperead>
    800041a0:	892a                	mv	s2,a0
    800041a2:	64e2                	ld	s1,24(sp)
    800041a4:	69a2                	ld	s3,8(sp)
    800041a6:	b7e5                	j	8000418e <fileread+0x58>
    if (f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    800041a8:	02451783          	lh	a5,36(a0)
    800041ac:	03079693          	slli	a3,a5,0x30
    800041b0:	92c1                	srli	a3,a3,0x30
    800041b2:	4725                	li	a4,9
    800041b4:	02d76863          	bltu	a4,a3,800041e4 <fileread+0xae>
    800041b8:	0792                	slli	a5,a5,0x4
    800041ba:	0001e717          	auipc	a4,0x1e
    800041be:	18670713          	addi	a4,a4,390 # 80022340 <devsw>
    800041c2:	97ba                	add	a5,a5,a4
    800041c4:	639c                	ld	a5,0(a5)
    800041c6:	c39d                	beqz	a5,800041ec <fileread+0xb6>
    r = devsw[f->major].read(1, addr, n);
    800041c8:	4505                	li	a0,1
    800041ca:	9782                	jalr	a5
    800041cc:	892a                	mv	s2,a0
    800041ce:	64e2                	ld	s1,24(sp)
    800041d0:	69a2                	ld	s3,8(sp)
    800041d2:	bf75                	j	8000418e <fileread+0x58>
    panic("fileread");
    800041d4:	00003517          	auipc	a0,0x3
    800041d8:	3a450513          	addi	a0,a0,932 # 80007578 <etext+0x578>
    800041dc:	df8fc0ef          	jal	800007d4 <panic>
    return -1;
    800041e0:	597d                	li	s2,-1
    800041e2:	b775                	j	8000418e <fileread+0x58>
      return -1;
    800041e4:	597d                	li	s2,-1
    800041e6:	64e2                	ld	s1,24(sp)
    800041e8:	69a2                	ld	s3,8(sp)
    800041ea:	b755                	j	8000418e <fileread+0x58>
    800041ec:	597d                	li	s2,-1
    800041ee:	64e2                	ld	s1,24(sp)
    800041f0:	69a2                	ld	s3,8(sp)
    800041f2:	bf71                	j	8000418e <fileread+0x58>

00000000800041f4 <filewrite>:
int
filewrite(struct file *f, uint64 addr, int n)
{
  int r, ret = 0;

  if (f->writable == 0)
    800041f4:	00954783          	lbu	a5,9(a0)
    800041f8:	10078b63          	beqz	a5,8000430e <filewrite+0x11a>
{
    800041fc:	715d                	addi	sp,sp,-80
    800041fe:	e486                	sd	ra,72(sp)
    80004200:	e0a2                	sd	s0,64(sp)
    80004202:	f84a                	sd	s2,48(sp)
    80004204:	f052                	sd	s4,32(sp)
    80004206:	e85a                	sd	s6,16(sp)
    80004208:	0880                	addi	s0,sp,80
    8000420a:	892a                	mv	s2,a0
    8000420c:	8b2e                	mv	s6,a1
    8000420e:	8a32                	mv	s4,a2
    return -1;

  if (f->type == FD_PIPE) {
    80004210:	411c                	lw	a5,0(a0)
    80004212:	4705                	li	a4,1
    80004214:	02e78763          	beq	a5,a4,80004242 <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if (f->type == FD_DEVICE) {
    80004218:	470d                	li	a4,3
    8000421a:	02e78863          	beq	a5,a4,8000424a <filewrite+0x56>
    if (f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if (f->type == FD_INODE) {
    8000421e:	4709                	li	a4,2
    80004220:	0ce79c63          	bne	a5,a4,800042f8 <filewrite+0x104>
    80004224:	f44e                	sd	s3,40(sp)
    // the maximum log transaction size, including
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    int max = ((MAXOPBLOCKS - 1 - 1 - 2) / 2) * BSIZE;
    int i = 0;
    while (i < n) {
    80004226:	0ac05863          	blez	a2,800042d6 <filewrite+0xe2>
    8000422a:	fc26                	sd	s1,56(sp)
    8000422c:	ec56                	sd	s5,24(sp)
    8000422e:	e45e                	sd	s7,8(sp)
    80004230:	e062                	sd	s8,0(sp)
    int i = 0;
    80004232:	4981                	li	s3,0
      int n1 = n - i;
      if (n1 > max)
    80004234:	6b85                	lui	s7,0x1
    80004236:	c00b8b93          	addi	s7,s7,-1024 # c00 <_entry-0x7ffff400>
    8000423a:	6c05                	lui	s8,0x1
    8000423c:	c00c0c1b          	addiw	s8,s8,-1024 # c00 <_entry-0x7ffff400>
    80004240:	a8b5                	j	800042bc <filewrite+0xc8>
    ret = pipewrite(f->pipe, addr, n);
    80004242:	6908                	ld	a0,16(a0)
    80004244:	1fc000ef          	jal	80004440 <pipewrite>
    80004248:	a04d                	j	800042ea <filewrite+0xf6>
    if (f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    8000424a:	02451783          	lh	a5,36(a0)
    8000424e:	03079693          	slli	a3,a5,0x30
    80004252:	92c1                	srli	a3,a3,0x30
    80004254:	4725                	li	a4,9
    80004256:	0ad76e63          	bltu	a4,a3,80004312 <filewrite+0x11e>
    8000425a:	0792                	slli	a5,a5,0x4
    8000425c:	0001e717          	auipc	a4,0x1e
    80004260:	0e470713          	addi	a4,a4,228 # 80022340 <devsw>
    80004264:	97ba                	add	a5,a5,a4
    80004266:	679c                	ld	a5,8(a5)
    80004268:	c7dd                	beqz	a5,80004316 <filewrite+0x122>
    ret = devsw[f->major].write(1, addr, n);
    8000426a:	4505                	li	a0,1
    8000426c:	9782                	jalr	a5
    8000426e:	a8b5                	j	800042ea <filewrite+0xf6>
      if (n1 > max)
    80004270:	00048a9b          	sext.w	s5,s1
        n1 = max;

      begin_op();
    80004274:	92fff0ef          	jal	80003ba2 <begin_op>
      ilock(f->ip);
    80004278:	01893503          	ld	a0,24(s2)
    8000427c:	f3dfe0ef          	jal	800031b8 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80004280:	8756                	mv	a4,s5
    80004282:	02092683          	lw	a3,32(s2)
    80004286:	01698633          	add	a2,s3,s6
    8000428a:	4585                	li	a1,1
    8000428c:	01893503          	ld	a0,24(s2)
    80004290:	bb4ff0ef          	jal	80003644 <writei>
    80004294:	84aa                	mv	s1,a0
    80004296:	00a05763          	blez	a0,800042a4 <filewrite+0xb0>
        f->off += r;
    8000429a:	02092783          	lw	a5,32(s2)
    8000429e:	9fa9                	addw	a5,a5,a0
    800042a0:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    800042a4:	01893503          	ld	a0,24(s2)
    800042a8:	fbffe0ef          	jal	80003266 <iunlock>
      end_op();
    800042ac:	961ff0ef          	jal	80003c0c <end_op>

      if (r != n1) {
    800042b0:	029a9563          	bne	s5,s1,800042da <filewrite+0xe6>
        // error from writei
        break;
      }
      i += r;
    800042b4:	013489bb          	addw	s3,s1,s3
    while (i < n) {
    800042b8:	0149da63          	bge	s3,s4,800042cc <filewrite+0xd8>
      int n1 = n - i;
    800042bc:	413a04bb          	subw	s1,s4,s3
      if (n1 > max)
    800042c0:	0004879b          	sext.w	a5,s1
    800042c4:	fafbd6e3          	bge	s7,a5,80004270 <filewrite+0x7c>
    800042c8:	84e2                	mv	s1,s8
    800042ca:	b75d                	j	80004270 <filewrite+0x7c>
    800042cc:	74e2                	ld	s1,56(sp)
    800042ce:	6ae2                	ld	s5,24(sp)
    800042d0:	6ba2                	ld	s7,8(sp)
    800042d2:	6c02                	ld	s8,0(sp)
    800042d4:	a039                	j	800042e2 <filewrite+0xee>
    int i = 0;
    800042d6:	4981                	li	s3,0
    800042d8:	a029                	j	800042e2 <filewrite+0xee>
    800042da:	74e2                	ld	s1,56(sp)
    800042dc:	6ae2                	ld	s5,24(sp)
    800042de:	6ba2                	ld	s7,8(sp)
    800042e0:	6c02                	ld	s8,0(sp)
    }
    ret = (i == n ? n : -1);
    800042e2:	033a1c63          	bne	s4,s3,8000431a <filewrite+0x126>
    800042e6:	8552                	mv	a0,s4
    800042e8:	79a2                	ld	s3,40(sp)
  } else {
    panic("filewrite");
  }

  return ret;
}
    800042ea:	60a6                	ld	ra,72(sp)
    800042ec:	6406                	ld	s0,64(sp)
    800042ee:	7942                	ld	s2,48(sp)
    800042f0:	7a02                	ld	s4,32(sp)
    800042f2:	6b42                	ld	s6,16(sp)
    800042f4:	6161                	addi	sp,sp,80
    800042f6:	8082                	ret
    800042f8:	fc26                	sd	s1,56(sp)
    800042fa:	f44e                	sd	s3,40(sp)
    800042fc:	ec56                	sd	s5,24(sp)
    800042fe:	e45e                	sd	s7,8(sp)
    80004300:	e062                	sd	s8,0(sp)
    panic("filewrite");
    80004302:	00003517          	auipc	a0,0x3
    80004306:	28650513          	addi	a0,a0,646 # 80007588 <etext+0x588>
    8000430a:	ccafc0ef          	jal	800007d4 <panic>
    return -1;
    8000430e:	557d                	li	a0,-1
}
    80004310:	8082                	ret
      return -1;
    80004312:	557d                	li	a0,-1
    80004314:	bfd9                	j	800042ea <filewrite+0xf6>
    80004316:	557d                	li	a0,-1
    80004318:	bfc9                	j	800042ea <filewrite+0xf6>
    ret = (i == n ? n : -1);
    8000431a:	557d                	li	a0,-1
    8000431c:	79a2                	ld	s3,40(sp)
    8000431e:	b7f1                	j	800042ea <filewrite+0xf6>

0000000080004320 <pipealloc>:
  int writeopen; // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80004320:	7179                	addi	sp,sp,-48
    80004322:	f406                	sd	ra,40(sp)
    80004324:	f022                	sd	s0,32(sp)
    80004326:	ec26                	sd	s1,24(sp)
    80004328:	e052                	sd	s4,0(sp)
    8000432a:	1800                	addi	s0,sp,48
    8000432c:	84aa                	mv	s1,a0
    8000432e:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80004330:	0005b023          	sd	zero,0(a1)
    80004334:	00053023          	sd	zero,0(a0)
  if ((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80004338:	c3bff0ef          	jal	80003f72 <filealloc>
    8000433c:	e088                	sd	a0,0(s1)
    8000433e:	c549                	beqz	a0,800043c8 <pipealloc+0xa8>
    80004340:	c33ff0ef          	jal	80003f72 <filealloc>
    80004344:	00aa3023          	sd	a0,0(s4)
    80004348:	cd25                	beqz	a0,800043c0 <pipealloc+0xa0>
    8000434a:	e84a                	sd	s2,16(sp)
    goto bad;
  if ((pi = (struct pipe *)kalloc()) == 0)
    8000434c:	f90fc0ef          	jal	80000adc <kalloc>
    80004350:	892a                	mv	s2,a0
    80004352:	c12d                	beqz	a0,800043b4 <pipealloc+0x94>
    80004354:	e44e                	sd	s3,8(sp)
    goto bad;
  pi->readopen = 1;
    80004356:	4985                	li	s3,1
    80004358:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    8000435c:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    80004360:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80004364:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    80004368:	00003597          	auipc	a1,0x3
    8000436c:	23058593          	addi	a1,a1,560 # 80007598 <etext+0x598>
    80004370:	fbcfc0ef          	jal	80000b2c <initlock>
  (*f0)->type = FD_PIPE;
    80004374:	609c                	ld	a5,0(s1)
    80004376:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    8000437a:	609c                	ld	a5,0(s1)
    8000437c:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80004380:	609c                	ld	a5,0(s1)
    80004382:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80004386:	609c                	ld	a5,0(s1)
    80004388:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    8000438c:	000a3783          	ld	a5,0(s4)
    80004390:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80004394:	000a3783          	ld	a5,0(s4)
    80004398:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    8000439c:	000a3783          	ld	a5,0(s4)
    800043a0:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    800043a4:	000a3783          	ld	a5,0(s4)
    800043a8:	0127b823          	sd	s2,16(a5)
  return 0;
    800043ac:	4501                	li	a0,0
    800043ae:	6942                	ld	s2,16(sp)
    800043b0:	69a2                	ld	s3,8(sp)
    800043b2:	a01d                	j	800043d8 <pipealloc+0xb8>

bad:
  if (pi)
    kfree((char *)pi);
  if (*f0)
    800043b4:	6088                	ld	a0,0(s1)
    800043b6:	c119                	beqz	a0,800043bc <pipealloc+0x9c>
    800043b8:	6942                	ld	s2,16(sp)
    800043ba:	a029                	j	800043c4 <pipealloc+0xa4>
    800043bc:	6942                	ld	s2,16(sp)
    800043be:	a029                	j	800043c8 <pipealloc+0xa8>
    800043c0:	6088                	ld	a0,0(s1)
    800043c2:	c10d                	beqz	a0,800043e4 <pipealloc+0xc4>
    fileclose(*f0);
    800043c4:	c53ff0ef          	jal	80004016 <fileclose>
  if (*f1)
    800043c8:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    800043cc:	557d                	li	a0,-1
  if (*f1)
    800043ce:	c789                	beqz	a5,800043d8 <pipealloc+0xb8>
    fileclose(*f1);
    800043d0:	853e                	mv	a0,a5
    800043d2:	c45ff0ef          	jal	80004016 <fileclose>
  return -1;
    800043d6:	557d                	li	a0,-1
}
    800043d8:	70a2                	ld	ra,40(sp)
    800043da:	7402                	ld	s0,32(sp)
    800043dc:	64e2                	ld	s1,24(sp)
    800043de:	6a02                	ld	s4,0(sp)
    800043e0:	6145                	addi	sp,sp,48
    800043e2:	8082                	ret
  return -1;
    800043e4:	557d                	li	a0,-1
    800043e6:	bfcd                	j	800043d8 <pipealloc+0xb8>

00000000800043e8 <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    800043e8:	1101                	addi	sp,sp,-32
    800043ea:	ec06                	sd	ra,24(sp)
    800043ec:	e822                	sd	s0,16(sp)
    800043ee:	e426                	sd	s1,8(sp)
    800043f0:	e04a                	sd	s2,0(sp)
    800043f2:	1000                	addi	s0,sp,32
    800043f4:	84aa                	mv	s1,a0
    800043f6:	892e                	mv	s2,a1
  acquire(&pi->lock);
    800043f8:	fb4fc0ef          	jal	80000bac <acquire>
  if (writable) {
    800043fc:	02090763          	beqz	s2,8000442a <pipeclose+0x42>
    pi->writeopen = 0;
    80004400:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    80004404:	21848513          	addi	a0,s1,536
    80004408:	af3fd0ef          	jal	80001efa <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if (pi->readopen == 0 && pi->writeopen == 0) {
    8000440c:	2204b783          	ld	a5,544(s1)
    80004410:	e785                	bnez	a5,80004438 <pipeclose+0x50>
    release(&pi->lock);
    80004412:	8526                	mv	a0,s1
    80004414:	82dfc0ef          	jal	80000c40 <release>
    kfree((char *)pi);
    80004418:	8526                	mv	a0,s1
    8000441a:	de0fc0ef          	jal	800009fa <kfree>
  } else
    release(&pi->lock);
}
    8000441e:	60e2                	ld	ra,24(sp)
    80004420:	6442                	ld	s0,16(sp)
    80004422:	64a2                	ld	s1,8(sp)
    80004424:	6902                	ld	s2,0(sp)
    80004426:	6105                	addi	sp,sp,32
    80004428:	8082                	ret
    pi->readopen = 0;
    8000442a:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    8000442e:	21c48513          	addi	a0,s1,540
    80004432:	ac9fd0ef          	jal	80001efa <wakeup>
    80004436:	bfd9                	j	8000440c <pipeclose+0x24>
    release(&pi->lock);
    80004438:	8526                	mv	a0,s1
    8000443a:	807fc0ef          	jal	80000c40 <release>
}
    8000443e:	b7c5                	j	8000441e <pipeclose+0x36>

0000000080004440 <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80004440:	711d                	addi	sp,sp,-96
    80004442:	ec86                	sd	ra,88(sp)
    80004444:	e8a2                	sd	s0,80(sp)
    80004446:	e4a6                	sd	s1,72(sp)
    80004448:	e0ca                	sd	s2,64(sp)
    8000444a:	fc4e                	sd	s3,56(sp)
    8000444c:	f852                	sd	s4,48(sp)
    8000444e:	f456                	sd	s5,40(sp)
    80004450:	1080                	addi	s0,sp,96
    80004452:	84aa                	mv	s1,a0
    80004454:	8aae                	mv	s5,a1
    80004456:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    80004458:	c4cfd0ef          	jal	800018a4 <myproc>
    8000445c:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    8000445e:	8526                	mv	a0,s1
    80004460:	f4cfc0ef          	jal	80000bac <acquire>
  while (i < n) {
    80004464:	0b405a63          	blez	s4,80004518 <pipewrite+0xd8>
    80004468:	f05a                	sd	s6,32(sp)
    8000446a:	ec5e                	sd	s7,24(sp)
    8000446c:	e862                	sd	s8,16(sp)
  int i = 0;
    8000446e:	4901                	li	s2,0
    if (pi->nwrite == pi->nread + PIPESIZE) { //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if (copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004470:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    80004472:	21848c13          	addi	s8,s1,536
      sleep(&pi->nwrite, &pi->lock);
    80004476:	21c48b93          	addi	s7,s1,540
    8000447a:	a81d                	j	800044b0 <pipewrite+0x70>
      release(&pi->lock);
    8000447c:	8526                	mv	a0,s1
    8000447e:	fc2fc0ef          	jal	80000c40 <release>
      return -1;
    80004482:	597d                	li	s2,-1
    80004484:	7b02                	ld	s6,32(sp)
    80004486:	6be2                	ld	s7,24(sp)
    80004488:	6c42                	ld	s8,16(sp)
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    8000448a:	854a                	mv	a0,s2
    8000448c:	60e6                	ld	ra,88(sp)
    8000448e:	6446                	ld	s0,80(sp)
    80004490:	64a6                	ld	s1,72(sp)
    80004492:	6906                	ld	s2,64(sp)
    80004494:	79e2                	ld	s3,56(sp)
    80004496:	7a42                	ld	s4,48(sp)
    80004498:	7aa2                	ld	s5,40(sp)
    8000449a:	6125                	addi	sp,sp,96
    8000449c:	8082                	ret
      wakeup(&pi->nread);
    8000449e:	8562                	mv	a0,s8
    800044a0:	a5bfd0ef          	jal	80001efa <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    800044a4:	85a6                	mv	a1,s1
    800044a6:	855e                	mv	a0,s7
    800044a8:	a07fd0ef          	jal	80001eae <sleep>
  while (i < n) {
    800044ac:	05495b63          	bge	s2,s4,80004502 <pipewrite+0xc2>
    if (pi->readopen == 0 || killed(pr)) {
    800044b0:	2204a783          	lw	a5,544(s1)
    800044b4:	d7e1                	beqz	a5,8000447c <pipewrite+0x3c>
    800044b6:	854e                	mv	a0,s3
    800044b8:	c2ffd0ef          	jal	800020e6 <killed>
    800044bc:	f161                	bnez	a0,8000447c <pipewrite+0x3c>
    if (pi->nwrite == pi->nread + PIPESIZE) { //DOC: pipewrite-full
    800044be:	2184a783          	lw	a5,536(s1)
    800044c2:	21c4a703          	lw	a4,540(s1)
    800044c6:	2007879b          	addiw	a5,a5,512
    800044ca:	fcf70ae3          	beq	a4,a5,8000449e <pipewrite+0x5e>
      if (copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    800044ce:	4685                	li	a3,1
    800044d0:	01590633          	add	a2,s2,s5
    800044d4:	faf40593          	addi	a1,s0,-81
    800044d8:	0509b503          	ld	a0,80(s3)
    800044dc:	9c0fd0ef          	jal	8000169c <copyin>
    800044e0:	03650e63          	beq	a0,s6,8000451c <pipewrite+0xdc>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    800044e4:	21c4a783          	lw	a5,540(s1)
    800044e8:	0017871b          	addiw	a4,a5,1
    800044ec:	20e4ae23          	sw	a4,540(s1)
    800044f0:	1ff7f793          	andi	a5,a5,511
    800044f4:	97a6                	add	a5,a5,s1
    800044f6:	faf44703          	lbu	a4,-81(s0)
    800044fa:	00e78c23          	sb	a4,24(a5)
      i++;
    800044fe:	2905                	addiw	s2,s2,1
    80004500:	b775                	j	800044ac <pipewrite+0x6c>
    80004502:	7b02                	ld	s6,32(sp)
    80004504:	6be2                	ld	s7,24(sp)
    80004506:	6c42                	ld	s8,16(sp)
  wakeup(&pi->nread);
    80004508:	21848513          	addi	a0,s1,536
    8000450c:	9effd0ef          	jal	80001efa <wakeup>
  release(&pi->lock);
    80004510:	8526                	mv	a0,s1
    80004512:	f2efc0ef          	jal	80000c40 <release>
  return i;
    80004516:	bf95                	j	8000448a <pipewrite+0x4a>
  int i = 0;
    80004518:	4901                	li	s2,0
    8000451a:	b7fd                	j	80004508 <pipewrite+0xc8>
    8000451c:	7b02                	ld	s6,32(sp)
    8000451e:	6be2                	ld	s7,24(sp)
    80004520:	6c42                	ld	s8,16(sp)
    80004522:	b7dd                	j	80004508 <pipewrite+0xc8>

0000000080004524 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80004524:	715d                	addi	sp,sp,-80
    80004526:	e486                	sd	ra,72(sp)
    80004528:	e0a2                	sd	s0,64(sp)
    8000452a:	fc26                	sd	s1,56(sp)
    8000452c:	f84a                	sd	s2,48(sp)
    8000452e:	f44e                	sd	s3,40(sp)
    80004530:	f052                	sd	s4,32(sp)
    80004532:	ec56                	sd	s5,24(sp)
    80004534:	0880                	addi	s0,sp,80
    80004536:	84aa                	mv	s1,a0
    80004538:	892e                	mv	s2,a1
    8000453a:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    8000453c:	b68fd0ef          	jal	800018a4 <myproc>
    80004540:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    80004542:	8526                	mv	a0,s1
    80004544:	e68fc0ef          	jal	80000bac <acquire>
  while (pi->nread == pi->nwrite && pi->writeopen) { //DOC: pipe-empty
    80004548:	2184a703          	lw	a4,536(s1)
    8000454c:	21c4a783          	lw	a5,540(s1)
    if (killed(pr)) {
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004550:	21848993          	addi	s3,s1,536
  while (pi->nread == pi->nwrite && pi->writeopen) { //DOC: pipe-empty
    80004554:	02f71563          	bne	a4,a5,8000457e <piperead+0x5a>
    80004558:	2244a783          	lw	a5,548(s1)
    8000455c:	cb85                	beqz	a5,8000458c <piperead+0x68>
    if (killed(pr)) {
    8000455e:	8552                	mv	a0,s4
    80004560:	b87fd0ef          	jal	800020e6 <killed>
    80004564:	ed19                	bnez	a0,80004582 <piperead+0x5e>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004566:	85a6                	mv	a1,s1
    80004568:	854e                	mv	a0,s3
    8000456a:	945fd0ef          	jal	80001eae <sleep>
  while (pi->nread == pi->nwrite && pi->writeopen) { //DOC: pipe-empty
    8000456e:	2184a703          	lw	a4,536(s1)
    80004572:	21c4a783          	lw	a5,540(s1)
    80004576:	fef701e3          	beq	a4,a5,80004558 <piperead+0x34>
    8000457a:	e85a                	sd	s6,16(sp)
    8000457c:	a809                	j	8000458e <piperead+0x6a>
    8000457e:	e85a                	sd	s6,16(sp)
    80004580:	a039                	j	8000458e <piperead+0x6a>
      release(&pi->lock);
    80004582:	8526                	mv	a0,s1
    80004584:	ebcfc0ef          	jal	80000c40 <release>
      return -1;
    80004588:	59fd                	li	s3,-1
    8000458a:	a8b9                	j	800045e8 <piperead+0xc4>
    8000458c:	e85a                	sd	s6,16(sp)
  }
  for (i = 0; i < n; i++) { //DOC: piperead-copy
    8000458e:	4981                	li	s3,0
    if (pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread % PIPESIZE];
    if (copyout(pr->pagetable, addr + i, &ch, 1) == -1) {
    80004590:	5b7d                	li	s6,-1
  for (i = 0; i < n; i++) { //DOC: piperead-copy
    80004592:	05505363          	blez	s5,800045d8 <piperead+0xb4>
    if (pi->nread == pi->nwrite)
    80004596:	2184a783          	lw	a5,536(s1)
    8000459a:	21c4a703          	lw	a4,540(s1)
    8000459e:	02f70d63          	beq	a4,a5,800045d8 <piperead+0xb4>
    ch = pi->data[pi->nread % PIPESIZE];
    800045a2:	1ff7f793          	andi	a5,a5,511
    800045a6:	97a6                	add	a5,a5,s1
    800045a8:	0187c783          	lbu	a5,24(a5)
    800045ac:	faf40fa3          	sb	a5,-65(s0)
    if (copyout(pr->pagetable, addr + i, &ch, 1) == -1) {
    800045b0:	4685                	li	a3,1
    800045b2:	fbf40613          	addi	a2,s0,-65
    800045b6:	85ca                	mv	a1,s2
    800045b8:	050a3503          	ld	a0,80(s4)
    800045bc:	ffdfc0ef          	jal	800015b8 <copyout>
    800045c0:	03650e63          	beq	a0,s6,800045fc <piperead+0xd8>
      if (i == 0)
        i = -1;
      break;
    }
    pi->nread++;
    800045c4:	2184a783          	lw	a5,536(s1)
    800045c8:	2785                	addiw	a5,a5,1
    800045ca:	20f4ac23          	sw	a5,536(s1)
  for (i = 0; i < n; i++) { //DOC: piperead-copy
    800045ce:	2985                	addiw	s3,s3,1
    800045d0:	0905                	addi	s2,s2,1
    800045d2:	fd3a92e3          	bne	s5,s3,80004596 <piperead+0x72>
    800045d6:	89d6                	mv	s3,s5
  }
  wakeup(&pi->nwrite); //DOC: piperead-wakeup
    800045d8:	21c48513          	addi	a0,s1,540
    800045dc:	91ffd0ef          	jal	80001efa <wakeup>
  release(&pi->lock);
    800045e0:	8526                	mv	a0,s1
    800045e2:	e5efc0ef          	jal	80000c40 <release>
    800045e6:	6b42                	ld	s6,16(sp)
  return i;
}
    800045e8:	854e                	mv	a0,s3
    800045ea:	60a6                	ld	ra,72(sp)
    800045ec:	6406                	ld	s0,64(sp)
    800045ee:	74e2                	ld	s1,56(sp)
    800045f0:	7942                	ld	s2,48(sp)
    800045f2:	79a2                	ld	s3,40(sp)
    800045f4:	7a02                	ld	s4,32(sp)
    800045f6:	6ae2                	ld	s5,24(sp)
    800045f8:	6161                	addi	sp,sp,80
    800045fa:	8082                	ret
      if (i == 0)
    800045fc:	fc099ee3          	bnez	s3,800045d8 <piperead+0xb4>
        i = -1;
    80004600:	89aa                	mv	s3,a0
    80004602:	bfd9                	j	800045d8 <piperead+0xb4>

0000000080004604 <flags2perm>:
static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

// map ELF permissions to PTE permission bits.
int
flags2perm(int flags)
{
    80004604:	1141                	addi	sp,sp,-16
    80004606:	e422                	sd	s0,8(sp)
    80004608:	0800                	addi	s0,sp,16
    8000460a:	87aa                	mv	a5,a0
  int perm = 0;
  if (flags & 0x1)
    8000460c:	8905                	andi	a0,a0,1
    8000460e:	050e                	slli	a0,a0,0x3
    perm = PTE_X;
  if (flags & 0x2)
    80004610:	8b89                	andi	a5,a5,2
    80004612:	c399                	beqz	a5,80004618 <flags2perm+0x14>
    perm |= PTE_W;
    80004614:	00456513          	ori	a0,a0,4
  return perm;
}
    80004618:	6422                	ld	s0,8(sp)
    8000461a:	0141                	addi	sp,sp,16
    8000461c:	8082                	ret

000000008000461e <kexec>:
//
// the implementation of the exec() system call
//
int
kexec(char *path, char **argv)
{
    8000461e:	df010113          	addi	sp,sp,-528
    80004622:	20113423          	sd	ra,520(sp)
    80004626:	20813023          	sd	s0,512(sp)
    8000462a:	ffa6                	sd	s1,504(sp)
    8000462c:	fbca                	sd	s2,496(sp)
    8000462e:	0c00                	addi	s0,sp,528
    80004630:	892a                	mv	s2,a0
    80004632:	dea43c23          	sd	a0,-520(s0)
    80004636:	e0b43023          	sd	a1,-512(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    8000463a:	a6afd0ef          	jal	800018a4 <myproc>
    8000463e:	84aa                	mv	s1,a0

  begin_op();
    80004640:	d62ff0ef          	jal	80003ba2 <begin_op>

  // Open the executable file.
  if ((ip = namei(path)) == 0) {
    80004644:	854a                	mv	a0,s2
    80004646:	b88ff0ef          	jal	800039ce <namei>
    8000464a:	c931                	beqz	a0,8000469e <kexec+0x80>
    8000464c:	f3d2                	sd	s4,480(sp)
    8000464e:	8a2a                	mv	s4,a0
    end_op();
    return -1;
  }
  ilock(ip);
    80004650:	b69fe0ef          	jal	800031b8 <ilock>

  // Read the ELF header.
  if (readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80004654:	04000713          	li	a4,64
    80004658:	4681                	li	a3,0
    8000465a:	e5040613          	addi	a2,s0,-432
    8000465e:	4581                	li	a1,0
    80004660:	8552                	mv	a0,s4
    80004662:	ee7fe0ef          	jal	80003548 <readi>
    80004666:	04000793          	li	a5,64
    8000466a:	00f51a63          	bne	a0,a5,8000467e <kexec+0x60>
    goto bad;

  // Is this really an ELF file?
  if (elf.magic != ELF_MAGIC)
    8000466e:	e5042703          	lw	a4,-432(s0)
    80004672:	464c47b7          	lui	a5,0x464c4
    80004676:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    8000467a:	02f70663          	beq	a4,a5,800046a6 <kexec+0x88>

bad:
  if (pagetable)
    proc_freepagetable(pagetable, sz);
  if (ip) {
    iunlockput(ip);
    8000467e:	8552                	mv	a0,s4
    80004680:	d43fe0ef          	jal	800033c2 <iunlockput>
    end_op();
    80004684:	d88ff0ef          	jal	80003c0c <end_op>
  }
  return -1;
    80004688:	557d                	li	a0,-1
    8000468a:	7a1e                	ld	s4,480(sp)
}
    8000468c:	20813083          	ld	ra,520(sp)
    80004690:	20013403          	ld	s0,512(sp)
    80004694:	74fe                	ld	s1,504(sp)
    80004696:	795e                	ld	s2,496(sp)
    80004698:	21010113          	addi	sp,sp,528
    8000469c:	8082                	ret
    end_op();
    8000469e:	d6eff0ef          	jal	80003c0c <end_op>
    return -1;
    800046a2:	557d                	li	a0,-1
    800046a4:	b7e5                	j	8000468c <kexec+0x6e>
    800046a6:	ebda                	sd	s6,464(sp)
  if ((pagetable = proc_pagetable(p)) == 0)
    800046a8:	8526                	mv	a0,s1
    800046aa:	b00fd0ef          	jal	800019aa <proc_pagetable>
    800046ae:	8b2a                	mv	s6,a0
    800046b0:	2c050b63          	beqz	a0,80004986 <kexec+0x368>
    800046b4:	f7ce                	sd	s3,488(sp)
    800046b6:	efd6                	sd	s5,472(sp)
    800046b8:	e7de                	sd	s7,456(sp)
    800046ba:	e3e2                	sd	s8,448(sp)
    800046bc:	ff66                	sd	s9,440(sp)
    800046be:	fb6a                	sd	s10,432(sp)
  for (i = 0, off = elf.phoff; i < elf.phnum; i++, off += sizeof(ph)) {
    800046c0:	e7042d03          	lw	s10,-400(s0)
    800046c4:	e8845783          	lhu	a5,-376(s0)
    800046c8:	12078963          	beqz	a5,800047fa <kexec+0x1dc>
    800046cc:	f76e                	sd	s11,424(sp)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    800046ce:	4901                	li	s2,0
  for (i = 0, off = elf.phoff; i < elf.phnum; i++, off += sizeof(ph)) {
    800046d0:	4d81                	li	s11,0
    if (ph.vaddr % PGSIZE != 0)
    800046d2:	6c85                	lui	s9,0x1
    800046d4:	fffc8793          	addi	a5,s9,-1 # fff <_entry-0x7ffff001>
    800046d8:	def43823          	sd	a5,-528(s0)

  for (i = 0; i < sz; i += PGSIZE) {
    pa = walkaddr(pagetable, va + i);
    if (pa == 0)
      panic("loadseg: address should exist");
    if (sz - i < PGSIZE)
    800046dc:	6a85                	lui	s5,0x1
    800046de:	a085                	j	8000473e <kexec+0x120>
      panic("loadseg: address should exist");
    800046e0:	00003517          	auipc	a0,0x3
    800046e4:	ec050513          	addi	a0,a0,-320 # 800075a0 <etext+0x5a0>
    800046e8:	8ecfc0ef          	jal	800007d4 <panic>
    if (sz - i < PGSIZE)
    800046ec:	2481                	sext.w	s1,s1
      n = sz - i;
    else
      n = PGSIZE;
    if (readi(ip, 0, (uint64)pa, offset + i, n) != n)
    800046ee:	8726                	mv	a4,s1
    800046f0:	012c06bb          	addw	a3,s8,s2
    800046f4:	4581                	li	a1,0
    800046f6:	8552                	mv	a0,s4
    800046f8:	e51fe0ef          	jal	80003548 <readi>
    800046fc:	2501                	sext.w	a0,a0
    800046fe:	24a49a63          	bne	s1,a0,80004952 <kexec+0x334>
  for (i = 0; i < sz; i += PGSIZE) {
    80004702:	012a893b          	addw	s2,s5,s2
    80004706:	03397363          	bgeu	s2,s3,8000472c <kexec+0x10e>
    pa = walkaddr(pagetable, va + i);
    8000470a:	02091593          	slli	a1,s2,0x20
    8000470e:	9181                	srli	a1,a1,0x20
    80004710:	95de                	add	a1,a1,s7
    80004712:	855a                	mv	a0,s6
    80004714:	873fc0ef          	jal	80000f86 <walkaddr>
    80004718:	862a                	mv	a2,a0
    if (pa == 0)
    8000471a:	d179                	beqz	a0,800046e0 <kexec+0xc2>
    if (sz - i < PGSIZE)
    8000471c:	412984bb          	subw	s1,s3,s2
    80004720:	0004879b          	sext.w	a5,s1
    80004724:	fcfcf4e3          	bgeu	s9,a5,800046ec <kexec+0xce>
    80004728:	84d6                	mv	s1,s5
    8000472a:	b7c9                	j	800046ec <kexec+0xce>
    sz = sz1;
    8000472c:	e0843903          	ld	s2,-504(s0)
  for (i = 0, off = elf.phoff; i < elf.phnum; i++, off += sizeof(ph)) {
    80004730:	2d85                	addiw	s11,s11,1
    80004732:	038d0d1b          	addiw	s10,s10,56 # 1038 <_entry-0x7fffefc8>
    80004736:	e8845783          	lhu	a5,-376(s0)
    8000473a:	08fdd063          	bge	s11,a5,800047ba <kexec+0x19c>
    if (readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    8000473e:	2d01                	sext.w	s10,s10
    80004740:	03800713          	li	a4,56
    80004744:	86ea                	mv	a3,s10
    80004746:	e1840613          	addi	a2,s0,-488
    8000474a:	4581                	li	a1,0
    8000474c:	8552                	mv	a0,s4
    8000474e:	dfbfe0ef          	jal	80003548 <readi>
    80004752:	03800793          	li	a5,56
    80004756:	1cf51663          	bne	a0,a5,80004922 <kexec+0x304>
    if (ph.type != ELF_PROG_LOAD)
    8000475a:	e1842783          	lw	a5,-488(s0)
    8000475e:	4705                	li	a4,1
    80004760:	fce798e3          	bne	a5,a4,80004730 <kexec+0x112>
    if (ph.memsz < ph.filesz)
    80004764:	e4043483          	ld	s1,-448(s0)
    80004768:	e3843783          	ld	a5,-456(s0)
    8000476c:	1af4ef63          	bltu	s1,a5,8000492a <kexec+0x30c>
    if (ph.vaddr + ph.memsz < ph.vaddr)
    80004770:	e2843783          	ld	a5,-472(s0)
    80004774:	94be                	add	s1,s1,a5
    80004776:	1af4ee63          	bltu	s1,a5,80004932 <kexec+0x314>
    if (ph.vaddr % PGSIZE != 0)
    8000477a:	df043703          	ld	a4,-528(s0)
    8000477e:	8ff9                	and	a5,a5,a4
    80004780:	1a079d63          	bnez	a5,8000493a <kexec+0x31c>
    if ((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz,
    80004784:	e1c42503          	lw	a0,-484(s0)
    80004788:	e7dff0ef          	jal	80004604 <flags2perm>
    8000478c:	86aa                	mv	a3,a0
    8000478e:	8626                	mv	a2,s1
    80004790:	85ca                	mv	a1,s2
    80004792:	855a                	mv	a0,s6
    80004794:	acbfc0ef          	jal	8000125e <uvmalloc>
    80004798:	e0a43423          	sd	a0,-504(s0)
    8000479c:	1a050363          	beqz	a0,80004942 <kexec+0x324>
    if (loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    800047a0:	e2843b83          	ld	s7,-472(s0)
    800047a4:	e2042c03          	lw	s8,-480(s0)
    800047a8:	e3842983          	lw	s3,-456(s0)
  for (i = 0; i < sz; i += PGSIZE) {
    800047ac:	00098463          	beqz	s3,800047b4 <kexec+0x196>
    800047b0:	4901                	li	s2,0
    800047b2:	bfa1                	j	8000470a <kexec+0xec>
    sz = sz1;
    800047b4:	e0843903          	ld	s2,-504(s0)
    800047b8:	bfa5                	j	80004730 <kexec+0x112>
    800047ba:	7dba                	ld	s11,424(sp)
  iunlockput(ip);
    800047bc:	8552                	mv	a0,s4
    800047be:	c05fe0ef          	jal	800033c2 <iunlockput>
  end_op();
    800047c2:	c4aff0ef          	jal	80003c0c <end_op>
  p = myproc();
    800047c6:	8defd0ef          	jal	800018a4 <myproc>
    800047ca:	8aaa                	mv	s5,a0
  uint64 oldsz = p->sz;
    800047cc:	04853c83          	ld	s9,72(a0)
  sz = PGROUNDUP(sz);
    800047d0:	6985                	lui	s3,0x1
    800047d2:	19fd                	addi	s3,s3,-1 # fff <_entry-0x7ffff001>
    800047d4:	99ca                	add	s3,s3,s2
    800047d6:	77fd                	lui	a5,0xfffff
    800047d8:	00f9f9b3          	and	s3,s3,a5
  if ((sz1 = uvmalloc(pagetable, sz, sz + (USERSTACK + 1) * PGSIZE, PTE_W)) ==
    800047dc:	4691                	li	a3,4
    800047de:	6609                	lui	a2,0x2
    800047e0:	964e                	add	a2,a2,s3
    800047e2:	85ce                	mv	a1,s3
    800047e4:	855a                	mv	a0,s6
    800047e6:	a79fc0ef          	jal	8000125e <uvmalloc>
    800047ea:	892a                	mv	s2,a0
    800047ec:	e0a43423          	sd	a0,-504(s0)
    800047f0:	e519                	bnez	a0,800047fe <kexec+0x1e0>
  if (pagetable)
    800047f2:	e1343423          	sd	s3,-504(s0)
    800047f6:	4a01                	li	s4,0
    800047f8:	aab1                	j	80004954 <kexec+0x336>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    800047fa:	4901                	li	s2,0
    800047fc:	b7c1                	j	800047bc <kexec+0x19e>
  uvmclear(pagetable, sz - (USERSTACK + 1) * PGSIZE);
    800047fe:	75f9                	lui	a1,0xffffe
    80004800:	95aa                	add	a1,a1,a0
    80004802:	855a                	mv	a0,s6
    80004804:	c31fc0ef          	jal	80001434 <uvmclear>
  stackbase = sp - USERSTACK * PGSIZE;
    80004808:	7bfd                	lui	s7,0xfffff
    8000480a:	9bca                	add	s7,s7,s2
  for (argc = 0; argv[argc]; argc++) {
    8000480c:	e0043783          	ld	a5,-512(s0)
    80004810:	6388                	ld	a0,0(a5)
    80004812:	cd39                	beqz	a0,80004870 <kexec+0x252>
    80004814:	e9040993          	addi	s3,s0,-368
    80004818:	f9040c13          	addi	s8,s0,-112
    8000481c:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    8000481e:	dcafc0ef          	jal	80000de8 <strlen>
    80004822:	0015079b          	addiw	a5,a0,1
    80004826:	40f907b3          	sub	a5,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    8000482a:	ff07f913          	andi	s2,a5,-16
    if (sp < stackbase)
    8000482e:	11796e63          	bltu	s2,s7,8000494a <kexec+0x32c>
    if (copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80004832:	e0043d03          	ld	s10,-512(s0)
    80004836:	000d3a03          	ld	s4,0(s10)
    8000483a:	8552                	mv	a0,s4
    8000483c:	dacfc0ef          	jal	80000de8 <strlen>
    80004840:	0015069b          	addiw	a3,a0,1
    80004844:	8652                	mv	a2,s4
    80004846:	85ca                	mv	a1,s2
    80004848:	855a                	mv	a0,s6
    8000484a:	d6ffc0ef          	jal	800015b8 <copyout>
    8000484e:	10054063          	bltz	a0,8000494e <kexec+0x330>
    ustack[argc] = sp;
    80004852:	0129b023          	sd	s2,0(s3)
  for (argc = 0; argv[argc]; argc++) {
    80004856:	0485                	addi	s1,s1,1
    80004858:	008d0793          	addi	a5,s10,8
    8000485c:	e0f43023          	sd	a5,-512(s0)
    80004860:	008d3503          	ld	a0,8(s10)
    80004864:	c909                	beqz	a0,80004876 <kexec+0x258>
    if (argc >= MAXARG)
    80004866:	09a1                	addi	s3,s3,8
    80004868:	fb899be3          	bne	s3,s8,8000481e <kexec+0x200>
  ip = 0;
    8000486c:	4a01                	li	s4,0
    8000486e:	a0dd                	j	80004954 <kexec+0x336>
  sp = sz;
    80004870:	e0843903          	ld	s2,-504(s0)
  for (argc = 0; argv[argc]; argc++) {
    80004874:	4481                	li	s1,0
  ustack[argc] = 0;
    80004876:	00349793          	slli	a5,s1,0x3
    8000487a:	f9078793          	addi	a5,a5,-112 # ffffffffffffef90 <end+0xffffffff7ffdbab8>
    8000487e:	97a2                	add	a5,a5,s0
    80004880:	f007b023          	sd	zero,-256(a5)
  sp -= (argc + 1) * sizeof(uint64);
    80004884:	00148693          	addi	a3,s1,1
    80004888:	068e                	slli	a3,a3,0x3
    8000488a:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    8000488e:	ff097913          	andi	s2,s2,-16
  sz = sz1;
    80004892:	e0843983          	ld	s3,-504(s0)
  if (sp < stackbase)
    80004896:	f5796ee3          	bltu	s2,s7,800047f2 <kexec+0x1d4>
  if (copyout(pagetable, sp, (char *)ustack, (argc + 1) * sizeof(uint64)) < 0)
    8000489a:	e9040613          	addi	a2,s0,-368
    8000489e:	85ca                	mv	a1,s2
    800048a0:	855a                	mv	a0,s6
    800048a2:	d17fc0ef          	jal	800015b8 <copyout>
    800048a6:	0e054263          	bltz	a0,8000498a <kexec+0x36c>
  p->trapframe->a1 = sp;
    800048aa:	058ab783          	ld	a5,88(s5) # 1058 <_entry-0x7fffefa8>
    800048ae:	0727bc23          	sd	s2,120(a5)
  for (last = s = path; *s; s++)
    800048b2:	df843783          	ld	a5,-520(s0)
    800048b6:	0007c703          	lbu	a4,0(a5)
    800048ba:	cf11                	beqz	a4,800048d6 <kexec+0x2b8>
    800048bc:	0785                	addi	a5,a5,1
    if (*s == '/')
    800048be:	02f00693          	li	a3,47
    800048c2:	a039                	j	800048d0 <kexec+0x2b2>
      last = s + 1;
    800048c4:	def43c23          	sd	a5,-520(s0)
  for (last = s = path; *s; s++)
    800048c8:	0785                	addi	a5,a5,1
    800048ca:	fff7c703          	lbu	a4,-1(a5)
    800048ce:	c701                	beqz	a4,800048d6 <kexec+0x2b8>
    if (*s == '/')
    800048d0:	fed71ce3          	bne	a4,a3,800048c8 <kexec+0x2aa>
    800048d4:	bfc5                	j	800048c4 <kexec+0x2a6>
  safestrcpy(p->name, last, sizeof(p->name));
    800048d6:	4641                	li	a2,16
    800048d8:	df843583          	ld	a1,-520(s0)
    800048dc:	158a8513          	addi	a0,s5,344
    800048e0:	cd6fc0ef          	jal	80000db6 <safestrcpy>
  oldpagetable = p->pagetable;
    800048e4:	050ab503          	ld	a0,80(s5)
  p->pagetable = pagetable;
    800048e8:	056ab823          	sd	s6,80(s5)
  p->sz = sz;
    800048ec:	e0843783          	ld	a5,-504(s0)
    800048f0:	04fab423          	sd	a5,72(s5)
  p->trapframe->epc = elf.entry; // initial program counter = ulib.c:start()
    800048f4:	058ab783          	ld	a5,88(s5)
    800048f8:	e6843703          	ld	a4,-408(s0)
    800048fc:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp;         // initial stack pointer
    800048fe:	058ab783          	ld	a5,88(s5)
    80004902:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    80004906:	85e6                	mv	a1,s9
    80004908:	926fd0ef          	jal	80001a2e <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    8000490c:	0004851b          	sext.w	a0,s1
    80004910:	79be                	ld	s3,488(sp)
    80004912:	7a1e                	ld	s4,480(sp)
    80004914:	6afe                	ld	s5,472(sp)
    80004916:	6b5e                	ld	s6,464(sp)
    80004918:	6bbe                	ld	s7,456(sp)
    8000491a:	6c1e                	ld	s8,448(sp)
    8000491c:	7cfa                	ld	s9,440(sp)
    8000491e:	7d5a                	ld	s10,432(sp)
    80004920:	b3b5                	j	8000468c <kexec+0x6e>
    80004922:	e1243423          	sd	s2,-504(s0)
    80004926:	7dba                	ld	s11,424(sp)
    80004928:	a035                	j	80004954 <kexec+0x336>
    8000492a:	e1243423          	sd	s2,-504(s0)
    8000492e:	7dba                	ld	s11,424(sp)
    80004930:	a015                	j	80004954 <kexec+0x336>
    80004932:	e1243423          	sd	s2,-504(s0)
    80004936:	7dba                	ld	s11,424(sp)
    80004938:	a831                	j	80004954 <kexec+0x336>
    8000493a:	e1243423          	sd	s2,-504(s0)
    8000493e:	7dba                	ld	s11,424(sp)
    80004940:	a811                	j	80004954 <kexec+0x336>
    80004942:	e1243423          	sd	s2,-504(s0)
    80004946:	7dba                	ld	s11,424(sp)
    80004948:	a031                	j	80004954 <kexec+0x336>
  ip = 0;
    8000494a:	4a01                	li	s4,0
    8000494c:	a021                	j	80004954 <kexec+0x336>
    8000494e:	4a01                	li	s4,0
  if (pagetable)
    80004950:	a011                	j	80004954 <kexec+0x336>
    80004952:	7dba                	ld	s11,424(sp)
    proc_freepagetable(pagetable, sz);
    80004954:	e0843583          	ld	a1,-504(s0)
    80004958:	855a                	mv	a0,s6
    8000495a:	8d4fd0ef          	jal	80001a2e <proc_freepagetable>
  return -1;
    8000495e:	557d                	li	a0,-1
  if (ip) {
    80004960:	000a1b63          	bnez	s4,80004976 <kexec+0x358>
    80004964:	79be                	ld	s3,488(sp)
    80004966:	7a1e                	ld	s4,480(sp)
    80004968:	6afe                	ld	s5,472(sp)
    8000496a:	6b5e                	ld	s6,464(sp)
    8000496c:	6bbe                	ld	s7,456(sp)
    8000496e:	6c1e                	ld	s8,448(sp)
    80004970:	7cfa                	ld	s9,440(sp)
    80004972:	7d5a                	ld	s10,432(sp)
    80004974:	bb21                	j	8000468c <kexec+0x6e>
    80004976:	79be                	ld	s3,488(sp)
    80004978:	6afe                	ld	s5,472(sp)
    8000497a:	6b5e                	ld	s6,464(sp)
    8000497c:	6bbe                	ld	s7,456(sp)
    8000497e:	6c1e                	ld	s8,448(sp)
    80004980:	7cfa                	ld	s9,440(sp)
    80004982:	7d5a                	ld	s10,432(sp)
    80004984:	b9ed                	j	8000467e <kexec+0x60>
    80004986:	6b5e                	ld	s6,464(sp)
    80004988:	b9dd                	j	8000467e <kexec+0x60>
  sz = sz1;
    8000498a:	e0843983          	ld	s3,-504(s0)
    8000498e:	b595                	j	800047f2 <kexec+0x1d4>

0000000080004990 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80004990:	7179                	addi	sp,sp,-48
    80004992:	f406                	sd	ra,40(sp)
    80004994:	f022                	sd	s0,32(sp)
    80004996:	ec26                	sd	s1,24(sp)
    80004998:	e84a                	sd	s2,16(sp)
    8000499a:	1800                	addi	s0,sp,48
    8000499c:	892e                	mv	s2,a1
    8000499e:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    800049a0:	fdc40593          	addi	a1,s0,-36
    800049a4:	e0ffd0ef          	jal	800027b2 <argint>
  if (fd < 0 || fd >= NOFILE || (f = myproc()->ofile[fd]) == 0)
    800049a8:	fdc42703          	lw	a4,-36(s0)
    800049ac:	47bd                	li	a5,15
    800049ae:	02e7e963          	bltu	a5,a4,800049e0 <argfd+0x50>
    800049b2:	ef3fc0ef          	jal	800018a4 <myproc>
    800049b6:	fdc42703          	lw	a4,-36(s0)
    800049ba:	01a70793          	addi	a5,a4,26
    800049be:	078e                	slli	a5,a5,0x3
    800049c0:	953e                	add	a0,a0,a5
    800049c2:	611c                	ld	a5,0(a0)
    800049c4:	c385                	beqz	a5,800049e4 <argfd+0x54>
    return -1;
  if (pfd)
    800049c6:	00090463          	beqz	s2,800049ce <argfd+0x3e>
    *pfd = fd;
    800049ca:	00e92023          	sw	a4,0(s2)
  if (pf)
    *pf = f;
  return 0;
    800049ce:	4501                	li	a0,0
  if (pf)
    800049d0:	c091                	beqz	s1,800049d4 <argfd+0x44>
    *pf = f;
    800049d2:	e09c                	sd	a5,0(s1)
}
    800049d4:	70a2                	ld	ra,40(sp)
    800049d6:	7402                	ld	s0,32(sp)
    800049d8:	64e2                	ld	s1,24(sp)
    800049da:	6942                	ld	s2,16(sp)
    800049dc:	6145                	addi	sp,sp,48
    800049de:	8082                	ret
    return -1;
    800049e0:	557d                	li	a0,-1
    800049e2:	bfcd                	j	800049d4 <argfd+0x44>
    800049e4:	557d                	li	a0,-1
    800049e6:	b7fd                	j	800049d4 <argfd+0x44>

00000000800049e8 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    800049e8:	1101                	addi	sp,sp,-32
    800049ea:	ec06                	sd	ra,24(sp)
    800049ec:	e822                	sd	s0,16(sp)
    800049ee:	e426                	sd	s1,8(sp)
    800049f0:	1000                	addi	s0,sp,32
    800049f2:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    800049f4:	eb1fc0ef          	jal	800018a4 <myproc>
    800049f8:	862a                	mv	a2,a0

  for (fd = 0; fd < NOFILE; fd++) {
    800049fa:	0d050793          	addi	a5,a0,208
    800049fe:	4501                	li	a0,0
    80004a00:	46c1                	li	a3,16
    if (p->ofile[fd] == 0) {
    80004a02:	6398                	ld	a4,0(a5)
    80004a04:	cb19                	beqz	a4,80004a1a <fdalloc+0x32>
  for (fd = 0; fd < NOFILE; fd++) {
    80004a06:	2505                	addiw	a0,a0,1
    80004a08:	07a1                	addi	a5,a5,8
    80004a0a:	fed51ce3          	bne	a0,a3,80004a02 <fdalloc+0x1a>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80004a0e:	557d                	li	a0,-1
}
    80004a10:	60e2                	ld	ra,24(sp)
    80004a12:	6442                	ld	s0,16(sp)
    80004a14:	64a2                	ld	s1,8(sp)
    80004a16:	6105                	addi	sp,sp,32
    80004a18:	8082                	ret
      p->ofile[fd] = f;
    80004a1a:	01a50793          	addi	a5,a0,26
    80004a1e:	078e                	slli	a5,a5,0x3
    80004a20:	963e                	add	a2,a2,a5
    80004a22:	e204                	sd	s1,0(a2)
      return fd;
    80004a24:	b7f5                	j	80004a10 <fdalloc+0x28>

0000000080004a26 <create>:
  return -1;
}

static struct inode *
create(char *path, short type, short major, short minor)
{
    80004a26:	715d                	addi	sp,sp,-80
    80004a28:	e486                	sd	ra,72(sp)
    80004a2a:	e0a2                	sd	s0,64(sp)
    80004a2c:	fc26                	sd	s1,56(sp)
    80004a2e:	f84a                	sd	s2,48(sp)
    80004a30:	f44e                	sd	s3,40(sp)
    80004a32:	ec56                	sd	s5,24(sp)
    80004a34:	e85a                	sd	s6,16(sp)
    80004a36:	0880                	addi	s0,sp,80
    80004a38:	8b2e                	mv	s6,a1
    80004a3a:	89b2                	mv	s3,a2
    80004a3c:	8936                	mv	s2,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if ((dp = nameiparent(path, name)) == 0)
    80004a3e:	fb040593          	addi	a1,s0,-80
    80004a42:	fa7fe0ef          	jal	800039e8 <nameiparent>
    80004a46:	84aa                	mv	s1,a0
    80004a48:	10050a63          	beqz	a0,80004b5c <create+0x136>
    return 0;

  ilock(dp);
    80004a4c:	f6cfe0ef          	jal	800031b8 <ilock>

  if ((ip = dirlookup(dp, name, 0)) != 0) {
    80004a50:	4601                	li	a2,0
    80004a52:	fb040593          	addi	a1,s0,-80
    80004a56:	8526                	mv	a0,s1
    80004a58:	d11fe0ef          	jal	80003768 <dirlookup>
    80004a5c:	8aaa                	mv	s5,a0
    80004a5e:	c129                	beqz	a0,80004aa0 <create+0x7a>
    iunlockput(dp);
    80004a60:	8526                	mv	a0,s1
    80004a62:	961fe0ef          	jal	800033c2 <iunlockput>
    ilock(ip);
    80004a66:	8556                	mv	a0,s5
    80004a68:	f50fe0ef          	jal	800031b8 <ilock>
    if (type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    80004a6c:	4789                	li	a5,2
    80004a6e:	02fb1463          	bne	s6,a5,80004a96 <create+0x70>
    80004a72:	044ad783          	lhu	a5,68(s5)
    80004a76:	37f9                	addiw	a5,a5,-2
    80004a78:	17c2                	slli	a5,a5,0x30
    80004a7a:	93c1                	srli	a5,a5,0x30
    80004a7c:	4705                	li	a4,1
    80004a7e:	00f76c63          	bltu	a4,a5,80004a96 <create+0x70>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    80004a82:	8556                	mv	a0,s5
    80004a84:	60a6                	ld	ra,72(sp)
    80004a86:	6406                	ld	s0,64(sp)
    80004a88:	74e2                	ld	s1,56(sp)
    80004a8a:	7942                	ld	s2,48(sp)
    80004a8c:	79a2                	ld	s3,40(sp)
    80004a8e:	6ae2                	ld	s5,24(sp)
    80004a90:	6b42                	ld	s6,16(sp)
    80004a92:	6161                	addi	sp,sp,80
    80004a94:	8082                	ret
    iunlockput(ip);
    80004a96:	8556                	mv	a0,s5
    80004a98:	92bfe0ef          	jal	800033c2 <iunlockput>
    return 0;
    80004a9c:	4a81                	li	s5,0
    80004a9e:	b7d5                	j	80004a82 <create+0x5c>
    80004aa0:	f052                	sd	s4,32(sp)
  if ((ip = ialloc(dp->dev, type)) == 0) {
    80004aa2:	85da                	mv	a1,s6
    80004aa4:	4088                	lw	a0,0(s1)
    80004aa6:	da2fe0ef          	jal	80003048 <ialloc>
    80004aaa:	8a2a                	mv	s4,a0
    80004aac:	cd15                	beqz	a0,80004ae8 <create+0xc2>
  ilock(ip);
    80004aae:	f0afe0ef          	jal	800031b8 <ilock>
  ip->major = major;
    80004ab2:	053a1323          	sh	s3,70(s4)
  ip->minor = minor;
    80004ab6:	052a1423          	sh	s2,72(s4)
  ip->nlink = 1;
    80004aba:	4905                	li	s2,1
    80004abc:	052a1523          	sh	s2,74(s4)
  iupdate(ip);
    80004ac0:	8552                	mv	a0,s4
    80004ac2:	e42fe0ef          	jal	80003104 <iupdate>
  if (type == T_DIR) { // Create . and .. entries.
    80004ac6:	032b0763          	beq	s6,s2,80004af4 <create+0xce>
  if (dirlink(dp, name, ip->inum) < 0)
    80004aca:	004a2603          	lw	a2,4(s4)
    80004ace:	fb040593          	addi	a1,s0,-80
    80004ad2:	8526                	mv	a0,s1
    80004ad4:	e61fe0ef          	jal	80003934 <dirlink>
    80004ad8:	06054563          	bltz	a0,80004b42 <create+0x11c>
  iunlockput(dp);
    80004adc:	8526                	mv	a0,s1
    80004ade:	8e5fe0ef          	jal	800033c2 <iunlockput>
  return ip;
    80004ae2:	8ad2                	mv	s5,s4
    80004ae4:	7a02                	ld	s4,32(sp)
    80004ae6:	bf71                	j	80004a82 <create+0x5c>
    iunlockput(dp);
    80004ae8:	8526                	mv	a0,s1
    80004aea:	8d9fe0ef          	jal	800033c2 <iunlockput>
    return 0;
    80004aee:	8ad2                	mv	s5,s4
    80004af0:	7a02                	ld	s4,32(sp)
    80004af2:	bf41                	j	80004a82 <create+0x5c>
    if (dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    80004af4:	004a2603          	lw	a2,4(s4)
    80004af8:	00003597          	auipc	a1,0x3
    80004afc:	ac858593          	addi	a1,a1,-1336 # 800075c0 <etext+0x5c0>
    80004b00:	8552                	mv	a0,s4
    80004b02:	e33fe0ef          	jal	80003934 <dirlink>
    80004b06:	02054e63          	bltz	a0,80004b42 <create+0x11c>
    80004b0a:	40d0                	lw	a2,4(s1)
    80004b0c:	00003597          	auipc	a1,0x3
    80004b10:	abc58593          	addi	a1,a1,-1348 # 800075c8 <etext+0x5c8>
    80004b14:	8552                	mv	a0,s4
    80004b16:	e1ffe0ef          	jal	80003934 <dirlink>
    80004b1a:	02054463          	bltz	a0,80004b42 <create+0x11c>
  if (dirlink(dp, name, ip->inum) < 0)
    80004b1e:	004a2603          	lw	a2,4(s4)
    80004b22:	fb040593          	addi	a1,s0,-80
    80004b26:	8526                	mv	a0,s1
    80004b28:	e0dfe0ef          	jal	80003934 <dirlink>
    80004b2c:	00054b63          	bltz	a0,80004b42 <create+0x11c>
    dp->nlink++; // for ".."
    80004b30:	04a4d783          	lhu	a5,74(s1)
    80004b34:	2785                	addiw	a5,a5,1
    80004b36:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80004b3a:	8526                	mv	a0,s1
    80004b3c:	dc8fe0ef          	jal	80003104 <iupdate>
    80004b40:	bf71                	j	80004adc <create+0xb6>
  ip->nlink = 0;
    80004b42:	040a1523          	sh	zero,74(s4)
  iupdate(ip);
    80004b46:	8552                	mv	a0,s4
    80004b48:	dbcfe0ef          	jal	80003104 <iupdate>
  iunlockput(ip);
    80004b4c:	8552                	mv	a0,s4
    80004b4e:	875fe0ef          	jal	800033c2 <iunlockput>
  iunlockput(dp);
    80004b52:	8526                	mv	a0,s1
    80004b54:	86ffe0ef          	jal	800033c2 <iunlockput>
  return 0;
    80004b58:	7a02                	ld	s4,32(sp)
    80004b5a:	b725                	j	80004a82 <create+0x5c>
    return 0;
    80004b5c:	8aaa                	mv	s5,a0
    80004b5e:	b715                	j	80004a82 <create+0x5c>

0000000080004b60 <sys_dup>:
{
    80004b60:	7179                	addi	sp,sp,-48
    80004b62:	f406                	sd	ra,40(sp)
    80004b64:	f022                	sd	s0,32(sp)
    80004b66:	1800                	addi	s0,sp,48
  if (argfd(0, 0, &f) < 0)
    80004b68:	fd840613          	addi	a2,s0,-40
    80004b6c:	4581                	li	a1,0
    80004b6e:	4501                	li	a0,0
    80004b70:	e21ff0ef          	jal	80004990 <argfd>
    return -1;
    80004b74:	57fd                	li	a5,-1
  if (argfd(0, 0, &f) < 0)
    80004b76:	02054363          	bltz	a0,80004b9c <sys_dup+0x3c>
    80004b7a:	ec26                	sd	s1,24(sp)
    80004b7c:	e84a                	sd	s2,16(sp)
  if ((fd = fdalloc(f)) < 0)
    80004b7e:	fd843903          	ld	s2,-40(s0)
    80004b82:	854a                	mv	a0,s2
    80004b84:	e65ff0ef          	jal	800049e8 <fdalloc>
    80004b88:	84aa                	mv	s1,a0
    return -1;
    80004b8a:	57fd                	li	a5,-1
  if ((fd = fdalloc(f)) < 0)
    80004b8c:	00054d63          	bltz	a0,80004ba6 <sys_dup+0x46>
  filedup(f);
    80004b90:	854a                	mv	a0,s2
    80004b92:	c3eff0ef          	jal	80003fd0 <filedup>
  return fd;
    80004b96:	87a6                	mv	a5,s1
    80004b98:	64e2                	ld	s1,24(sp)
    80004b9a:	6942                	ld	s2,16(sp)
}
    80004b9c:	853e                	mv	a0,a5
    80004b9e:	70a2                	ld	ra,40(sp)
    80004ba0:	7402                	ld	s0,32(sp)
    80004ba2:	6145                	addi	sp,sp,48
    80004ba4:	8082                	ret
    80004ba6:	64e2                	ld	s1,24(sp)
    80004ba8:	6942                	ld	s2,16(sp)
    80004baa:	bfcd                	j	80004b9c <sys_dup+0x3c>

0000000080004bac <sys_read>:
{
    80004bac:	7179                	addi	sp,sp,-48
    80004bae:	f406                	sd	ra,40(sp)
    80004bb0:	f022                	sd	s0,32(sp)
    80004bb2:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80004bb4:	fd840593          	addi	a1,s0,-40
    80004bb8:	4505                	li	a0,1
    80004bba:	c15fd0ef          	jal	800027ce <argaddr>
  argint(2, &n);
    80004bbe:	fe440593          	addi	a1,s0,-28
    80004bc2:	4509                	li	a0,2
    80004bc4:	beffd0ef          	jal	800027b2 <argint>
  if (argfd(0, 0, &f) < 0)
    80004bc8:	fe840613          	addi	a2,s0,-24
    80004bcc:	4581                	li	a1,0
    80004bce:	4501                	li	a0,0
    80004bd0:	dc1ff0ef          	jal	80004990 <argfd>
    80004bd4:	87aa                	mv	a5,a0
    return -1;
    80004bd6:	557d                	li	a0,-1
  if (argfd(0, 0, &f) < 0)
    80004bd8:	0007ca63          	bltz	a5,80004bec <sys_read+0x40>
  return fileread(f, p, n);
    80004bdc:	fe442603          	lw	a2,-28(s0)
    80004be0:	fd843583          	ld	a1,-40(s0)
    80004be4:	fe843503          	ld	a0,-24(s0)
    80004be8:	d4eff0ef          	jal	80004136 <fileread>
}
    80004bec:	70a2                	ld	ra,40(sp)
    80004bee:	7402                	ld	s0,32(sp)
    80004bf0:	6145                	addi	sp,sp,48
    80004bf2:	8082                	ret

0000000080004bf4 <sys_write>:
{
    80004bf4:	7179                	addi	sp,sp,-48
    80004bf6:	f406                	sd	ra,40(sp)
    80004bf8:	f022                	sd	s0,32(sp)
    80004bfa:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80004bfc:	fd840593          	addi	a1,s0,-40
    80004c00:	4505                	li	a0,1
    80004c02:	bcdfd0ef          	jal	800027ce <argaddr>
  argint(2, &n);
    80004c06:	fe440593          	addi	a1,s0,-28
    80004c0a:	4509                	li	a0,2
    80004c0c:	ba7fd0ef          	jal	800027b2 <argint>
  if (argfd(0, 0, &f) < 0)
    80004c10:	fe840613          	addi	a2,s0,-24
    80004c14:	4581                	li	a1,0
    80004c16:	4501                	li	a0,0
    80004c18:	d79ff0ef          	jal	80004990 <argfd>
    80004c1c:	87aa                	mv	a5,a0
    return -1;
    80004c1e:	557d                	li	a0,-1
  if (argfd(0, 0, &f) < 0)
    80004c20:	0007ca63          	bltz	a5,80004c34 <sys_write+0x40>
  return filewrite(f, p, n);
    80004c24:	fe442603          	lw	a2,-28(s0)
    80004c28:	fd843583          	ld	a1,-40(s0)
    80004c2c:	fe843503          	ld	a0,-24(s0)
    80004c30:	dc4ff0ef          	jal	800041f4 <filewrite>
}
    80004c34:	70a2                	ld	ra,40(sp)
    80004c36:	7402                	ld	s0,32(sp)
    80004c38:	6145                	addi	sp,sp,48
    80004c3a:	8082                	ret

0000000080004c3c <sys_close>:
{
    80004c3c:	1101                	addi	sp,sp,-32
    80004c3e:	ec06                	sd	ra,24(sp)
    80004c40:	e822                	sd	s0,16(sp)
    80004c42:	1000                	addi	s0,sp,32
  if (argfd(0, &fd, &f) < 0)
    80004c44:	fe040613          	addi	a2,s0,-32
    80004c48:	fec40593          	addi	a1,s0,-20
    80004c4c:	4501                	li	a0,0
    80004c4e:	d43ff0ef          	jal	80004990 <argfd>
    return -1;
    80004c52:	57fd                	li	a5,-1
  if (argfd(0, &fd, &f) < 0)
    80004c54:	02054063          	bltz	a0,80004c74 <sys_close+0x38>
  myproc()->ofile[fd] = 0;
    80004c58:	c4dfc0ef          	jal	800018a4 <myproc>
    80004c5c:	fec42783          	lw	a5,-20(s0)
    80004c60:	07e9                	addi	a5,a5,26
    80004c62:	078e                	slli	a5,a5,0x3
    80004c64:	953e                	add	a0,a0,a5
    80004c66:	00053023          	sd	zero,0(a0)
  fileclose(f);
    80004c6a:	fe043503          	ld	a0,-32(s0)
    80004c6e:	ba8ff0ef          	jal	80004016 <fileclose>
  return 0;
    80004c72:	4781                	li	a5,0
}
    80004c74:	853e                	mv	a0,a5
    80004c76:	60e2                	ld	ra,24(sp)
    80004c78:	6442                	ld	s0,16(sp)
    80004c7a:	6105                	addi	sp,sp,32
    80004c7c:	8082                	ret

0000000080004c7e <sys_fstat>:
{
    80004c7e:	1101                	addi	sp,sp,-32
    80004c80:	ec06                	sd	ra,24(sp)
    80004c82:	e822                	sd	s0,16(sp)
    80004c84:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    80004c86:	fe040593          	addi	a1,s0,-32
    80004c8a:	4505                	li	a0,1
    80004c8c:	b43fd0ef          	jal	800027ce <argaddr>
  if (argfd(0, 0, &f) < 0)
    80004c90:	fe840613          	addi	a2,s0,-24
    80004c94:	4581                	li	a1,0
    80004c96:	4501                	li	a0,0
    80004c98:	cf9ff0ef          	jal	80004990 <argfd>
    80004c9c:	87aa                	mv	a5,a0
    return -1;
    80004c9e:	557d                	li	a0,-1
  if (argfd(0, 0, &f) < 0)
    80004ca0:	0007c863          	bltz	a5,80004cb0 <sys_fstat+0x32>
  return filestat(f, st);
    80004ca4:	fe043583          	ld	a1,-32(s0)
    80004ca8:	fe843503          	ld	a0,-24(s0)
    80004cac:	c2cff0ef          	jal	800040d8 <filestat>
}
    80004cb0:	60e2                	ld	ra,24(sp)
    80004cb2:	6442                	ld	s0,16(sp)
    80004cb4:	6105                	addi	sp,sp,32
    80004cb6:	8082                	ret

0000000080004cb8 <sys_link>:
{
    80004cb8:	7169                	addi	sp,sp,-304
    80004cba:	f606                	sd	ra,296(sp)
    80004cbc:	f222                	sd	s0,288(sp)
    80004cbe:	1a00                	addi	s0,sp,304
  if (argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80004cc0:	08000613          	li	a2,128
    80004cc4:	ed040593          	addi	a1,s0,-304
    80004cc8:	4501                	li	a0,0
    80004cca:	b21fd0ef          	jal	800027ea <argstr>
    return -1;
    80004cce:	57fd                	li	a5,-1
  if (argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80004cd0:	0c054e63          	bltz	a0,80004dac <sys_link+0xf4>
    80004cd4:	08000613          	li	a2,128
    80004cd8:	f5040593          	addi	a1,s0,-176
    80004cdc:	4505                	li	a0,1
    80004cde:	b0dfd0ef          	jal	800027ea <argstr>
    return -1;
    80004ce2:	57fd                	li	a5,-1
  if (argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80004ce4:	0c054463          	bltz	a0,80004dac <sys_link+0xf4>
    80004ce8:	ee26                	sd	s1,280(sp)
  begin_op();
    80004cea:	eb9fe0ef          	jal	80003ba2 <begin_op>
  if ((ip = namei(old)) == 0) {
    80004cee:	ed040513          	addi	a0,s0,-304
    80004cf2:	cddfe0ef          	jal	800039ce <namei>
    80004cf6:	84aa                	mv	s1,a0
    80004cf8:	c53d                	beqz	a0,80004d66 <sys_link+0xae>
  ilock(ip);
    80004cfa:	cbefe0ef          	jal	800031b8 <ilock>
  if (ip->type == T_DIR) {
    80004cfe:	04449703          	lh	a4,68(s1)
    80004d02:	4785                	li	a5,1
    80004d04:	06f70663          	beq	a4,a5,80004d70 <sys_link+0xb8>
    80004d08:	ea4a                	sd	s2,272(sp)
  ip->nlink++;
    80004d0a:	04a4d783          	lhu	a5,74(s1)
    80004d0e:	2785                	addiw	a5,a5,1
    80004d10:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80004d14:	8526                	mv	a0,s1
    80004d16:	beefe0ef          	jal	80003104 <iupdate>
  iunlock(ip);
    80004d1a:	8526                	mv	a0,s1
    80004d1c:	d4afe0ef          	jal	80003266 <iunlock>
  if ((dp = nameiparent(new, name)) == 0)
    80004d20:	fd040593          	addi	a1,s0,-48
    80004d24:	f5040513          	addi	a0,s0,-176
    80004d28:	cc1fe0ef          	jal	800039e8 <nameiparent>
    80004d2c:	892a                	mv	s2,a0
    80004d2e:	cd21                	beqz	a0,80004d86 <sys_link+0xce>
  ilock(dp);
    80004d30:	c88fe0ef          	jal	800031b8 <ilock>
  if (dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0) {
    80004d34:	00092703          	lw	a4,0(s2)
    80004d38:	409c                	lw	a5,0(s1)
    80004d3a:	04f71363          	bne	a4,a5,80004d80 <sys_link+0xc8>
    80004d3e:	40d0                	lw	a2,4(s1)
    80004d40:	fd040593          	addi	a1,s0,-48
    80004d44:	854a                	mv	a0,s2
    80004d46:	beffe0ef          	jal	80003934 <dirlink>
    80004d4a:	02054b63          	bltz	a0,80004d80 <sys_link+0xc8>
  iunlockput(dp);
    80004d4e:	854a                	mv	a0,s2
    80004d50:	e72fe0ef          	jal	800033c2 <iunlockput>
  iput(ip);
    80004d54:	8526                	mv	a0,s1
    80004d56:	de4fe0ef          	jal	8000333a <iput>
  end_op();
    80004d5a:	eb3fe0ef          	jal	80003c0c <end_op>
  return 0;
    80004d5e:	4781                	li	a5,0
    80004d60:	64f2                	ld	s1,280(sp)
    80004d62:	6952                	ld	s2,272(sp)
    80004d64:	a0a1                	j	80004dac <sys_link+0xf4>
    end_op();
    80004d66:	ea7fe0ef          	jal	80003c0c <end_op>
    return -1;
    80004d6a:	57fd                	li	a5,-1
    80004d6c:	64f2                	ld	s1,280(sp)
    80004d6e:	a83d                	j	80004dac <sys_link+0xf4>
    iunlockput(ip);
    80004d70:	8526                	mv	a0,s1
    80004d72:	e50fe0ef          	jal	800033c2 <iunlockput>
    end_op();
    80004d76:	e97fe0ef          	jal	80003c0c <end_op>
    return -1;
    80004d7a:	57fd                	li	a5,-1
    80004d7c:	64f2                	ld	s1,280(sp)
    80004d7e:	a03d                	j	80004dac <sys_link+0xf4>
    iunlockput(dp);
    80004d80:	854a                	mv	a0,s2
    80004d82:	e40fe0ef          	jal	800033c2 <iunlockput>
  ilock(ip);
    80004d86:	8526                	mv	a0,s1
    80004d88:	c30fe0ef          	jal	800031b8 <ilock>
  ip->nlink--;
    80004d8c:	04a4d783          	lhu	a5,74(s1)
    80004d90:	37fd                	addiw	a5,a5,-1
    80004d92:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80004d96:	8526                	mv	a0,s1
    80004d98:	b6cfe0ef          	jal	80003104 <iupdate>
  iunlockput(ip);
    80004d9c:	8526                	mv	a0,s1
    80004d9e:	e24fe0ef          	jal	800033c2 <iunlockput>
  end_op();
    80004da2:	e6bfe0ef          	jal	80003c0c <end_op>
  return -1;
    80004da6:	57fd                	li	a5,-1
    80004da8:	64f2                	ld	s1,280(sp)
    80004daa:	6952                	ld	s2,272(sp)
}
    80004dac:	853e                	mv	a0,a5
    80004dae:	70b2                	ld	ra,296(sp)
    80004db0:	7412                	ld	s0,288(sp)
    80004db2:	6155                	addi	sp,sp,304
    80004db4:	8082                	ret

0000000080004db6 <sys_unlink>:
{
    80004db6:	7151                	addi	sp,sp,-240
    80004db8:	f586                	sd	ra,232(sp)
    80004dba:	f1a2                	sd	s0,224(sp)
    80004dbc:	1980                	addi	s0,sp,240
  if (argstr(0, path, MAXPATH) < 0)
    80004dbe:	08000613          	li	a2,128
    80004dc2:	f3040593          	addi	a1,s0,-208
    80004dc6:	4501                	li	a0,0
    80004dc8:	a23fd0ef          	jal	800027ea <argstr>
    80004dcc:	16054063          	bltz	a0,80004f2c <sys_unlink+0x176>
    80004dd0:	eda6                	sd	s1,216(sp)
  begin_op();
    80004dd2:	dd1fe0ef          	jal	80003ba2 <begin_op>
  if ((dp = nameiparent(path, name)) == 0) {
    80004dd6:	fb040593          	addi	a1,s0,-80
    80004dda:	f3040513          	addi	a0,s0,-208
    80004dde:	c0bfe0ef          	jal	800039e8 <nameiparent>
    80004de2:	84aa                	mv	s1,a0
    80004de4:	c945                	beqz	a0,80004e94 <sys_unlink+0xde>
  ilock(dp);
    80004de6:	bd2fe0ef          	jal	800031b8 <ilock>
  if (namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    80004dea:	00002597          	auipc	a1,0x2
    80004dee:	7d658593          	addi	a1,a1,2006 # 800075c0 <etext+0x5c0>
    80004df2:	fb040513          	addi	a0,s0,-80
    80004df6:	95dfe0ef          	jal	80003752 <namecmp>
    80004dfa:	10050e63          	beqz	a0,80004f16 <sys_unlink+0x160>
    80004dfe:	00002597          	auipc	a1,0x2
    80004e02:	7ca58593          	addi	a1,a1,1994 # 800075c8 <etext+0x5c8>
    80004e06:	fb040513          	addi	a0,s0,-80
    80004e0a:	949fe0ef          	jal	80003752 <namecmp>
    80004e0e:	10050463          	beqz	a0,80004f16 <sys_unlink+0x160>
    80004e12:	e9ca                	sd	s2,208(sp)
  if ((ip = dirlookup(dp, name, &off)) == 0)
    80004e14:	f2c40613          	addi	a2,s0,-212
    80004e18:	fb040593          	addi	a1,s0,-80
    80004e1c:	8526                	mv	a0,s1
    80004e1e:	94bfe0ef          	jal	80003768 <dirlookup>
    80004e22:	892a                	mv	s2,a0
    80004e24:	0e050863          	beqz	a0,80004f14 <sys_unlink+0x15e>
  ilock(ip);
    80004e28:	b90fe0ef          	jal	800031b8 <ilock>
  if (ip->nlink < 1)
    80004e2c:	04a91783          	lh	a5,74(s2)
    80004e30:	06f05763          	blez	a5,80004e9e <sys_unlink+0xe8>
  if (ip->type == T_DIR && !isdirempty(ip)) {
    80004e34:	04491703          	lh	a4,68(s2)
    80004e38:	4785                	li	a5,1
    80004e3a:	06f70963          	beq	a4,a5,80004eac <sys_unlink+0xf6>
  memset(&de, 0, sizeof(de));
    80004e3e:	4641                	li	a2,16
    80004e40:	4581                	li	a1,0
    80004e42:	fc040513          	addi	a0,s0,-64
    80004e46:	e33fb0ef          	jal	80000c78 <memset>
  if (writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004e4a:	4741                	li	a4,16
    80004e4c:	f2c42683          	lw	a3,-212(s0)
    80004e50:	fc040613          	addi	a2,s0,-64
    80004e54:	4581                	li	a1,0
    80004e56:	8526                	mv	a0,s1
    80004e58:	fecfe0ef          	jal	80003644 <writei>
    80004e5c:	47c1                	li	a5,16
    80004e5e:	08f51b63          	bne	a0,a5,80004ef4 <sys_unlink+0x13e>
  if (ip->type == T_DIR) {
    80004e62:	04491703          	lh	a4,68(s2)
    80004e66:	4785                	li	a5,1
    80004e68:	08f70d63          	beq	a4,a5,80004f02 <sys_unlink+0x14c>
  iunlockput(dp);
    80004e6c:	8526                	mv	a0,s1
    80004e6e:	d54fe0ef          	jal	800033c2 <iunlockput>
  ip->nlink--;
    80004e72:	04a95783          	lhu	a5,74(s2)
    80004e76:	37fd                	addiw	a5,a5,-1
    80004e78:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    80004e7c:	854a                	mv	a0,s2
    80004e7e:	a86fe0ef          	jal	80003104 <iupdate>
  iunlockput(ip);
    80004e82:	854a                	mv	a0,s2
    80004e84:	d3efe0ef          	jal	800033c2 <iunlockput>
  end_op();
    80004e88:	d85fe0ef          	jal	80003c0c <end_op>
  return 0;
    80004e8c:	4501                	li	a0,0
    80004e8e:	64ee                	ld	s1,216(sp)
    80004e90:	694e                	ld	s2,208(sp)
    80004e92:	a849                	j	80004f24 <sys_unlink+0x16e>
    end_op();
    80004e94:	d79fe0ef          	jal	80003c0c <end_op>
    return -1;
    80004e98:	557d                	li	a0,-1
    80004e9a:	64ee                	ld	s1,216(sp)
    80004e9c:	a061                	j	80004f24 <sys_unlink+0x16e>
    80004e9e:	e5ce                	sd	s3,200(sp)
    panic("unlink: nlink < 1");
    80004ea0:	00002517          	auipc	a0,0x2
    80004ea4:	73050513          	addi	a0,a0,1840 # 800075d0 <etext+0x5d0>
    80004ea8:	92dfb0ef          	jal	800007d4 <panic>
  for (off = 2 * sizeof(de); off < dp->size; off += sizeof(de)) {
    80004eac:	04c92703          	lw	a4,76(s2)
    80004eb0:	02000793          	li	a5,32
    80004eb4:	f8e7f5e3          	bgeu	a5,a4,80004e3e <sys_unlink+0x88>
    80004eb8:	e5ce                	sd	s3,200(sp)
    80004eba:	02000993          	li	s3,32
    if (readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004ebe:	4741                	li	a4,16
    80004ec0:	86ce                	mv	a3,s3
    80004ec2:	f1840613          	addi	a2,s0,-232
    80004ec6:	4581                	li	a1,0
    80004ec8:	854a                	mv	a0,s2
    80004eca:	e7efe0ef          	jal	80003548 <readi>
    80004ece:	47c1                	li	a5,16
    80004ed0:	00f51c63          	bne	a0,a5,80004ee8 <sys_unlink+0x132>
    if (de.inum != 0)
    80004ed4:	f1845783          	lhu	a5,-232(s0)
    80004ed8:	efa1                	bnez	a5,80004f30 <sys_unlink+0x17a>
  for (off = 2 * sizeof(de); off < dp->size; off += sizeof(de)) {
    80004eda:	29c1                	addiw	s3,s3,16
    80004edc:	04c92783          	lw	a5,76(s2)
    80004ee0:	fcf9efe3          	bltu	s3,a5,80004ebe <sys_unlink+0x108>
    80004ee4:	69ae                	ld	s3,200(sp)
    80004ee6:	bfa1                	j	80004e3e <sys_unlink+0x88>
      panic("isdirempty: readi");
    80004ee8:	00002517          	auipc	a0,0x2
    80004eec:	70050513          	addi	a0,a0,1792 # 800075e8 <etext+0x5e8>
    80004ef0:	8e5fb0ef          	jal	800007d4 <panic>
    80004ef4:	e5ce                	sd	s3,200(sp)
    panic("unlink: writei");
    80004ef6:	00002517          	auipc	a0,0x2
    80004efa:	70a50513          	addi	a0,a0,1802 # 80007600 <etext+0x600>
    80004efe:	8d7fb0ef          	jal	800007d4 <panic>
    dp->nlink--;
    80004f02:	04a4d783          	lhu	a5,74(s1)
    80004f06:	37fd                	addiw	a5,a5,-1
    80004f08:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80004f0c:	8526                	mv	a0,s1
    80004f0e:	9f6fe0ef          	jal	80003104 <iupdate>
    80004f12:	bfa9                	j	80004e6c <sys_unlink+0xb6>
    80004f14:	694e                	ld	s2,208(sp)
  iunlockput(dp);
    80004f16:	8526                	mv	a0,s1
    80004f18:	caafe0ef          	jal	800033c2 <iunlockput>
  end_op();
    80004f1c:	cf1fe0ef          	jal	80003c0c <end_op>
  return -1;
    80004f20:	557d                	li	a0,-1
    80004f22:	64ee                	ld	s1,216(sp)
}
    80004f24:	70ae                	ld	ra,232(sp)
    80004f26:	740e                	ld	s0,224(sp)
    80004f28:	616d                	addi	sp,sp,240
    80004f2a:	8082                	ret
    return -1;
    80004f2c:	557d                	li	a0,-1
    80004f2e:	bfdd                	j	80004f24 <sys_unlink+0x16e>
    iunlockput(ip);
    80004f30:	854a                	mv	a0,s2
    80004f32:	c90fe0ef          	jal	800033c2 <iunlockput>
    goto bad;
    80004f36:	694e                	ld	s2,208(sp)
    80004f38:	69ae                	ld	s3,200(sp)
    80004f3a:	bff1                	j	80004f16 <sys_unlink+0x160>

0000000080004f3c <sys_open>:

uint64
sys_open(void)
{
    80004f3c:	7131                	addi	sp,sp,-192
    80004f3e:	fd06                	sd	ra,184(sp)
    80004f40:	f922                	sd	s0,176(sp)
    80004f42:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    80004f44:	f4c40593          	addi	a1,s0,-180
    80004f48:	4505                	li	a0,1
    80004f4a:	869fd0ef          	jal	800027b2 <argint>
  if ((n = argstr(0, path, MAXPATH)) < 0)
    80004f4e:	08000613          	li	a2,128
    80004f52:	f5040593          	addi	a1,s0,-176
    80004f56:	4501                	li	a0,0
    80004f58:	893fd0ef          	jal	800027ea <argstr>
    80004f5c:	87aa                	mv	a5,a0
    return -1;
    80004f5e:	557d                	li	a0,-1
  if ((n = argstr(0, path, MAXPATH)) < 0)
    80004f60:	0a07c263          	bltz	a5,80005004 <sys_open+0xc8>
    80004f64:	f526                	sd	s1,168(sp)

  begin_op();
    80004f66:	c3dfe0ef          	jal	80003ba2 <begin_op>

  if (omode & O_CREATE) {
    80004f6a:	f4c42783          	lw	a5,-180(s0)
    80004f6e:	2007f793          	andi	a5,a5,512
    80004f72:	c3d5                	beqz	a5,80005016 <sys_open+0xda>
    ip = create(path, T_FILE, 0, 0);
    80004f74:	4681                	li	a3,0
    80004f76:	4601                	li	a2,0
    80004f78:	4589                	li	a1,2
    80004f7a:	f5040513          	addi	a0,s0,-176
    80004f7e:	aa9ff0ef          	jal	80004a26 <create>
    80004f82:	84aa                	mv	s1,a0
    if (ip == 0) {
    80004f84:	c541                	beqz	a0,8000500c <sys_open+0xd0>
      end_op();
      return -1;
    }
  }

  if (ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)) {
    80004f86:	04449703          	lh	a4,68(s1)
    80004f8a:	478d                	li	a5,3
    80004f8c:	00f71763          	bne	a4,a5,80004f9a <sys_open+0x5e>
    80004f90:	0464d703          	lhu	a4,70(s1)
    80004f94:	47a5                	li	a5,9
    80004f96:	0ae7ed63          	bltu	a5,a4,80005050 <sys_open+0x114>
    80004f9a:	f14a                	sd	s2,160(sp)
    iunlockput(ip);
    end_op();
    return -1;
  }

  if ((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0) {
    80004f9c:	fd7fe0ef          	jal	80003f72 <filealloc>
    80004fa0:	892a                	mv	s2,a0
    80004fa2:	c179                	beqz	a0,80005068 <sys_open+0x12c>
    80004fa4:	ed4e                	sd	s3,152(sp)
    80004fa6:	a43ff0ef          	jal	800049e8 <fdalloc>
    80004faa:	89aa                	mv	s3,a0
    80004fac:	0a054a63          	bltz	a0,80005060 <sys_open+0x124>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if (ip->type == T_DEVICE) {
    80004fb0:	04449703          	lh	a4,68(s1)
    80004fb4:	478d                	li	a5,3
    80004fb6:	0cf70263          	beq	a4,a5,8000507a <sys_open+0x13e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    80004fba:	4789                	li	a5,2
    80004fbc:	00f92023          	sw	a5,0(s2)
    f->off = 0;
    80004fc0:	02092023          	sw	zero,32(s2)
  }
  f->ip = ip;
    80004fc4:	00993c23          	sd	s1,24(s2)
  f->readable = !(omode & O_WRONLY);
    80004fc8:	f4c42783          	lw	a5,-180(s0)
    80004fcc:	0017c713          	xori	a4,a5,1
    80004fd0:	8b05                	andi	a4,a4,1
    80004fd2:	00e90423          	sb	a4,8(s2)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80004fd6:	0037f713          	andi	a4,a5,3
    80004fda:	00e03733          	snez	a4,a4
    80004fde:	00e904a3          	sb	a4,9(s2)

  if ((omode & O_TRUNC) && ip->type == T_FILE) {
    80004fe2:	4007f793          	andi	a5,a5,1024
    80004fe6:	c791                	beqz	a5,80004ff2 <sys_open+0xb6>
    80004fe8:	04449703          	lh	a4,68(s1)
    80004fec:	4789                	li	a5,2
    80004fee:	08f70d63          	beq	a4,a5,80005088 <sys_open+0x14c>
    itrunc(ip);
  }

  iunlock(ip);
    80004ff2:	8526                	mv	a0,s1
    80004ff4:	a72fe0ef          	jal	80003266 <iunlock>
  end_op();
    80004ff8:	c15fe0ef          	jal	80003c0c <end_op>

  return fd;
    80004ffc:	854e                	mv	a0,s3
    80004ffe:	74aa                	ld	s1,168(sp)
    80005000:	790a                	ld	s2,160(sp)
    80005002:	69ea                	ld	s3,152(sp)
}
    80005004:	70ea                	ld	ra,184(sp)
    80005006:	744a                	ld	s0,176(sp)
    80005008:	6129                	addi	sp,sp,192
    8000500a:	8082                	ret
      end_op();
    8000500c:	c01fe0ef          	jal	80003c0c <end_op>
      return -1;
    80005010:	557d                	li	a0,-1
    80005012:	74aa                	ld	s1,168(sp)
    80005014:	bfc5                	j	80005004 <sys_open+0xc8>
    if ((ip = namei(path)) == 0) {
    80005016:	f5040513          	addi	a0,s0,-176
    8000501a:	9b5fe0ef          	jal	800039ce <namei>
    8000501e:	84aa                	mv	s1,a0
    80005020:	c11d                	beqz	a0,80005046 <sys_open+0x10a>
    ilock(ip);
    80005022:	996fe0ef          	jal	800031b8 <ilock>
    if (ip->type == T_DIR && omode != O_RDONLY) {
    80005026:	04449703          	lh	a4,68(s1)
    8000502a:	4785                	li	a5,1
    8000502c:	f4f71de3          	bne	a4,a5,80004f86 <sys_open+0x4a>
    80005030:	f4c42783          	lw	a5,-180(s0)
    80005034:	d3bd                	beqz	a5,80004f9a <sys_open+0x5e>
      iunlockput(ip);
    80005036:	8526                	mv	a0,s1
    80005038:	b8afe0ef          	jal	800033c2 <iunlockput>
      end_op();
    8000503c:	bd1fe0ef          	jal	80003c0c <end_op>
      return -1;
    80005040:	557d                	li	a0,-1
    80005042:	74aa                	ld	s1,168(sp)
    80005044:	b7c1                	j	80005004 <sys_open+0xc8>
      end_op();
    80005046:	bc7fe0ef          	jal	80003c0c <end_op>
      return -1;
    8000504a:	557d                	li	a0,-1
    8000504c:	74aa                	ld	s1,168(sp)
    8000504e:	bf5d                	j	80005004 <sys_open+0xc8>
    iunlockput(ip);
    80005050:	8526                	mv	a0,s1
    80005052:	b70fe0ef          	jal	800033c2 <iunlockput>
    end_op();
    80005056:	bb7fe0ef          	jal	80003c0c <end_op>
    return -1;
    8000505a:	557d                	li	a0,-1
    8000505c:	74aa                	ld	s1,168(sp)
    8000505e:	b75d                	j	80005004 <sys_open+0xc8>
      fileclose(f);
    80005060:	854a                	mv	a0,s2
    80005062:	fb5fe0ef          	jal	80004016 <fileclose>
    80005066:	69ea                	ld	s3,152(sp)
    iunlockput(ip);
    80005068:	8526                	mv	a0,s1
    8000506a:	b58fe0ef          	jal	800033c2 <iunlockput>
    end_op();
    8000506e:	b9ffe0ef          	jal	80003c0c <end_op>
    return -1;
    80005072:	557d                	li	a0,-1
    80005074:	74aa                	ld	s1,168(sp)
    80005076:	790a                	ld	s2,160(sp)
    80005078:	b771                	j	80005004 <sys_open+0xc8>
    f->type = FD_DEVICE;
    8000507a:	00f92023          	sw	a5,0(s2)
    f->major = ip->major;
    8000507e:	04649783          	lh	a5,70(s1)
    80005082:	02f91223          	sh	a5,36(s2)
    80005086:	bf3d                	j	80004fc4 <sys_open+0x88>
    itrunc(ip);
    80005088:	8526                	mv	a0,s1
    8000508a:	a1cfe0ef          	jal	800032a6 <itrunc>
    8000508e:	b795                	j	80004ff2 <sys_open+0xb6>

0000000080005090 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80005090:	7175                	addi	sp,sp,-144
    80005092:	e506                	sd	ra,136(sp)
    80005094:	e122                	sd	s0,128(sp)
    80005096:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80005098:	b0bfe0ef          	jal	80003ba2 <begin_op>
  if (argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0) {
    8000509c:	08000613          	li	a2,128
    800050a0:	f7040593          	addi	a1,s0,-144
    800050a4:	4501                	li	a0,0
    800050a6:	f44fd0ef          	jal	800027ea <argstr>
    800050aa:	02054363          	bltz	a0,800050d0 <sys_mkdir+0x40>
    800050ae:	4681                	li	a3,0
    800050b0:	4601                	li	a2,0
    800050b2:	4585                	li	a1,1
    800050b4:	f7040513          	addi	a0,s0,-144
    800050b8:	96fff0ef          	jal	80004a26 <create>
    800050bc:	c911                	beqz	a0,800050d0 <sys_mkdir+0x40>
    end_op();
    return -1;
  }
  iunlockput(ip);
    800050be:	b04fe0ef          	jal	800033c2 <iunlockput>
  end_op();
    800050c2:	b4bfe0ef          	jal	80003c0c <end_op>
  return 0;
    800050c6:	4501                	li	a0,0
}
    800050c8:	60aa                	ld	ra,136(sp)
    800050ca:	640a                	ld	s0,128(sp)
    800050cc:	6149                	addi	sp,sp,144
    800050ce:	8082                	ret
    end_op();
    800050d0:	b3dfe0ef          	jal	80003c0c <end_op>
    return -1;
    800050d4:	557d                	li	a0,-1
    800050d6:	bfcd                	j	800050c8 <sys_mkdir+0x38>

00000000800050d8 <sys_mknod>:

uint64
sys_mknod(void)
{
    800050d8:	7135                	addi	sp,sp,-160
    800050da:	ed06                	sd	ra,152(sp)
    800050dc:	e922                	sd	s0,144(sp)
    800050de:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    800050e0:	ac3fe0ef          	jal	80003ba2 <begin_op>
  argint(1, &major);
    800050e4:	f6c40593          	addi	a1,s0,-148
    800050e8:	4505                	li	a0,1
    800050ea:	ec8fd0ef          	jal	800027b2 <argint>
  argint(2, &minor);
    800050ee:	f6840593          	addi	a1,s0,-152
    800050f2:	4509                	li	a0,2
    800050f4:	ebefd0ef          	jal	800027b2 <argint>
  if ((argstr(0, path, MAXPATH)) < 0 ||
    800050f8:	08000613          	li	a2,128
    800050fc:	f7040593          	addi	a1,s0,-144
    80005100:	4501                	li	a0,0
    80005102:	ee8fd0ef          	jal	800027ea <argstr>
    80005106:	02054563          	bltz	a0,80005130 <sys_mknod+0x58>
      (ip = create(path, T_DEVICE, major, minor)) == 0) {
    8000510a:	f6841683          	lh	a3,-152(s0)
    8000510e:	f6c41603          	lh	a2,-148(s0)
    80005112:	458d                	li	a1,3
    80005114:	f7040513          	addi	a0,s0,-144
    80005118:	90fff0ef          	jal	80004a26 <create>
  if ((argstr(0, path, MAXPATH)) < 0 ||
    8000511c:	c911                	beqz	a0,80005130 <sys_mknod+0x58>
    end_op();
    return -1;
  }
  iunlockput(ip);
    8000511e:	aa4fe0ef          	jal	800033c2 <iunlockput>
  end_op();
    80005122:	aebfe0ef          	jal	80003c0c <end_op>
  return 0;
    80005126:	4501                	li	a0,0
}
    80005128:	60ea                	ld	ra,152(sp)
    8000512a:	644a                	ld	s0,144(sp)
    8000512c:	610d                	addi	sp,sp,160
    8000512e:	8082                	ret
    end_op();
    80005130:	addfe0ef          	jal	80003c0c <end_op>
    return -1;
    80005134:	557d                	li	a0,-1
    80005136:	bfcd                	j	80005128 <sys_mknod+0x50>

0000000080005138 <sys_chdir>:

uint64
sys_chdir(void)
{
    80005138:	7135                	addi	sp,sp,-160
    8000513a:	ed06                	sd	ra,152(sp)
    8000513c:	e922                	sd	s0,144(sp)
    8000513e:	e14a                	sd	s2,128(sp)
    80005140:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80005142:	f62fc0ef          	jal	800018a4 <myproc>
    80005146:	892a                	mv	s2,a0

  begin_op();
    80005148:	a5bfe0ef          	jal	80003ba2 <begin_op>
  if (argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0) {
    8000514c:	08000613          	li	a2,128
    80005150:	f6040593          	addi	a1,s0,-160
    80005154:	4501                	li	a0,0
    80005156:	e94fd0ef          	jal	800027ea <argstr>
    8000515a:	04054363          	bltz	a0,800051a0 <sys_chdir+0x68>
    8000515e:	e526                	sd	s1,136(sp)
    80005160:	f6040513          	addi	a0,s0,-160
    80005164:	86bfe0ef          	jal	800039ce <namei>
    80005168:	84aa                	mv	s1,a0
    8000516a:	c915                	beqz	a0,8000519e <sys_chdir+0x66>
    end_op();
    return -1;
  }
  ilock(ip);
    8000516c:	84cfe0ef          	jal	800031b8 <ilock>
  if (ip->type != T_DIR) {
    80005170:	04449703          	lh	a4,68(s1)
    80005174:	4785                	li	a5,1
    80005176:	02f71963          	bne	a4,a5,800051a8 <sys_chdir+0x70>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    8000517a:	8526                	mv	a0,s1
    8000517c:	8eafe0ef          	jal	80003266 <iunlock>
  iput(p->cwd);
    80005180:	15093503          	ld	a0,336(s2)
    80005184:	9b6fe0ef          	jal	8000333a <iput>
  end_op();
    80005188:	a85fe0ef          	jal	80003c0c <end_op>
  p->cwd = ip;
    8000518c:	14993823          	sd	s1,336(s2)
  return 0;
    80005190:	4501                	li	a0,0
    80005192:	64aa                	ld	s1,136(sp)
}
    80005194:	60ea                	ld	ra,152(sp)
    80005196:	644a                	ld	s0,144(sp)
    80005198:	690a                	ld	s2,128(sp)
    8000519a:	610d                	addi	sp,sp,160
    8000519c:	8082                	ret
    8000519e:	64aa                	ld	s1,136(sp)
    end_op();
    800051a0:	a6dfe0ef          	jal	80003c0c <end_op>
    return -1;
    800051a4:	557d                	li	a0,-1
    800051a6:	b7fd                	j	80005194 <sys_chdir+0x5c>
    iunlockput(ip);
    800051a8:	8526                	mv	a0,s1
    800051aa:	a18fe0ef          	jal	800033c2 <iunlockput>
    end_op();
    800051ae:	a5ffe0ef          	jal	80003c0c <end_op>
    return -1;
    800051b2:	557d                	li	a0,-1
    800051b4:	64aa                	ld	s1,136(sp)
    800051b6:	bff9                	j	80005194 <sys_chdir+0x5c>

00000000800051b8 <sys_exec>:

uint64
sys_exec(void)
{
    800051b8:	7121                	addi	sp,sp,-448
    800051ba:	ff06                	sd	ra,440(sp)
    800051bc:	fb22                	sd	s0,432(sp)
    800051be:	0380                	addi	s0,sp,448
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    800051c0:	e4840593          	addi	a1,s0,-440
    800051c4:	4505                	li	a0,1
    800051c6:	e08fd0ef          	jal	800027ce <argaddr>
  if (argstr(0, path, MAXPATH) < 0) {
    800051ca:	08000613          	li	a2,128
    800051ce:	f5040593          	addi	a1,s0,-176
    800051d2:	4501                	li	a0,0
    800051d4:	e16fd0ef          	jal	800027ea <argstr>
    800051d8:	87aa                	mv	a5,a0
    return -1;
    800051da:	557d                	li	a0,-1
  if (argstr(0, path, MAXPATH) < 0) {
    800051dc:	0c07c463          	bltz	a5,800052a4 <sys_exec+0xec>
    800051e0:	f726                	sd	s1,424(sp)
    800051e2:	f34a                	sd	s2,416(sp)
    800051e4:	ef4e                	sd	s3,408(sp)
    800051e6:	eb52                	sd	s4,400(sp)
  }
  memset(argv, 0, sizeof(argv));
    800051e8:	10000613          	li	a2,256
    800051ec:	4581                	li	a1,0
    800051ee:	e5040513          	addi	a0,s0,-432
    800051f2:	a87fb0ef          	jal	80000c78 <memset>
  for (i = 0;; i++) {
    if (i >= NELEM(argv)) {
    800051f6:	e5040493          	addi	s1,s0,-432
  memset(argv, 0, sizeof(argv));
    800051fa:	89a6                	mv	s3,s1
    800051fc:	4901                	li	s2,0
    if (i >= NELEM(argv)) {
    800051fe:	02000a13          	li	s4,32
      goto bad;
    }
    if (fetchaddr(uargv + sizeof(uint64) * i, (uint64 *)&uarg) < 0) {
    80005202:	00391513          	slli	a0,s2,0x3
    80005206:	e4040593          	addi	a1,s0,-448
    8000520a:	e4843783          	ld	a5,-440(s0)
    8000520e:	953e                	add	a0,a0,a5
    80005210:	d18fd0ef          	jal	80002728 <fetchaddr>
    80005214:	02054663          	bltz	a0,80005240 <sys_exec+0x88>
      goto bad;
    }
    if (uarg == 0) {
    80005218:	e4043783          	ld	a5,-448(s0)
    8000521c:	c3a9                	beqz	a5,8000525e <sys_exec+0xa6>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    8000521e:	8bffb0ef          	jal	80000adc <kalloc>
    80005222:	85aa                	mv	a1,a0
    80005224:	00a9b023          	sd	a0,0(s3)
    if (argv[i] == 0)
    80005228:	cd01                	beqz	a0,80005240 <sys_exec+0x88>
      goto bad;
    if (fetchstr(uarg, argv[i], PGSIZE) < 0)
    8000522a:	6605                	lui	a2,0x1
    8000522c:	e4043503          	ld	a0,-448(s0)
    80005230:	d42fd0ef          	jal	80002772 <fetchstr>
    80005234:	00054663          	bltz	a0,80005240 <sys_exec+0x88>
    if (i >= NELEM(argv)) {
    80005238:	0905                	addi	s2,s2,1
    8000523a:	09a1                	addi	s3,s3,8
    8000523c:	fd4913e3          	bne	s2,s4,80005202 <sys_exec+0x4a>
    kfree(argv[i]);

  return ret;

bad:
  for (i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005240:	f5040913          	addi	s2,s0,-176
    80005244:	6088                	ld	a0,0(s1)
    80005246:	c931                	beqz	a0,8000529a <sys_exec+0xe2>
    kfree(argv[i]);
    80005248:	fb2fb0ef          	jal	800009fa <kfree>
  for (i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    8000524c:	04a1                	addi	s1,s1,8
    8000524e:	ff249be3          	bne	s1,s2,80005244 <sys_exec+0x8c>
  return -1;
    80005252:	557d                	li	a0,-1
    80005254:	74ba                	ld	s1,424(sp)
    80005256:	791a                	ld	s2,416(sp)
    80005258:	69fa                	ld	s3,408(sp)
    8000525a:	6a5a                	ld	s4,400(sp)
    8000525c:	a0a1                	j	800052a4 <sys_exec+0xec>
      argv[i] = 0;
    8000525e:	0009079b          	sext.w	a5,s2
    80005262:	078e                	slli	a5,a5,0x3
    80005264:	fd078793          	addi	a5,a5,-48
    80005268:	97a2                	add	a5,a5,s0
    8000526a:	e807b023          	sd	zero,-384(a5)
  int ret = kexec(path, argv);
    8000526e:	e5040593          	addi	a1,s0,-432
    80005272:	f5040513          	addi	a0,s0,-176
    80005276:	ba8ff0ef          	jal	8000461e <kexec>
    8000527a:	892a                	mv	s2,a0
  for (i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    8000527c:	f5040993          	addi	s3,s0,-176
    80005280:	6088                	ld	a0,0(s1)
    80005282:	c511                	beqz	a0,8000528e <sys_exec+0xd6>
    kfree(argv[i]);
    80005284:	f76fb0ef          	jal	800009fa <kfree>
  for (i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005288:	04a1                	addi	s1,s1,8
    8000528a:	ff349be3          	bne	s1,s3,80005280 <sys_exec+0xc8>
  return ret;
    8000528e:	854a                	mv	a0,s2
    80005290:	74ba                	ld	s1,424(sp)
    80005292:	791a                	ld	s2,416(sp)
    80005294:	69fa                	ld	s3,408(sp)
    80005296:	6a5a                	ld	s4,400(sp)
    80005298:	a031                	j	800052a4 <sys_exec+0xec>
  return -1;
    8000529a:	557d                	li	a0,-1
    8000529c:	74ba                	ld	s1,424(sp)
    8000529e:	791a                	ld	s2,416(sp)
    800052a0:	69fa                	ld	s3,408(sp)
    800052a2:	6a5a                	ld	s4,400(sp)
}
    800052a4:	70fa                	ld	ra,440(sp)
    800052a6:	745a                	ld	s0,432(sp)
    800052a8:	6139                	addi	sp,sp,448
    800052aa:	8082                	ret

00000000800052ac <sys_pipe>:

uint64
sys_pipe(void)
{
    800052ac:	7139                	addi	sp,sp,-64
    800052ae:	fc06                	sd	ra,56(sp)
    800052b0:	f822                	sd	s0,48(sp)
    800052b2:	f426                	sd	s1,40(sp)
    800052b4:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    800052b6:	deefc0ef          	jal	800018a4 <myproc>
    800052ba:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    800052bc:	fd840593          	addi	a1,s0,-40
    800052c0:	4501                	li	a0,0
    800052c2:	d0cfd0ef          	jal	800027ce <argaddr>
  if (pipealloc(&rf, &wf) < 0)
    800052c6:	fc840593          	addi	a1,s0,-56
    800052ca:	fd040513          	addi	a0,s0,-48
    800052ce:	852ff0ef          	jal	80004320 <pipealloc>
    return -1;
    800052d2:	57fd                	li	a5,-1
  if (pipealloc(&rf, &wf) < 0)
    800052d4:	0a054463          	bltz	a0,8000537c <sys_pipe+0xd0>
  fd0 = -1;
    800052d8:	fcf42223          	sw	a5,-60(s0)
  if ((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0) {
    800052dc:	fd043503          	ld	a0,-48(s0)
    800052e0:	f08ff0ef          	jal	800049e8 <fdalloc>
    800052e4:	fca42223          	sw	a0,-60(s0)
    800052e8:	08054163          	bltz	a0,8000536a <sys_pipe+0xbe>
    800052ec:	fc843503          	ld	a0,-56(s0)
    800052f0:	ef8ff0ef          	jal	800049e8 <fdalloc>
    800052f4:	fca42023          	sw	a0,-64(s0)
    800052f8:	06054063          	bltz	a0,80005358 <sys_pipe+0xac>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if (copyout(p->pagetable, fdarray, (char *)&fd0, sizeof(fd0)) < 0 ||
    800052fc:	4691                	li	a3,4
    800052fe:	fc440613          	addi	a2,s0,-60
    80005302:	fd843583          	ld	a1,-40(s0)
    80005306:	68a8                	ld	a0,80(s1)
    80005308:	ab0fc0ef          	jal	800015b8 <copyout>
    8000530c:	00054e63          	bltz	a0,80005328 <sys_pipe+0x7c>
      copyout(p->pagetable, fdarray + sizeof(fd0), (char *)&fd1, sizeof(fd1)) <
    80005310:	4691                	li	a3,4
    80005312:	fc040613          	addi	a2,s0,-64
    80005316:	fd843583          	ld	a1,-40(s0)
    8000531a:	0591                	addi	a1,a1,4
    8000531c:	68a8                	ld	a0,80(s1)
    8000531e:	a9afc0ef          	jal	800015b8 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80005322:	4781                	li	a5,0
  if (copyout(p->pagetable, fdarray, (char *)&fd0, sizeof(fd0)) < 0 ||
    80005324:	04055c63          	bgez	a0,8000537c <sys_pipe+0xd0>
    p->ofile[fd0] = 0;
    80005328:	fc442783          	lw	a5,-60(s0)
    8000532c:	07e9                	addi	a5,a5,26
    8000532e:	078e                	slli	a5,a5,0x3
    80005330:	97a6                	add	a5,a5,s1
    80005332:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    80005336:	fc042783          	lw	a5,-64(s0)
    8000533a:	07e9                	addi	a5,a5,26
    8000533c:	078e                	slli	a5,a5,0x3
    8000533e:	94be                	add	s1,s1,a5
    80005340:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    80005344:	fd043503          	ld	a0,-48(s0)
    80005348:	ccffe0ef          	jal	80004016 <fileclose>
    fileclose(wf);
    8000534c:	fc843503          	ld	a0,-56(s0)
    80005350:	cc7fe0ef          	jal	80004016 <fileclose>
    return -1;
    80005354:	57fd                	li	a5,-1
    80005356:	a01d                	j	8000537c <sys_pipe+0xd0>
    if (fd0 >= 0)
    80005358:	fc442783          	lw	a5,-60(s0)
    8000535c:	0007c763          	bltz	a5,8000536a <sys_pipe+0xbe>
      p->ofile[fd0] = 0;
    80005360:	07e9                	addi	a5,a5,26
    80005362:	078e                	slli	a5,a5,0x3
    80005364:	97a6                	add	a5,a5,s1
    80005366:	0007b023          	sd	zero,0(a5)
    fileclose(rf);
    8000536a:	fd043503          	ld	a0,-48(s0)
    8000536e:	ca9fe0ef          	jal	80004016 <fileclose>
    fileclose(wf);
    80005372:	fc843503          	ld	a0,-56(s0)
    80005376:	ca1fe0ef          	jal	80004016 <fileclose>
    return -1;
    8000537a:	57fd                	li	a5,-1
}
    8000537c:	853e                	mv	a0,a5
    8000537e:	70e2                	ld	ra,56(sp)
    80005380:	7442                	ld	s0,48(sp)
    80005382:	74a2                	ld	s1,40(sp)
    80005384:	6121                	addi	sp,sp,64
    80005386:	8082                	ret
	...

0000000080005390 <kernelvec>:
.globl kerneltrap
.globl kernelvec
.align 4
kernelvec:
        # make room to save registers.
        addi sp, sp, -256
    80005390:	7111                	addi	sp,sp,-256

        # save caller-saved registers.
        sd ra, 0(sp)
    80005392:	e006                	sd	ra,0(sp)
        # sd sp, 8(sp)
        sd gp, 16(sp)
    80005394:	e80e                	sd	gp,16(sp)
        # sd tp, 24(sp)
        sd t0, 32(sp)
    80005396:	f016                	sd	t0,32(sp)
        sd t1, 40(sp)
    80005398:	f41a                	sd	t1,40(sp)
        sd t2, 48(sp)
    8000539a:	f81e                	sd	t2,48(sp)
        sd a0, 72(sp)
    8000539c:	e4aa                	sd	a0,72(sp)
        sd a1, 80(sp)
    8000539e:	e8ae                	sd	a1,80(sp)
        sd a2, 88(sp)
    800053a0:	ecb2                	sd	a2,88(sp)
        sd a3, 96(sp)
    800053a2:	f0b6                	sd	a3,96(sp)
        sd a4, 104(sp)
    800053a4:	f4ba                	sd	a4,104(sp)
        sd a5, 112(sp)
    800053a6:	f8be                	sd	a5,112(sp)
        sd a6, 120(sp)
    800053a8:	fcc2                	sd	a6,120(sp)
        sd a7, 128(sp)
    800053aa:	e146                	sd	a7,128(sp)
        sd t3, 216(sp)
    800053ac:	edf2                	sd	t3,216(sp)
        sd t4, 224(sp)
    800053ae:	f1f6                	sd	t4,224(sp)
        sd t5, 232(sp)
    800053b0:	f5fa                	sd	t5,232(sp)
        sd t6, 240(sp)
    800053b2:	f9fe                	sd	t6,240(sp)

        # call the C trap handler in trap.c
        call kerneltrap
    800053b4:	a84fd0ef          	jal	80002638 <kerneltrap>

        # restore registers.
        ld ra, 0(sp)
    800053b8:	6082                	ld	ra,0(sp)
        # ld sp, 8(sp)
        ld gp, 16(sp)
    800053ba:	61c2                	ld	gp,16(sp)
        # not tp (contains hartid), in case we moved CPUs
        ld t0, 32(sp)
    800053bc:	7282                	ld	t0,32(sp)
        ld t1, 40(sp)
    800053be:	7322                	ld	t1,40(sp)
        ld t2, 48(sp)
    800053c0:	73c2                	ld	t2,48(sp)
        ld a0, 72(sp)
    800053c2:	6526                	ld	a0,72(sp)
        ld a1, 80(sp)
    800053c4:	65c6                	ld	a1,80(sp)
        ld a2, 88(sp)
    800053c6:	6666                	ld	a2,88(sp)
        ld a3, 96(sp)
    800053c8:	7686                	ld	a3,96(sp)
        ld a4, 104(sp)
    800053ca:	7726                	ld	a4,104(sp)
        ld a5, 112(sp)
    800053cc:	77c6                	ld	a5,112(sp)
        ld a6, 120(sp)
    800053ce:	7866                	ld	a6,120(sp)
        ld a7, 128(sp)
    800053d0:	688a                	ld	a7,128(sp)
        ld t3, 216(sp)
    800053d2:	6e6e                	ld	t3,216(sp)
        ld t4, 224(sp)
    800053d4:	7e8e                	ld	t4,224(sp)
        ld t5, 232(sp)
    800053d6:	7f2e                	ld	t5,232(sp)
        ld t6, 240(sp)
    800053d8:	7fce                	ld	t6,240(sp)

        addi sp, sp, 256
    800053da:	6111                	addi	sp,sp,256

        # return to whatever we were doing in the kernel.
        sret
    800053dc:	10200073          	sret
	...

00000000800053ee <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    800053ee:	1141                	addi	sp,sp,-16
    800053f0:	e422                	sd	s0,8(sp)
    800053f2:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32 *)(PLIC + UART0_IRQ * 4) = 1;
    800053f4:	0c0007b7          	lui	a5,0xc000
    800053f8:	4705                	li	a4,1
    800053fa:	d798                	sw	a4,40(a5)
  *(uint32 *)(PLIC + VIRTIO0_IRQ * 4) = 1;
    800053fc:	0c0007b7          	lui	a5,0xc000
    80005400:	c3d8                	sw	a4,4(a5)
}
    80005402:	6422                	ld	s0,8(sp)
    80005404:	0141                	addi	sp,sp,16
    80005406:	8082                	ret

0000000080005408 <plicinithart>:

void
plicinithart(void)
{
    80005408:	1141                	addi	sp,sp,-16
    8000540a:	e406                	sd	ra,8(sp)
    8000540c:	e022                	sd	s0,0(sp)
    8000540e:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005410:	c68fc0ef          	jal	80001878 <cpuid>

  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32 *)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80005414:	0085171b          	slliw	a4,a0,0x8
    80005418:	0c0027b7          	lui	a5,0xc002
    8000541c:	97ba                	add	a5,a5,a4
    8000541e:	40200713          	li	a4,1026
    80005422:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32 *)PLIC_SPRIORITY(hart) = 0;
    80005426:	00d5151b          	slliw	a0,a0,0xd
    8000542a:	0c2017b7          	lui	a5,0xc201
    8000542e:	97aa                	add	a5,a5,a0
    80005430:	0007a023          	sw	zero,0(a5) # c201000 <_entry-0x73dff000>
}
    80005434:	60a2                	ld	ra,8(sp)
    80005436:	6402                	ld	s0,0(sp)
    80005438:	0141                	addi	sp,sp,16
    8000543a:	8082                	ret

000000008000543c <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    8000543c:	1141                	addi	sp,sp,-16
    8000543e:	e406                	sd	ra,8(sp)
    80005440:	e022                	sd	s0,0(sp)
    80005442:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005444:	c34fc0ef          	jal	80001878 <cpuid>
  int irq = *(uint32 *)PLIC_SCLAIM(hart);
    80005448:	00d5151b          	slliw	a0,a0,0xd
    8000544c:	0c2017b7          	lui	a5,0xc201
    80005450:	97aa                	add	a5,a5,a0
  return irq;
}
    80005452:	43c8                	lw	a0,4(a5)
    80005454:	60a2                	ld	ra,8(sp)
    80005456:	6402                	ld	s0,0(sp)
    80005458:	0141                	addi	sp,sp,16
    8000545a:	8082                	ret

000000008000545c <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    8000545c:	1101                	addi	sp,sp,-32
    8000545e:	ec06                	sd	ra,24(sp)
    80005460:	e822                	sd	s0,16(sp)
    80005462:	e426                	sd	s1,8(sp)
    80005464:	1000                	addi	s0,sp,32
    80005466:	84aa                	mv	s1,a0
  int hart = cpuid();
    80005468:	c10fc0ef          	jal	80001878 <cpuid>
  *(uint32 *)PLIC_SCLAIM(hart) = irq;
    8000546c:	00d5151b          	slliw	a0,a0,0xd
    80005470:	0c2017b7          	lui	a5,0xc201
    80005474:	97aa                	add	a5,a5,a0
    80005476:	c3c4                	sw	s1,4(a5)
}
    80005478:	60e2                	ld	ra,24(sp)
    8000547a:	6442                	ld	s0,16(sp)
    8000547c:	64a2                	ld	s1,8(sp)
    8000547e:	6105                	addi	sp,sp,32
    80005480:	8082                	ret

0000000080005482 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80005482:	1141                	addi	sp,sp,-16
    80005484:	e406                	sd	ra,8(sp)
    80005486:	e022                	sd	s0,0(sp)
    80005488:	0800                	addi	s0,sp,16
  if (i >= NUM)
    8000548a:	479d                	li	a5,7
    8000548c:	04a7ca63          	blt	a5,a0,800054e0 <free_desc+0x5e>
    panic("free_desc 1");
  if (disk.free[i])
    80005490:	0001e797          	auipc	a5,0x1e
    80005494:	f0878793          	addi	a5,a5,-248 # 80023398 <disk>
    80005498:	97aa                	add	a5,a5,a0
    8000549a:	0187c783          	lbu	a5,24(a5)
    8000549e:	e7b9                	bnez	a5,800054ec <free_desc+0x6a>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    800054a0:	00451693          	slli	a3,a0,0x4
    800054a4:	0001e797          	auipc	a5,0x1e
    800054a8:	ef478793          	addi	a5,a5,-268 # 80023398 <disk>
    800054ac:	6398                	ld	a4,0(a5)
    800054ae:	9736                	add	a4,a4,a3
    800054b0:	00073023          	sd	zero,0(a4)
  disk.desc[i].len = 0;
    800054b4:	6398                	ld	a4,0(a5)
    800054b6:	9736                	add	a4,a4,a3
    800054b8:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    800054bc:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    800054c0:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    800054c4:	97aa                	add	a5,a5,a0
    800054c6:	4705                	li	a4,1
    800054c8:	00e78c23          	sb	a4,24(a5)
  wakeup(&disk.free[0]);
    800054cc:	0001e517          	auipc	a0,0x1e
    800054d0:	ee450513          	addi	a0,a0,-284 # 800233b0 <disk+0x18>
    800054d4:	a27fc0ef          	jal	80001efa <wakeup>
}
    800054d8:	60a2                	ld	ra,8(sp)
    800054da:	6402                	ld	s0,0(sp)
    800054dc:	0141                	addi	sp,sp,16
    800054de:	8082                	ret
    panic("free_desc 1");
    800054e0:	00002517          	auipc	a0,0x2
    800054e4:	13050513          	addi	a0,a0,304 # 80007610 <etext+0x610>
    800054e8:	aecfb0ef          	jal	800007d4 <panic>
    panic("free_desc 2");
    800054ec:	00002517          	auipc	a0,0x2
    800054f0:	13450513          	addi	a0,a0,308 # 80007620 <etext+0x620>
    800054f4:	ae0fb0ef          	jal	800007d4 <panic>

00000000800054f8 <virtio_disk_init>:
{
    800054f8:	1101                	addi	sp,sp,-32
    800054fa:	ec06                	sd	ra,24(sp)
    800054fc:	e822                	sd	s0,16(sp)
    800054fe:	e426                	sd	s1,8(sp)
    80005500:	e04a                	sd	s2,0(sp)
    80005502:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80005504:	00002597          	auipc	a1,0x2
    80005508:	12c58593          	addi	a1,a1,300 # 80007630 <etext+0x630>
    8000550c:	0001e517          	auipc	a0,0x1e
    80005510:	fb450513          	addi	a0,a0,-76 # 800234c0 <disk+0x128>
    80005514:	e18fb0ef          	jal	80000b2c <initlock>
  if (*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005518:	100017b7          	lui	a5,0x10001
    8000551c:	4398                	lw	a4,0(a5)
    8000551e:	2701                	sext.w	a4,a4
    80005520:	747277b7          	lui	a5,0x74727
    80005524:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    80005528:	18f71063          	bne	a4,a5,800056a8 <virtio_disk_init+0x1b0>
      *R(VIRTIO_MMIO_VERSION) != 2 || *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    8000552c:	100017b7          	lui	a5,0x10001
    80005530:	0791                	addi	a5,a5,4 # 10001004 <_entry-0x6fffeffc>
    80005532:	439c                	lw	a5,0(a5)
    80005534:	2781                	sext.w	a5,a5
  if (*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005536:	4709                	li	a4,2
    80005538:	16e79863          	bne	a5,a4,800056a8 <virtio_disk_init+0x1b0>
      *R(VIRTIO_MMIO_VERSION) != 2 || *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    8000553c:	100017b7          	lui	a5,0x10001
    80005540:	07a1                	addi	a5,a5,8 # 10001008 <_entry-0x6fffeff8>
    80005542:	439c                	lw	a5,0(a5)
    80005544:	2781                	sext.w	a5,a5
    80005546:	16e79163          	bne	a5,a4,800056a8 <virtio_disk_init+0x1b0>
      *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551) {
    8000554a:	100017b7          	lui	a5,0x10001
    8000554e:	47d8                	lw	a4,12(a5)
    80005550:	2701                	sext.w	a4,a4
      *R(VIRTIO_MMIO_VERSION) != 2 || *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80005552:	554d47b7          	lui	a5,0x554d4
    80005556:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    8000555a:	14f71763          	bne	a4,a5,800056a8 <virtio_disk_init+0x1b0>
  *R(VIRTIO_MMIO_STATUS) = status;
    8000555e:	100017b7          	lui	a5,0x10001
    80005562:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    80005566:	4705                	li	a4,1
    80005568:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    8000556a:	470d                	li	a4,3
    8000556c:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    8000556e:	10001737          	lui	a4,0x10001
    80005572:	4b14                	lw	a3,16(a4)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    80005574:	c7ffe737          	lui	a4,0xc7ffe
    80005578:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47fdb287>
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    8000557c:	8ef9                	and	a3,a3,a4
    8000557e:	10001737          	lui	a4,0x10001
    80005582:	d314                	sw	a3,32(a4)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005584:	472d                	li	a4,11
    80005586:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005588:	07078793          	addi	a5,a5,112
  status = *R(VIRTIO_MMIO_STATUS);
    8000558c:	439c                	lw	a5,0(a5)
    8000558e:	0007891b          	sext.w	s2,a5
  if (!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    80005592:	8ba1                	andi	a5,a5,8
    80005594:	12078063          	beqz	a5,800056b4 <virtio_disk_init+0x1bc>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    80005598:	100017b7          	lui	a5,0x10001
    8000559c:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if (*R(VIRTIO_MMIO_QUEUE_READY))
    800055a0:	100017b7          	lui	a5,0x10001
    800055a4:	04478793          	addi	a5,a5,68 # 10001044 <_entry-0x6fffefbc>
    800055a8:	439c                	lw	a5,0(a5)
    800055aa:	2781                	sext.w	a5,a5
    800055ac:	10079a63          	bnez	a5,800056c0 <virtio_disk_init+0x1c8>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    800055b0:	100017b7          	lui	a5,0x10001
    800055b4:	03478793          	addi	a5,a5,52 # 10001034 <_entry-0x6fffefcc>
    800055b8:	439c                	lw	a5,0(a5)
    800055ba:	2781                	sext.w	a5,a5
  if (max == 0)
    800055bc:	10078863          	beqz	a5,800056cc <virtio_disk_init+0x1d4>
  if (max < NUM)
    800055c0:	471d                	li	a4,7
    800055c2:	10f77b63          	bgeu	a4,a5,800056d8 <virtio_disk_init+0x1e0>
  disk.desc = kalloc();
    800055c6:	d16fb0ef          	jal	80000adc <kalloc>
    800055ca:	0001e497          	auipc	s1,0x1e
    800055ce:	dce48493          	addi	s1,s1,-562 # 80023398 <disk>
    800055d2:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    800055d4:	d08fb0ef          	jal	80000adc <kalloc>
    800055d8:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    800055da:	d02fb0ef          	jal	80000adc <kalloc>
    800055de:	87aa                	mv	a5,a0
    800055e0:	e888                	sd	a0,16(s1)
  if (!disk.desc || !disk.avail || !disk.used)
    800055e2:	6088                	ld	a0,0(s1)
    800055e4:	10050063          	beqz	a0,800056e4 <virtio_disk_init+0x1ec>
    800055e8:	0001e717          	auipc	a4,0x1e
    800055ec:	db873703          	ld	a4,-584(a4) # 800233a0 <disk+0x8>
    800055f0:	0e070a63          	beqz	a4,800056e4 <virtio_disk_init+0x1ec>
    800055f4:	0e078863          	beqz	a5,800056e4 <virtio_disk_init+0x1ec>
  memset(disk.desc, 0, PGSIZE);
    800055f8:	6605                	lui	a2,0x1
    800055fa:	4581                	li	a1,0
    800055fc:	e7cfb0ef          	jal	80000c78 <memset>
  memset(disk.avail, 0, PGSIZE);
    80005600:	0001e497          	auipc	s1,0x1e
    80005604:	d9848493          	addi	s1,s1,-616 # 80023398 <disk>
    80005608:	6605                	lui	a2,0x1
    8000560a:	4581                	li	a1,0
    8000560c:	6488                	ld	a0,8(s1)
    8000560e:	e6afb0ef          	jal	80000c78 <memset>
  memset(disk.used, 0, PGSIZE);
    80005612:	6605                	lui	a2,0x1
    80005614:	4581                	li	a1,0
    80005616:	6888                	ld	a0,16(s1)
    80005618:	e60fb0ef          	jal	80000c78 <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    8000561c:	100017b7          	lui	a5,0x10001
    80005620:	4721                	li	a4,8
    80005622:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    80005624:	4098                	lw	a4,0(s1)
    80005626:	100017b7          	lui	a5,0x10001
    8000562a:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    8000562e:	40d8                	lw	a4,4(s1)
    80005630:	100017b7          	lui	a5,0x10001
    80005634:	08e7a223          	sw	a4,132(a5) # 10001084 <_entry-0x6fffef7c>
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    80005638:	649c                	ld	a5,8(s1)
    8000563a:	0007869b          	sext.w	a3,a5
    8000563e:	10001737          	lui	a4,0x10001
    80005642:	08d72823          	sw	a3,144(a4) # 10001090 <_entry-0x6fffef70>
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    80005646:	9781                	srai	a5,a5,0x20
    80005648:	10001737          	lui	a4,0x10001
    8000564c:	08f72a23          	sw	a5,148(a4) # 10001094 <_entry-0x6fffef6c>
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    80005650:	689c                	ld	a5,16(s1)
    80005652:	0007869b          	sext.w	a3,a5
    80005656:	10001737          	lui	a4,0x10001
    8000565a:	0ad72023          	sw	a3,160(a4) # 100010a0 <_entry-0x6fffef60>
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    8000565e:	9781                	srai	a5,a5,0x20
    80005660:	10001737          	lui	a4,0x10001
    80005664:	0af72223          	sw	a5,164(a4) # 100010a4 <_entry-0x6fffef5c>
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    80005668:	10001737          	lui	a4,0x10001
    8000566c:	4785                	li	a5,1
    8000566e:	c37c                	sw	a5,68(a4)
    disk.free[i] = 1;
    80005670:	00f48c23          	sb	a5,24(s1)
    80005674:	00f48ca3          	sb	a5,25(s1)
    80005678:	00f48d23          	sb	a5,26(s1)
    8000567c:	00f48da3          	sb	a5,27(s1)
    80005680:	00f48e23          	sb	a5,28(s1)
    80005684:	00f48ea3          	sb	a5,29(s1)
    80005688:	00f48f23          	sb	a5,30(s1)
    8000568c:	00f48fa3          	sb	a5,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    80005690:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    80005694:	100017b7          	lui	a5,0x10001
    80005698:	0727a823          	sw	s2,112(a5) # 10001070 <_entry-0x6fffef90>
}
    8000569c:	60e2                	ld	ra,24(sp)
    8000569e:	6442                	ld	s0,16(sp)
    800056a0:	64a2                	ld	s1,8(sp)
    800056a2:	6902                	ld	s2,0(sp)
    800056a4:	6105                	addi	sp,sp,32
    800056a6:	8082                	ret
    panic("could not find virtio disk");
    800056a8:	00002517          	auipc	a0,0x2
    800056ac:	f9850513          	addi	a0,a0,-104 # 80007640 <etext+0x640>
    800056b0:	924fb0ef          	jal	800007d4 <panic>
    panic("virtio disk FEATURES_OK unset");
    800056b4:	00002517          	auipc	a0,0x2
    800056b8:	fac50513          	addi	a0,a0,-84 # 80007660 <etext+0x660>
    800056bc:	918fb0ef          	jal	800007d4 <panic>
    panic("virtio disk should not be ready");
    800056c0:	00002517          	auipc	a0,0x2
    800056c4:	fc050513          	addi	a0,a0,-64 # 80007680 <etext+0x680>
    800056c8:	90cfb0ef          	jal	800007d4 <panic>
    panic("virtio disk has no queue 0");
    800056cc:	00002517          	auipc	a0,0x2
    800056d0:	fd450513          	addi	a0,a0,-44 # 800076a0 <etext+0x6a0>
    800056d4:	900fb0ef          	jal	800007d4 <panic>
    panic("virtio disk max queue too short");
    800056d8:	00002517          	auipc	a0,0x2
    800056dc:	fe850513          	addi	a0,a0,-24 # 800076c0 <etext+0x6c0>
    800056e0:	8f4fb0ef          	jal	800007d4 <panic>
    panic("virtio disk kalloc");
    800056e4:	00002517          	auipc	a0,0x2
    800056e8:	ffc50513          	addi	a0,a0,-4 # 800076e0 <etext+0x6e0>
    800056ec:	8e8fb0ef          	jal	800007d4 <panic>

00000000800056f0 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    800056f0:	7159                	addi	sp,sp,-112
    800056f2:	f486                	sd	ra,104(sp)
    800056f4:	f0a2                	sd	s0,96(sp)
    800056f6:	eca6                	sd	s1,88(sp)
    800056f8:	e8ca                	sd	s2,80(sp)
    800056fa:	e4ce                	sd	s3,72(sp)
    800056fc:	e0d2                	sd	s4,64(sp)
    800056fe:	fc56                	sd	s5,56(sp)
    80005700:	f85a                	sd	s6,48(sp)
    80005702:	f45e                	sd	s7,40(sp)
    80005704:	f062                	sd	s8,32(sp)
    80005706:	ec66                	sd	s9,24(sp)
    80005708:	1880                	addi	s0,sp,112
    8000570a:	8a2a                	mv	s4,a0
    8000570c:	8bae                	mv	s7,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    8000570e:	00c52c83          	lw	s9,12(a0)
    80005712:	001c9c9b          	slliw	s9,s9,0x1
    80005716:	1c82                	slli	s9,s9,0x20
    80005718:	020cdc93          	srli	s9,s9,0x20

  acquire(&disk.vdisk_lock);
    8000571c:	0001e517          	auipc	a0,0x1e
    80005720:	da450513          	addi	a0,a0,-604 # 800234c0 <disk+0x128>
    80005724:	c88fb0ef          	jal	80000bac <acquire>
  for (int i = 0; i < 3; i++) {
    80005728:	4981                	li	s3,0
  for (int i = 0; i < NUM; i++) {
    8000572a:	44a1                	li	s1,8
      disk.free[i] = 0;
    8000572c:	0001eb17          	auipc	s6,0x1e
    80005730:	c6cb0b13          	addi	s6,s6,-916 # 80023398 <disk>
  for (int i = 0; i < 3; i++) {
    80005734:	4a8d                	li	s5,3
  int idx[3];
  while (1) {
    if (alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    80005736:	0001ec17          	auipc	s8,0x1e
    8000573a:	d8ac0c13          	addi	s8,s8,-630 # 800234c0 <disk+0x128>
    8000573e:	a8b9                	j	8000579c <virtio_disk_rw+0xac>
      disk.free[i] = 0;
    80005740:	00fb0733          	add	a4,s6,a5
    80005744:	00070c23          	sb	zero,24(a4) # 10001018 <_entry-0x6fffefe8>
    idx[i] = alloc_desc();
    80005748:	c19c                	sw	a5,0(a1)
    if (idx[i] < 0) {
    8000574a:	0207c563          	bltz	a5,80005774 <virtio_disk_rw+0x84>
  for (int i = 0; i < 3; i++) {
    8000574e:	2905                	addiw	s2,s2,1
    80005750:	0611                	addi	a2,a2,4 # 1004 <_entry-0x7fffeffc>
    80005752:	05590963          	beq	s2,s5,800057a4 <virtio_disk_rw+0xb4>
    idx[i] = alloc_desc();
    80005756:	85b2                	mv	a1,a2
  for (int i = 0; i < NUM; i++) {
    80005758:	0001e717          	auipc	a4,0x1e
    8000575c:	c4070713          	addi	a4,a4,-960 # 80023398 <disk>
    80005760:	87ce                	mv	a5,s3
    if (disk.free[i]) {
    80005762:	01874683          	lbu	a3,24(a4)
    80005766:	fee9                	bnez	a3,80005740 <virtio_disk_rw+0x50>
  for (int i = 0; i < NUM; i++) {
    80005768:	2785                	addiw	a5,a5,1
    8000576a:	0705                	addi	a4,a4,1
    8000576c:	fe979be3          	bne	a5,s1,80005762 <virtio_disk_rw+0x72>
    idx[i] = alloc_desc();
    80005770:	57fd                	li	a5,-1
    80005772:	c19c                	sw	a5,0(a1)
      for (int j = 0; j < i; j++)
    80005774:	01205d63          	blez	s2,8000578e <virtio_disk_rw+0x9e>
        free_desc(idx[j]);
    80005778:	f9042503          	lw	a0,-112(s0)
    8000577c:	d07ff0ef          	jal	80005482 <free_desc>
      for (int j = 0; j < i; j++)
    80005780:	4785                	li	a5,1
    80005782:	0127d663          	bge	a5,s2,8000578e <virtio_disk_rw+0x9e>
        free_desc(idx[j]);
    80005786:	f9442503          	lw	a0,-108(s0)
    8000578a:	cf9ff0ef          	jal	80005482 <free_desc>
    sleep(&disk.free[0], &disk.vdisk_lock);
    8000578e:	85e2                	mv	a1,s8
    80005790:	0001e517          	auipc	a0,0x1e
    80005794:	c2050513          	addi	a0,a0,-992 # 800233b0 <disk+0x18>
    80005798:	f16fc0ef          	jal	80001eae <sleep>
  for (int i = 0; i < 3; i++) {
    8000579c:	f9040613          	addi	a2,s0,-112
    800057a0:	894e                	mv	s2,s3
    800057a2:	bf55                	j	80005756 <virtio_disk_rw+0x66>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    800057a4:	f9042503          	lw	a0,-112(s0)
    800057a8:	00451693          	slli	a3,a0,0x4

  if (write)
    800057ac:	0001e797          	auipc	a5,0x1e
    800057b0:	bec78793          	addi	a5,a5,-1044 # 80023398 <disk>
    800057b4:	00a50713          	addi	a4,a0,10
    800057b8:	0712                	slli	a4,a4,0x4
    800057ba:	973e                	add	a4,a4,a5
    800057bc:	01703633          	snez	a2,s7
    800057c0:	c710                	sw	a2,8(a4)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    800057c2:	00072623          	sw	zero,12(a4)
  buf0->sector = sector;
    800057c6:	01973823          	sd	s9,16(a4)

  disk.desc[idx[0]].addr = (uint64)buf0;
    800057ca:	6398                	ld	a4,0(a5)
    800057cc:	9736                	add	a4,a4,a3
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    800057ce:	0a868613          	addi	a2,a3,168
    800057d2:	963e                	add	a2,a2,a5
  disk.desc[idx[0]].addr = (uint64)buf0;
    800057d4:	e310                	sd	a2,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    800057d6:	6390                	ld	a2,0(a5)
    800057d8:	00d605b3          	add	a1,a2,a3
    800057dc:	4741                	li	a4,16
    800057de:	c598                	sw	a4,8(a1)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    800057e0:	4805                	li	a6,1
    800057e2:	01059623          	sh	a6,12(a1)
  disk.desc[idx[0]].next = idx[1];
    800057e6:	f9442703          	lw	a4,-108(s0)
    800057ea:	00e59723          	sh	a4,14(a1)

  disk.desc[idx[1]].addr = (uint64)b->data;
    800057ee:	0712                	slli	a4,a4,0x4
    800057f0:	963a                	add	a2,a2,a4
    800057f2:	058a0593          	addi	a1,s4,88
    800057f6:	e20c                	sd	a1,0(a2)
  disk.desc[idx[1]].len = BSIZE;
    800057f8:	0007b883          	ld	a7,0(a5)
    800057fc:	9746                	add	a4,a4,a7
    800057fe:	40000613          	li	a2,1024
    80005802:	c710                	sw	a2,8(a4)
  if (write)
    80005804:	001bb613          	seqz	a2,s7
    80005808:	0016161b          	slliw	a2,a2,0x1
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    8000580c:	00166613          	ori	a2,a2,1
    80005810:	00c71623          	sh	a2,12(a4)
  disk.desc[idx[1]].next = idx[2];
    80005814:	f9842583          	lw	a1,-104(s0)
    80005818:	00b71723          	sh	a1,14(a4)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    8000581c:	00250613          	addi	a2,a0,2
    80005820:	0612                	slli	a2,a2,0x4
    80005822:	963e                	add	a2,a2,a5
    80005824:	577d                	li	a4,-1
    80005826:	00e60823          	sb	a4,16(a2)
  disk.desc[idx[2]].addr = (uint64)&disk.info[idx[0]].status;
    8000582a:	0592                	slli	a1,a1,0x4
    8000582c:	98ae                	add	a7,a7,a1
    8000582e:	03068713          	addi	a4,a3,48
    80005832:	973e                	add	a4,a4,a5
    80005834:	00e8b023          	sd	a4,0(a7)
  disk.desc[idx[2]].len = 1;
    80005838:	6398                	ld	a4,0(a5)
    8000583a:	972e                	add	a4,a4,a1
    8000583c:	01072423          	sw	a6,8(a4)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    80005840:	4689                	li	a3,2
    80005842:	00d71623          	sh	a3,12(a4)
  disk.desc[idx[2]].next = 0;
    80005846:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    8000584a:	010a2223          	sw	a6,4(s4)
  disk.info[idx[0]].b = b;
    8000584e:	01463423          	sd	s4,8(a2)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    80005852:	6794                	ld	a3,8(a5)
    80005854:	0026d703          	lhu	a4,2(a3)
    80005858:	8b1d                	andi	a4,a4,7
    8000585a:	0706                	slli	a4,a4,0x1
    8000585c:	96ba                	add	a3,a3,a4
    8000585e:	00a69223          	sh	a0,4(a3)

  __atomic_thread_fence(__ATOMIC_SEQ_CST);
    80005862:	0330000f          	fence	rw,rw

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    80005866:	6798                	ld	a4,8(a5)
    80005868:	00275783          	lhu	a5,2(a4)
    8000586c:	2785                	addiw	a5,a5,1
    8000586e:	00f71123          	sh	a5,2(a4)

  __atomic_thread_fence(__ATOMIC_SEQ_CST);
    80005872:	0330000f          	fence	rw,rw

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    80005876:	100017b7          	lui	a5,0x10001
    8000587a:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while (b->disk == 1) {
    8000587e:	004a2783          	lw	a5,4(s4)
    sleep(b, &disk.vdisk_lock);
    80005882:	0001e917          	auipc	s2,0x1e
    80005886:	c3e90913          	addi	s2,s2,-962 # 800234c0 <disk+0x128>
  while (b->disk == 1) {
    8000588a:	4485                	li	s1,1
    8000588c:	01079a63          	bne	a5,a6,800058a0 <virtio_disk_rw+0x1b0>
    sleep(b, &disk.vdisk_lock);
    80005890:	85ca                	mv	a1,s2
    80005892:	8552                	mv	a0,s4
    80005894:	e1afc0ef          	jal	80001eae <sleep>
  while (b->disk == 1) {
    80005898:	004a2783          	lw	a5,4(s4)
    8000589c:	fe978ae3          	beq	a5,s1,80005890 <virtio_disk_rw+0x1a0>
  }

  disk.info[idx[0]].b = 0;
    800058a0:	f9042903          	lw	s2,-112(s0)
    800058a4:	00290713          	addi	a4,s2,2
    800058a8:	0712                	slli	a4,a4,0x4
    800058aa:	0001e797          	auipc	a5,0x1e
    800058ae:	aee78793          	addi	a5,a5,-1298 # 80023398 <disk>
    800058b2:	97ba                	add	a5,a5,a4
    800058b4:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    800058b8:	0001e997          	auipc	s3,0x1e
    800058bc:	ae098993          	addi	s3,s3,-1312 # 80023398 <disk>
    800058c0:	00491713          	slli	a4,s2,0x4
    800058c4:	0009b783          	ld	a5,0(s3)
    800058c8:	97ba                	add	a5,a5,a4
    800058ca:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    800058ce:	854a                	mv	a0,s2
    800058d0:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    800058d4:	bafff0ef          	jal	80005482 <free_desc>
    if (flag & VRING_DESC_F_NEXT)
    800058d8:	8885                	andi	s1,s1,1
    800058da:	f0fd                	bnez	s1,800058c0 <virtio_disk_rw+0x1d0>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    800058dc:	0001e517          	auipc	a0,0x1e
    800058e0:	be450513          	addi	a0,a0,-1052 # 800234c0 <disk+0x128>
    800058e4:	b5cfb0ef          	jal	80000c40 <release>
}
    800058e8:	70a6                	ld	ra,104(sp)
    800058ea:	7406                	ld	s0,96(sp)
    800058ec:	64e6                	ld	s1,88(sp)
    800058ee:	6946                	ld	s2,80(sp)
    800058f0:	69a6                	ld	s3,72(sp)
    800058f2:	6a06                	ld	s4,64(sp)
    800058f4:	7ae2                	ld	s5,56(sp)
    800058f6:	7b42                	ld	s6,48(sp)
    800058f8:	7ba2                	ld	s7,40(sp)
    800058fa:	7c02                	ld	s8,32(sp)
    800058fc:	6ce2                	ld	s9,24(sp)
    800058fe:	6165                	addi	sp,sp,112
    80005900:	8082                	ret

0000000080005902 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    80005902:	1101                	addi	sp,sp,-32
    80005904:	ec06                	sd	ra,24(sp)
    80005906:	e822                	sd	s0,16(sp)
    80005908:	e426                	sd	s1,8(sp)
    8000590a:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    8000590c:	0001e497          	auipc	s1,0x1e
    80005910:	a8c48493          	addi	s1,s1,-1396 # 80023398 <disk>
    80005914:	0001e517          	auipc	a0,0x1e
    80005918:	bac50513          	addi	a0,a0,-1108 # 800234c0 <disk+0x128>
    8000591c:	a90fb0ef          	jal	80000bac <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    80005920:	100017b7          	lui	a5,0x10001
    80005924:	53b8                	lw	a4,96(a5)
    80005926:	8b0d                	andi	a4,a4,3
    80005928:	100017b7          	lui	a5,0x10001
    8000592c:	d3f8                	sw	a4,100(a5)

  __atomic_thread_fence(__ATOMIC_SEQ_CST);
    8000592e:	0330000f          	fence	rw,rw

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while (disk.used_idx != disk.used->idx) {
    80005932:	689c                	ld	a5,16(s1)
    80005934:	0204d703          	lhu	a4,32(s1)
    80005938:	0027d783          	lhu	a5,2(a5) # 10001002 <_entry-0x6fffeffe>
    8000593c:	04f70663          	beq	a4,a5,80005988 <virtio_disk_intr+0x86>
    __atomic_thread_fence(__ATOMIC_SEQ_CST);
    80005940:	0330000f          	fence	rw,rw
    int id = disk.used->ring[disk.used_idx % NUM].id;
    80005944:	6898                	ld	a4,16(s1)
    80005946:	0204d783          	lhu	a5,32(s1)
    8000594a:	8b9d                	andi	a5,a5,7
    8000594c:	078e                	slli	a5,a5,0x3
    8000594e:	97ba                	add	a5,a5,a4
    80005950:	43dc                	lw	a5,4(a5)

    if (disk.info[id].status != 0)
    80005952:	00278713          	addi	a4,a5,2
    80005956:	0712                	slli	a4,a4,0x4
    80005958:	9726                	add	a4,a4,s1
    8000595a:	01074703          	lbu	a4,16(a4)
    8000595e:	e321                	bnez	a4,8000599e <virtio_disk_intr+0x9c>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    80005960:	0789                	addi	a5,a5,2
    80005962:	0792                	slli	a5,a5,0x4
    80005964:	97a6                	add	a5,a5,s1
    80005966:	6788                	ld	a0,8(a5)
    b->disk = 0; // disk is done with buf
    80005968:	00052223          	sw	zero,4(a0)
    wakeup(b);
    8000596c:	d8efc0ef          	jal	80001efa <wakeup>

    disk.used_idx += 1;
    80005970:	0204d783          	lhu	a5,32(s1)
    80005974:	2785                	addiw	a5,a5,1
    80005976:	17c2                	slli	a5,a5,0x30
    80005978:	93c1                	srli	a5,a5,0x30
    8000597a:	02f49023          	sh	a5,32(s1)
  while (disk.used_idx != disk.used->idx) {
    8000597e:	6898                	ld	a4,16(s1)
    80005980:	00275703          	lhu	a4,2(a4)
    80005984:	faf71ee3          	bne	a4,a5,80005940 <virtio_disk_intr+0x3e>
  }

  release(&disk.vdisk_lock);
    80005988:	0001e517          	auipc	a0,0x1e
    8000598c:	b3850513          	addi	a0,a0,-1224 # 800234c0 <disk+0x128>
    80005990:	ab0fb0ef          	jal	80000c40 <release>
}
    80005994:	60e2                	ld	ra,24(sp)
    80005996:	6442                	ld	s0,16(sp)
    80005998:	64a2                	ld	s1,8(sp)
    8000599a:	6105                	addi	sp,sp,32
    8000599c:	8082                	ret
      panic("virtio_disk_intr status");
    8000599e:	00002517          	auipc	a0,0x2
    800059a2:	d5a50513          	addi	a0,a0,-678 # 800076f8 <etext+0x6f8>
    800059a6:	e2ffa0ef          	jal	800007d4 <panic>
	...

0000000080006000 <_trampoline>:
    80006000:	14051073          	csrw	sscratch,a0
    80006004:	02000537          	lui	a0,0x2000
    80006008:	357d                	addiw	a0,a0,-1 # 1ffffff <_entry-0x7e000001>
    8000600a:	0536                	slli	a0,a0,0xd
    8000600c:	02153423          	sd	ra,40(a0)
    80006010:	02253823          	sd	sp,48(a0)
    80006014:	02353c23          	sd	gp,56(a0)
    80006018:	04453023          	sd	tp,64(a0)
    8000601c:	04553423          	sd	t0,72(a0)
    80006020:	04653823          	sd	t1,80(a0)
    80006024:	04753c23          	sd	t2,88(a0)
    80006028:	f120                	sd	s0,96(a0)
    8000602a:	f524                	sd	s1,104(a0)
    8000602c:	fd2c                	sd	a1,120(a0)
    8000602e:	e150                	sd	a2,128(a0)
    80006030:	e554                	sd	a3,136(a0)
    80006032:	e958                	sd	a4,144(a0)
    80006034:	ed5c                	sd	a5,152(a0)
    80006036:	0b053023          	sd	a6,160(a0)
    8000603a:	0b153423          	sd	a7,168(a0)
    8000603e:	0b253823          	sd	s2,176(a0)
    80006042:	0b353c23          	sd	s3,184(a0)
    80006046:	0d453023          	sd	s4,192(a0)
    8000604a:	0d553423          	sd	s5,200(a0)
    8000604e:	0d653823          	sd	s6,208(a0)
    80006052:	0d753c23          	sd	s7,216(a0)
    80006056:	0f853023          	sd	s8,224(a0)
    8000605a:	0f953423          	sd	s9,232(a0)
    8000605e:	0fa53823          	sd	s10,240(a0)
    80006062:	0fb53c23          	sd	s11,248(a0)
    80006066:	11c53023          	sd	t3,256(a0)
    8000606a:	11d53423          	sd	t4,264(a0)
    8000606e:	11e53823          	sd	t5,272(a0)
    80006072:	11f53c23          	sd	t6,280(a0)
    80006076:	140022f3          	csrr	t0,sscratch
    8000607a:	06553823          	sd	t0,112(a0)
    8000607e:	00853103          	ld	sp,8(a0)
    80006082:	02053203          	ld	tp,32(a0)
    80006086:	01053283          	ld	t0,16(a0)
    8000608a:	00053303          	ld	t1,0(a0)
    8000608e:	12000073          	sfence.vma
    80006092:	18031073          	csrw	satp,t1
    80006096:	12000073          	sfence.vma
    8000609a:	9282                	jalr	t0

000000008000609c <userret>:
    8000609c:	12000073          	sfence.vma
    800060a0:	18051073          	csrw	satp,a0
    800060a4:	12000073          	sfence.vma
    800060a8:	02000537          	lui	a0,0x2000
    800060ac:	357d                	addiw	a0,a0,-1 # 1ffffff <_entry-0x7e000001>
    800060ae:	0536                	slli	a0,a0,0xd
    800060b0:	02853083          	ld	ra,40(a0)
    800060b4:	03053103          	ld	sp,48(a0)
    800060b8:	03853183          	ld	gp,56(a0)
    800060bc:	04053203          	ld	tp,64(a0)
    800060c0:	04853283          	ld	t0,72(a0)
    800060c4:	05053303          	ld	t1,80(a0)
    800060c8:	05853383          	ld	t2,88(a0)
    800060cc:	7120                	ld	s0,96(a0)
    800060ce:	7524                	ld	s1,104(a0)
    800060d0:	7d2c                	ld	a1,120(a0)
    800060d2:	6150                	ld	a2,128(a0)
    800060d4:	6554                	ld	a3,136(a0)
    800060d6:	6958                	ld	a4,144(a0)
    800060d8:	6d5c                	ld	a5,152(a0)
    800060da:	0a053803          	ld	a6,160(a0)
    800060de:	0a853883          	ld	a7,168(a0)
    800060e2:	0b053903          	ld	s2,176(a0)
    800060e6:	0b853983          	ld	s3,184(a0)
    800060ea:	0c053a03          	ld	s4,192(a0)
    800060ee:	0c853a83          	ld	s5,200(a0)
    800060f2:	0d053b03          	ld	s6,208(a0)
    800060f6:	0d853b83          	ld	s7,216(a0)
    800060fa:	0e053c03          	ld	s8,224(a0)
    800060fe:	0e853c83          	ld	s9,232(a0)
    80006102:	0f053d03          	ld	s10,240(a0)
    80006106:	0f853d83          	ld	s11,248(a0)
    8000610a:	10053e03          	ld	t3,256(a0)
    8000610e:	10853e83          	ld	t4,264(a0)
    80006112:	11053f03          	ld	t5,272(a0)
    80006116:	11853f83          	ld	t6,280(a0)
    8000611a:	7928                	ld	a0,112(a0)
    8000611c:	10200073          	sret
	...
