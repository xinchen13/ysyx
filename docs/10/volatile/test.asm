
test.o:     file format elf32-littleriscv


Disassembly of section .text:

00000000 <fun>:
   0:	00000797          	auipc	a5,0x0
   4:	0007a783          	lw	a5,0(a5) # 0 <fun>
   8:	00078023          	sb	zero,0(a5)

0000000c <.L2>:
   c:	0000006f          	j	c <.L2>

Disassembly of section .text.startup:

00000000 <main>:
   0:	00000797          	auipc	a5,0x0
   4:	0007a783          	lw	a5,0(a5) # 0 <main>
   8:	00078023          	sb	zero,0(a5)

0000000c <.L5>:
   c:	0000006f          	j	c <.L5>
