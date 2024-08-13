# 运行时环境和基础设施
- 为了运行更多的程序, 要为npc添加更多的指令, 进而考虑应该如何编译一个可以在npc上运行的程序, 并将其放到npc上运行
- 了解程序和计算机硬件之间的一层重要的抽象: 运行时环境
- 搭建更强大的基础设施, 在后续设计npc的时候发挥作用

## 运行时环境
应用程序的运行都需要运行时环境的支持, 包括加载, 销毁程序, 以及提供程序运行时的各种动态链接库(而不只单单会计算的TRM)

### 将运行时环境封装成库函数
- 为了让`n`个程序运行在`m`个架构上，本需要维护`n*m`份代码
- 通过把运行时环境抽象成库, 只需要定义一个结束程序的API, 比如`void halt()`供软件调用, 不同的架构分别实现自己的`halt()`, 这样就只需要维护`n+m`份代码

## AM - 裸机(bare-metal)运行时环境
AM(Abstract machine): 一个向程序提供运行时环境的库, 包含一组统一抽象的API, AM根据程序的需求把库划分成以下模块: AM = TRM + IOE + CTE + VME + MPE
- TRM(Turing Machine) - 图灵机, 最简单的运行时环境, 为程序提供基本的计算能力
- IOE(I/O Extension) - 输入输出扩展, 为程序提供输出输入的能力
- CTE(Context Extension) - 上下文扩展, 为程序提供上下文管理的能力
- VME(Virtual Memory Extension) - 虚存扩展, 为程序提供虚存管理的能力
- MPE(Multi-Processor Extension) - 多处理器扩展, 为程序提供多处理器通信的能力

有了AM后, PA的流程:
```
(在NEMU中)实现硬件功能 -> (在AM中)提供运行时环境 -> (在APP层)运行程序
(在NEMU中)实现更强大的硬件功能 -> (在AM中)提供更丰富的运行时环境 -> (在APP层)运行更复杂的程序
```

### 操作系统也有自己的运行时环境. AM和操作系统提供的运行时环境有什么不同呢? 为什么会有这些不同
AM提供的是程序运行必不可少的API，以及一些常用库函数, 和OS提供的接口有交集

## 阅读 Makefile, 通过批处理模式运行
阅读`abstract-machine`项目的Makefile

之前启动nemu的时候, 每次都需要手动键入`c`才能运行客户程序. 但如果不是为了使用nemu中的sdb, 我们其实可以节省`c`的键入. nemu中实现了一个批处理模式, 可以在启动nemu之后直接运行客户程序

- 阅读nemu的代码，发现`init_monitor()`函数调用了`parse_args()`，给`main()`传入参数`-b`或者`--batch`就可以调用`sdb_set_batch_mode()`将`is_batch_mode`置为true，从而启动nemu后就能直接运行客户程序, 使得通过AM的Makefile可以默认启动批处理模式的nemu
- 阅读Makefile，主要关注`make run`所对应的部分，查看传入参数, 注意到在`nemu/scripts/native.mk`中`ARGS`变量对应传给`main()`的参数. 在`Kconfig`文件中添加开关选项`BATCH_MODE`来控制开启与关闭; 在`nemu/scripts/native.mk`中通过`override ARGS += -b`来增加参数
- `make menuconfig`开启批处理模式后回到`am-kernels`目录，输入`make ARCH=riscv32-nemu run`即按批处理模式进行测试; 同时，直接在nemu目录下`make run`也是默认打开批处理模式
- 考虑到不在 `$AM_HOME/scripts/platform/nemu.mk` 中修改 `NEMUFLAGS` 是因为一方面直接运行nemu(运行内置客户程序)不能实现批处理模式，另一方面需要配置时需要修改源文件; 现在的实现方式把批处理模式作为nemu的功能统一管理了

## 实现字符串处理函数
实现`abstract-machine/klib/src/string.c`中列出的字符串处理函数, 让`cpu-tests`中的测试用例`string`可以成功运行

- 通过`man 3 <str-function-name>`查看手册, `strcpy`, `strncpy`, `memset`, `memcpy`不允许dst和src的内存重叠(overlap), 但是 `memmove`需要支持overlap
- 对于`memmove`的实现，通过在函数内的tmp临时变量作为缓冲，设置的大小为256(也就是说n > 256会产生未定义行为)
- 一些函数的实现参考了手册中的example

## 实现sprintf
为了运行测试用例`hello-str`, 还需要实现`abstract-machine/klib/src/stdio.c`中的库函数`sprintf()`. 和其它库函数相比, `sprintf()`比较特殊, 因为它的参数数目是可变的. 为了获得数目可变的参数, 可以使用C库`stdarg.h`中提供的宏, 具体用法查阅`man stdarg`. 目前只需要实现`%s`和`%d`就能通过`hello-str`的测试了, 其它功能(包括位宽, 精度等)可以在将来需要的时候再自行实现

