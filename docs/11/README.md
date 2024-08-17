# 支持RV32E的单周期NPC
- 采用RV32E指令集来设计npc (启动Linux使用RV64IMAC)
- RV32E的程序可以直接运行在RV32IM的处理器上, 因此可以把RV32IM的NEMU作为DiffTest的REF

## 搭建面向riscv32e-npc的运行时环境
AM项目已经提供了riscv32e-npc的基本框架, 只需要在 `am-kernels/tests/cpu-tests/` 目录下执行 `make ARCH=riscv32e-npc ALL=xxx` 即可将名为xxx的测试编译到riscv32e-npc的运行时环境中

### 从命令行中读入NPC需要执行的程序
接下来将会在NPC中不断地运行各种程序, 如果每次运行新程序都要重新编译NPC, 效率是很低的. 为了提高效率, 可以让仿真环境从命令行中读入程序的路径, 然后把程序内容放置到存储器中

- 参考nemu的参数读入，使用`getopt()`来读取命令行提供的`IMG`参数
- IMG参数由Makefile通过`make sim IMG=--img=xxx`的方式指定, 与am在调用nemu时的传递程序路径的方法相同(具体rtfsc: `$AM_HOME/scripts/platform/nemu.mk`)
- 根据nemu的存储器重构了仿真环境的存储器
- 使用`make sim IMG=--img=./default/dummy-riscv32e-npc.bin`测试，成功读入

### 一键编译并在NPC上运行AM程序
在AM项目中, 为riscv32e-npc提供run目标, 使得键入`make ARCH=riscv32e-npc ALL=xxx run`即可把AM程序编译并在NPC上运行

- 参考`$AM_HOME/scripts/platform/nemu.mk`, 为`$AM_HOME/scripts/platform/npc.mk`添加run目标, 即可直接将am程序编译到npc上

### 在NPC上运行dummy程序
sw指令需要访存内存, 不过对于dummy程序来说, 不实现也不影响运行的结果. 因此目前可以将它实现成空指令, 后面再来正确地实现它. 在架构图上添加auipc, lui, jal, jalr的电路. 实现上述指令, 使得NPC可以运行dummy程序:

<img src="../../figs/CamScanner 08-16-2024 12.24.jpg" width="500" />

修改rtl，添加了新的指令译码和执行，更新pc的生成逻辑, 此时查看波形:

<img src="../../figs/Screenshot from 2024-08-16 12-28-26.png"/>

### 实现riscv32e-npc中的halt()函数
为了可以自动地结束程序, 需要在riscv32e-npc中实现TRM的`halt()`函数, 在其中添加一条ebreak指令. 实现之后,就可以通过一条命令自动在NPC上运行AM程序并自动结束仿真了

- 参考`$AM_HOME/am/src/platform/nemu/include/nemu.h`, 在`$AM_HOME/am/src/riscv/npc/trm.c`添加内联汇编，并在`halt()`函数中调用

### 为NPC实现HIT GOOD/BAD TRAP
为NPC实现`HIT GOOD`/`BAD TRAP`, 输出程序是否成功结束执行的信息:

- rtfsc, 发现nemu中的相关功能是通过判断客户程序的返回值实现的
- 注意到之前实现ebreak的时候，内联汇编会把程序的返回值保存到寄存器a0中，因此只需要在仿真环境中读取a0的值作出判断
- 阅读verilator编译得到的头文件，发现可以通过`top->rootp->xcore__DOT__regfile_u0__DOT__regs[10]`的方式来访问a0寄存器
- 使得仿真环境返回该值即可

## 为NPC搭建基础设施
在PA中有四大基础设施: sdb, trace, native, DiffTest. 除了native属于AM之外, 其余三大基础设施都可以在NPC中搭建

### 为NPC搭建sdb
为NPC实现单步执行, 打印寄存器和扫描内存的功能, 而表达式求值和监视点都是基于打印寄存器和扫描内存实现的:

- 首先根据nemu重构了访存系统和log(保存到`build/npc.log`)，并移植了monitor
- 移植sdb时涉及readline和history库，不仅需要包括头文件，还要在makefile中添加链接选项`-lreadline`
- 通过Verilator编译出的C++文件来访问通用寄存器，如`dut->rootp->xcore__DOT__regfile_u0__DOT__regs[i]`表示第i个寄存器
- 在npc仿真环境中构造了一组寄存器，在每次执行后与rtl模型进行同步，这样接口更清晰
- 在`main.cpp`中生命了一部分全局变量，这样方便sdb与monitor使用

### 为NPC添加trace支持
在NPC中实现itrace, mtrace和ftrace

#### itrace
- 重新编写DPI-C，来获取当前运行的指令，用于判断ebreak与itrace
- 链接llvm库, 具体参考`$NEMU_HOME/src/utils/filelist.mk`: 主要是为Makefile添加源文件、编译规则和链接规则; 在使用函数时需要声明
- 具体的itrace参考nemu, 反汇编需要在monitor中初始化

#### ftrace
- 为`parse_args()`提供解析elf文件的选项`--elf`，从而读取到函数信息(默认的elf位于`$NPC_HOME/default/`目录下)
- 相比nemu的ftrace，添加了: 在开启ftrace时未传入elf文件/传入错误路径时的assert检查
- 指令解析与跳转、返回识别采取与nemu一样的策略，在`trace_and_difftest()`中实现

#### mtrace
- npc实现访存指令后再实现