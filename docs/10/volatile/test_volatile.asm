
test_volatile.o:     file format elf32-littleriscv


Disassembly of section .text:

00000000 <fun>:
   0:	00000717          	auipc	a4,0x0
   4:	00072703          	lw	a4,0(a4) # 0 <fun>
   8:	00070023          	sb	zero,0(a4)
   c:	0ff00693          	li	a3,255

00000010 <.L2>:
  10:	00074783          	lbu	a5,0(a4)
  14:	fed79ee3          	bne	a5,a3,10 <.L2>
  18:	03300793          	li	a5,51
  1c:	00f70023          	sb	a5,0(a4)
  20:	03400793          	li	a5,52
  24:	00f70023          	sb	a5,0(a4)
  28:	f8600793          	li	a5,-122
  2c:	00f70023          	sb	a5,0(a4)
  30:	00008067          	ret

Disassembly of section .text.startup:

00000000 <main>:
   0:	00000717          	auipc	a4,0x0
   4:	00072703          	lw	a4,0(a4) # 0 <main>
   8:	00070023          	sb	zero,0(a4)
   c:	0ff00693          	li	a3,255

00000010 <.L6>:
  10:	00074783          	lbu	a5,0(a4)
  14:	fed79ee3          	bne	a5,a3,10 <.L6>
  18:	03300793          	li	a5,51
  1c:	00f70023          	sb	a5,0(a4)
  20:	03400793          	li	a5,52
  24:	00f70023          	sb	a5,0(a4)
  28:	f8600793          	li	a5,-122
  2c:	00f70023          	sb	a5,0(a4)
  30:	00000513          	li	a0,0
  34:	00008067          	ret