- `stdarg`提供了va_list类型与`va_start()`, `va_arg()`, `va_end()`三个宏，进行参数提取
- 基本思路是检测格式化输出符号: 如果fmt中字符不涉及格式化输出, 则直接写入out中, 否则对类型进行匹配, 格式化输出对应的参数
- 暂不支持形如`%%d`形式的参数与位宽, 精度等(分支pa2s2)

## bug诊断的利器 - trace
在软件工程领域, 记录程序执行过程的信息称为踪迹(trace), 可以判断程序的执行过程是否符合预期, 从而进行bug的诊断

## 指令执行的踪迹 - itrace
itrace (instruction trace), 它可以记录客户程序执行的每一条指令. 代码只要记录`inst_fetch()`取到的每一条指令, 然后调用llvm项目提供的反汇编功能(在`nemu/src/utils/disasm.cc`中实现). itrace会输出指令的PC, 二进制表示以及反汇编结果. 框架代码默认已经打开了这个功能, 客户程序执行的指令都会被记录到`build/nemu-log.txt`中

一般来说只会关心出错现场前的trace, 可以维护一个环形缓冲区iringbuf来实现在客户程序出错(例如访问物理内存越界)的时候输出最近执行的若干条指令:

- 分析trace的性质, 应当是作为nemu计算机运行的监视程序, 可以将其归类到monitor中, 因此参考watchpoint的实现方式:  在`$NEMU_HOME/src/monitor/sdb/sdb.h`中声明了`iRingBuffer`数据结构以及初始化、写入与输出的函数; 具体实现位于`$NEMU_HOME/src/monitor/sdb/iringbuf.c`, 在其中使用函数对静态变量nemu_iringbuf进行读写
- 指令环形缓冲区的初始化放在`$NEMU_HOME/src/monitor/monitor.c`中的`init_monitor()`函数中进行, 当没有配置itrace时不进行初始化节约时间开销
- 在cpu执行过程中(即运行`cpu_exec()`), `trace_and_difftest()`函数通过`CONFIG_ITRACE`宏配置开关iringbuf的读写; 通过把128位的`s->logbuf`写入iringbuf来维护指令执行历史; 当遇到`nemu_state.state = NEMU_ABORT`时，输出缓冲区
- 把`inst.c`中的指令注释后运行nemu，验证实现正确性

## 内存访问的踪迹 - mtrace
实现mtrace只需要在`paddr_read()`和`paddr_write()`中进行记录即可. 可以自行定义mtrace输出的格式. 和最后只输出一次的iringbuf不同, 程序一般会执行很多访存指令, 这意味着开启mtrace将会产生大量的输出, 因此最好可以在不需要的时候关闭mtrace

- 直接在`paddr.c`的`paddr_read()`和`paddr_write()`函数中添加`Log()`输出，读内存输出读取地址和读字节数，写内存输出写地址、写字节数和写数据
- 在`Kconfig`中添加`MTRACE`选项，可以通过menuconfig来打开或者关闭mtrace，并设置了`MTRACE_START`和`MTRACE_END`可以控制输出读写内容的地址范围

## 函数调用的踪迹 - ftrace
ftrace是带有程序语义的trace, 用来追踪程序执行过程中的函数调用和返回: 在函数调用指令中记录目标地址, 表示将要调用某个函数; 然后在函数返回指令中记录当前PC, 表示将要从PC所在的函数返回

### 消失的符号
在`am-kernels/tests/cpu-tests/tests/add.c`中定义了宏`NR_DATA`, 同时也在`add()`函数中定义了局部变量c和形参a, b, 但在符号表中找不到和它们对应的表项, 为什么会这样?
- 宏在预处理阶段已经被整合进代码文本中
- 局部变量被分配了寄存器

### 实现ftrace
- `CONFIG_FTRACE`宏配置ftrace的开关
- 首先实现ELF文件的读取，将解析后的符号表和字符串表信息保存在自定义的数据结构elfStFunc中实现, 在`$NEMU_HOME/src/monitor/sdb/sdb.h`中声明, 包括函数名, 地址, 大小和函数数量. 还有一些函数
- 具体实现与iringbuf类似，在`$NEMU_HOME/src/monitor/sdb/ftrace.c`中定义一个静态变量; 实现函数, 包括读取、保存、打印以及输出ftrace信息
- elf文件的解析参考`man 5 elf`与gpt
- 在编译时需要为nemu传入一个ELF文件: 在`$AM_HOME/scripts/platform/nemu.mk`中添加`NEMUFLAGS += -e $(IMAGE).elf`, 作为传入nemu的文件
- nemu实现解析elf文件, 通过在`parse_args()`中添加`-e`选项来指定elf文件; 在`init_monitor（）`中调用`init_ftrace_stfunc()`读取并保存符号表中的函数信息, 注意需要放在`parse_args()`之后, 不然读取不到参数
- 关于区分jal和jalr函数调用, riscv手册如是说:

<img src="../../figs/windows-screenshot 2024-08-13 233254.png" width="580" />
