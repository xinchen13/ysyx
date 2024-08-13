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