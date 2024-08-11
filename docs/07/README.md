# 支持RV32IM的NEMU
用C语言来实现一个RISC-V处理器(的模拟器): pa2阶段1

## 指令周期
对于大部分指令来说, 执行它们都可以抽象成取指-译码-执行的指令周期:

1. 取指(instruction fetch, IF): 要执行一条指令, 首先要拿到这条指令. 指令在存储器中, 由PC指出当前指令的位置. 事实上, PC就是一个指针. 取指令要做的事情自然就是将PC指向的指令从内存读入到CPU中
2. 译码(instruction decode, ID): 在取指阶段, 计算机拿到了将要执行的指令: 0和1组成的比特串. CPU可以通过查表的方式得知这条指令的操作数和操作码，这个过程叫译码. 译码逻辑实际上也并非只有一张查找表那么简单, 还需要根据不同的指令通过多路选择器选择不同的操作数
3. 执行(execute, EX): 经过译码之后, CPU就知道当前指令具体要做什么了, 执行阶段就是真正完成指令的工作. 现在TRM只有加法器这一个执行部件, 必要的时候, 只需要往加法器输入两个源操作数, 就能得到执行的结果了. 之后还要把结果写回到目的操作数中, 可能是寄存器, 也可能是内存
4. 更新PC: 执行完一条指令之后, CPU就要执行下一条指令. 在这之前, CPU需要更新PC的值, 让PC加上刚才执行完的指令的长度, 即可指向下一条指令的位置

## YEMU
以YEMU来理解计算机的指令执行: [YEMU:一个简单的CPU模拟器](./yemu.md)

## 整理一条指令在NEMU中的执行过程
- 使用 gdb 运行 nemu, 按 `s` 进入指令执行相关函数与宏的执行
- 此以指令`00 00 02 97 auipc   t0, 0`为例，根据GDB的调试过程, 可以看到在取指阶段，`s->isa.inst.val = inst_fetch(&s->snpc, 4);`将指令读取到s结构体成员中
- 之后在`decode_exec(Decode *s)`函数中，初始化了rd, src1, src2, imm，并维护了下一条动态指令
- 之后`INSTPAT()`识别到`auipc`指令，根据指令设置了rs1, rs2与rd, 之后把U型立即数记录到操作数imm，执行`R(rd) = s->pc + imm`就完成了指令执行
- 最后更新cpu.pc就完成了pc的更新，这就是`auipc`指令的执行过程

## 运行第一个客户程序
克隆一个新的子项目am-kernels(在PA1干过了); 准备交叉编译环境riscv32(64): `apt-get install g++-riscv64-linux-gnu binutils-riscv64-linux-gnu`

在`am-kernels/tests/cpu-tests/`目录下准备了一些简单的测试用例. 在该目录下执行`make ARCH=$ISA-nemu ALL=xxx run`, 其中xxx为测试用例的名称(不包含`.c`后缀). 上述`make run`的命令最终会启动nemu, 并运行相应的客户程序. 如果需要使用GDB来调试nemu运行客户程序的情况, 可以执行以下命令`make ARCH=$ISA-nemu ALL=xxx gdb`

报告错误: `/usr/riscv64-linux-gnu/include/gnu/stubs.h:8:11: fatal error: gnu/stubs-ilp32.h: No such file or directory`

需要使用sudo权限修改以下文件:

```
--- /usr/riscv64-linux-gnu/include/gnu/stubs.h
+++ /usr/riscv64-linux-gnu/include/gnu/stubs.h
@@ -5,5 +5,5 @@
 #include <bits/wordsize.h>

 #if __WORDSIZE == 32 && defined __riscv_float_abi_soft
-# include <gnu/stubs-ilp32.h>
+//# include <gnu/stubs-ilp32.h>
 #endif
```

之后运行，进入nemu后运行客户程序，报错，这是因为还没有实现0x00000413的指令, 因此,需要在nemu中添加指令

实现了 `addi`, `jal`, `jalr`, `sw` 后能够正确运行 dummy 程序

#### 为什么执行了未实现指令会出现上述报错信息
RTFSC, 理解执行未实现指令的时候, nemu具体会怎么做:

NEMU会解析到inv指令，继而调用INV宏进行处理，INV宏定义在`nemu/include/cpu/cpu.h`，调用了`invalid_inst(thispc)`函数进行处理，而这一函数又定义在`nemu/src/engine/interpreter/hostcall.c`中，给出了报错信息
