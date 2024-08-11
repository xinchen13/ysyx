# YEMU: 一个简单的CPU模拟器
这个计算机有4个8位的寄存器, 一个4位PC, 以及一段16字节的内存. 它支持R型和M型两种指令格式, 4条指令. 其指令手册如下:

```
                                                     4  2  0
            |                        |        | +----+--+--+
mov   rt,rs | R[rt] <- R[rs]         | R-type | |0000|rt|rs|
            |                        |        | +----+--+--+
            |                        |        | +----+--+--+
add   rt,rs | R[rt] <- R[rs] + R[rt] | R-type | |0001|rt|rs|
            |                        |        | +----+--+--+
            |                        |        | +----+--+--+
load  addr  | R[0] <- M[addr]        | M-type | |1110| addr|
            |                        |        | +----+--+--+
            |                        |        | +----+--+--+
store addr  | M[addr] <- R[0]        | M-type | |1111| addr|
            |                        |        | +----+--+--+
```

对于采用补码表示的计算机, 能做加法自然就能做减法. 如果再添加一条条件跳转指令`jnz r, addr`: 当寄存器r不为0时, PC跳转到addr处, TRM就大不一样了. 例如通过jnz和dec的组合可以实现循环, 循环执行inc可以实现任意数的加法, 循环执行加法可以实现乘法, 函数调用可以看成一种特殊的跳转, 递归本质上就是函数调用.

根据指令手册可以写出YEMU模拟器:

```c
#include <stdint.h>
#include <stdio.h>

#define NREG 4
#define NMEM 16

// 定义指令格式
typedef union {
  struct { uint8_t rs : 2, rt : 2, op : 4; } rtype;
  struct { uint8_t addr : 4      , op : 4; } mtype;
  uint8_t inst;
} inst_t;

#define DECODE_R(inst) uint8_t rt = (inst).rtype.rt, rs = (inst).rtype.rs
#define DECODE_M(inst) uint8_t addr = (inst).mtype.addr

uint8_t pc = 0;       // PC, C语言中没有4位的数据类型, 我们采用8位类型来表示
uint8_t R[NREG] = {}; // 寄存器
uint8_t M[NMEM] = {   // 内存, 其中包含一个计算z = x + y的程序
  0b11100110,  // load  6#     | R[0] <- M[y]
  0b00000100,  // mov   r1, r0 | R[1] <- R[0]
  0b11100101,  // load  5#     | R[0] <- M[x]
  0b00010001,  // add   r0, r1 | R[0] <- R[0] + R[1]
  0b11110111,  // store 7#     | M[z] <- R[0]
  0b00010000,  // x = 16
  0b00100001,  // y = 33
  0b00000000,  // z = 0
};

int halt = 0; // 结束标志

// 执行一条指令
void exec_once() {
  inst_t this;
  this.inst = M[pc]; // 取指
  switch (this.rtype.op) {
  //  操作码译码       操作数译码           执行
    case 0b0000: { DECODE_R(this); R[rt]   = R[rs];   break; }
    case 0b0001: { DECODE_R(this); R[rt]  += R[rs];   break; }
    case 0b1110: { DECODE_M(this); R[0]    = M[addr]; break; }
    case 0b1111: { DECODE_M(this); M[addr] = R[0];    break; }
    default:
      printf("Invalid instruction with opcode = %x, halting...\n", this.rtype.op);
      halt = 1;
      break;
  }
  pc ++; // 更新PC
}

int main() {
  while (1) {
    exec_once();
    if (halt) break;
  }
  printf("The result of 16 + 33 is %d\n", M[7]);
  return 0;
}
```

## 理解YEMU如何执行程序
YEMU可以看成是一个简化版的NEMU, 它们的原理是相通的, 因此你需要理解YEMU是如何执行程序的. 具体地, 你需要
#### 画出在YEMU上执行的加法程序的状态机
用`(PC, R[0], R[1])`的组合来表示系统状态, 则加法程序(c=a+b)的状态机:

```
(0, xxxxxxxx, xxxxxxxx) -> (1, a, x) -> (2, a, a) -> (3, b, a) -> (4, b+a, a)
```

#### 通过RTFSC理解YEMU如何执行一条指令
首先根据pc的值读取当前指令（取指）; 其次根据指令手册写的查找表来确定指令类型与操作（译码），之后相应的进行内存、寄存器的读写（执行）; 最后更新pc

#### 思考一下, 以上两者有什么联系?
指令相当于状态机转移的激励，通过PC建立内存中的指令、数据与CPU状态机的交互