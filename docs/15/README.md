# SoC计算机系统
将NPC接入到ysyxSoC. 

SoC不仅仅只包含一个处理器, 还有诸多的外围设备, 以及连接处理器和外围设备之间的总线. 在这里, 我们把存储器也看成一种广义的设备, 毕竟对于SoC来说, 存储器和其他狭义的设备没有区别, 都是一段可以访问的地址空间

ysyxSoC文档: [ysyxSoC](./ysyxSoC.md)

## 获取ysyxSoC的代码并生成Verilog代码
### 初始操作
获取ysyxSoC的代码:
```sh
git clone git@github.com:OSCPU/ysyxSoC.git
cd ysyxSoC
```

在 `ysyxSoC` 目录下根据 mill 的文档介绍安装 java 与 mill (此外, rocket-chip项目要求mill的版本不低于0.11, 亲测0.12.1不行):

```sh
sudo apt install openjdk-8-jdk
curl -L https://github.com/com-lihaoyi/mill/releases/download/0.11.12/0.11.12 > mill && chmod +x mill
```

通过 `./mill --version` 可以查看版本

修改 `ysyxSoC/Makefile` 中的可执行文件为 `ysyxSoC` 目录下的 mill (`mill` 改为 `./mill`)

在 `ysyxSoC`目录下运行 `make dev-init` 命令, 拉取 `rocket-chip` 项目

在 `ysyxSoC/` 目录下运行 `make verilog`, 生成的Verilog文件位于 `ysyxSoC/build/ysyxSoCFull.v`

### 后续
进入 `ysyxSoC` 目录运行 `make verilog`


## 接入ysyxSoC
- 依照 [ysyxSoC/spec/cpu-interface.md](../../ysyxSoC/spec/cpu-interface.md) 中的master总线, 将之前实现的AXI4-Lite协议扩展到完整的AXI4
- 调整NPC顶层接口, 使其与 [ysyxSoC/spec/cpu-interface.md](../../ysyxSoC/spec/cpu-interface.md) 中的接口命名规范完全一致, 包括信号方向, 命名和数据位宽
  - 对于不使用的顶层输出端口, 需要将其赋值为常数0
  - 对于不使用的顶层输入端口, 悬空即可
  - 由于core有两个master，需要自己实现一层 axim, 作为仲裁逻辑，同时挂载clint与ysyxSoCFull模块作为slave
- 将 `ysyxSoC/perip` 目录及其子目录下的所有 `.v` 文件加入verilator的Verilog文件列表
- 将 `ysyxSoC/perip/uart16550/rtl` 和 `ysyxSoC/perip/spi/rtl` 两个目录加入verilator的include搜索路径中: 事实上只需要加入两个宏定义文件
- 在verilator编译选项中添加 `--timescale "1ns/1ns"` 和 `--no-timing`
- 将ysyxSoCFull模块(在 `ysyxSoC/build/ysyxSoCFull.v` 中定义)设置为verilator仿真的顶层模块
- 将 `ysyxSoCFull.v` 中的 `ysyx_00000000` 模块名修改为处理器的模块名 `cpu_wrapper`
- 在仿真的cpp文件中加入如下内容, 用于解决链接时找不到`flash_read`和`mrom_read`的问题:
```c
extern "C" void flash_read(int32_t addr, int32_t *data) { assert(0); }
extern "C" void mrom_read(int32_t addr, int32_t *data) { assert(0); }
```
- 开始仿真, 观察到代码进入了仿真的主循环, 但NPC无有效输出

## 最简单的SoC
### 程序的存放
使用一种非易失存储器(non-volatile memory)来存放最初的程序, 使其内容能在断电时保持, 并在上电时能让CPU马上从中取出指令. 一个最简单的解决方案就是ROM(Read-Only Memory), 每次从ROM中相同位置读出的内容都是相同的

ROM的实现有很多种, 总体上都是通过某种方式来将信息(在这里也是程序)存储在ROM中, 而且这种存储方式不会受到断电的影响, 从而具备非易失的属性. 如果考虑在ysyxSoC中的易用性, 最合适的就是mask ROM(掩膜ROM), 简称MROM, 其本质是将信息"硬编码"在门电路中, 因此对NPC来说访问方式非常直接

不过因为MROM的某些问题, 我们并不打算在流片的时候使用它. 但MROM作为ysyxSoC中的第一个简单的非易失存储器来存放程序, 对我们测试ysyxSoC的接入还是非常合适的. 我们已经在ysyxSoC中添加了一个AXI4接口的MROM控制器, 其地址空间是`0x2000_0000~0x2000_0fff`

#### 测试MROM的访问
修改NPC:
- NPC的复位PC值改为 `32'h20000000`
- 修改`mrom_read()`函数，使其总是返回一条ebreak指令`0x100073u`
- **由于 ysyxSoCFull.v 中的复位为高电平有效，需要把仿真环境中的 reset 修改为高电平复位，并反相后传给 cpu_wrapper**
- NPC取到的第一条指令即是ebreak指令, 从而结束仿真

因为NEMU还没有添加MROM的支持, 而NPC此时需要从MROM中取指, 故此时DiffTest机制不能正确工作. 不过目前的测试程序规模还很小, 可以先关闭DiffTest功能, 后面再回过头来处理DiffTest的问题

### 输出第一个字符
可以存放程序之后就需要考虑如何输出了. 为此, SoC中还需要提供一个最基本的输出设备. 真实的SoC中通常使用UART16550, 它包含一些设备寄存器, 用于设置字符长度, 波特率等信息. 在发送队列未满时, 即可通过写入对应的设备寄存器来发送字符

ysyxSoC中已经集成了一个UART16550控制器. 为了测试它, 我们先编写一个最简单的程序`char-test`, 它直接输出一个字符之后就陷入死循环:

```c
#define UART_BASE 0x10000000L
#define UART_TX   0

void _start() {
    *(volatile char *)(UART_BASE + UART_TX) = 'A';
    *(volatile char *)(UART_BASE + UART_TX) = '\n';
    while (1);
}
```

- 根据ysyxSoC中的设备地址空间约定, 以及UART手册(在 `ysyxSoC/perip/` 下的相关子目录中)中输出寄存器的地址设置上述宏定义, 使代码可以正确访问输出寄存器来输出一个字符
- 通过gcc和objcopy命令编译char-test, 并将ELF文件中的代码节单独抽取到char-test.bin中：
  - 使用 gcc 编译 char-test.c 文件生成目标文件: `riscv64-linux-gnu-gcc -fomit-frame-pointer -march=rv32e_zicsr -mabi=ilp32e -c -o char-test.o char-test.c`
  - 用 objcopy 命令从目标文件中抽取代码节到 char-test.bin 文件 `riscv64-linux-gnu-objcopy --dump-section .text=char-test.bin char-test.o`
- 改仿真环境的相关代码, 读入 `char-test.bin` 并将其作为MROM的内容, 然后正确实现 `mrom_read()` 函数, 使其根据参数addr返回MROM中相应位置的内容
- 修改 `$NPC_HOME/Makefile`，读取 bin 文件
- 实现正确后仿真过程将会在终端输出一个字符 `A`

如果通过 `riscv64-linux-gnu-objdump -S char-test.o` 等工具查看生成的汇编, 会发现代码节的地址位于地址0附近, 与MROM的地址空间不一致. 实际上, 这个程序很小, 我们很容易确认, 无论将它放在哪个地址, 都能正确地按预期执行. 对于更复杂的程序, 上述条件不一定能满足, 我们需要显式地将程序链接到一个正确的位置, 使得NPC复位后可以正确地执行程序

此外, 在真实的硬件场景下, 串口还需要根据波特率来将字符转换成串行的输出信号, 通过线缆传送到串口的接收端, 因此发送端在发送字符前, 软件还需要在串口的配置寄存器中设置正确的除数. 但当前的ysyxSoC仿真环境中并没有串口的接收端, 因此我们在串口控制器的RTL代码中添加了若干打印语句, 直接将串口发送队列中的字符打印出来, 这样软件也无需设置除数. 也因此, 上述代码在真实的硬件场景中并不一定能正常工作, 但作为前期测试, 这可以方便我们快速检查字符是否被正确写入串口发送队列. 我们将在成功运行足够多程序后, 再添加除数的设置, 使得代码可以在真实的硬件场景中工作

### 去掉换行也能输出
上述char-test在输出字符 `A` 之后, 还输出一个换行符. 尝试仅仅输出字符 `A` 而不输出换行符, 会观察到仿真过程连字符A都不输出了. 但如果每次输出一个字符之后都紧接着输出一个换行符, 打印出的信息将很难阅读.

为了解决这个问题, 只需要给verilator传递一个选项 `--autoflush`. 添加后将会看到即使上述程序仅输出单个字符 `A`, 也能成功输出. 选项描述如下:

After every `$display` or `$fdisplay`, flush the output stream. This ensures that messages will appear immediately but may reduce performance. For best performance, call fflush(stdout) occasionally in the C++ main loop. Defaults to off, which will buffer output as provided by the normal C/C++ standard library IO.

## 更实用的SoC
MROM虽然可以很好地实现程序的存放, 但它不支持写入操作. 但大多数程序都需要向存储器写入数据, 例如, C语言的调用约定允许被调用函数在栈上创建栈桢, 并通过栈桢存取数据. 因此, 一个仅包含MROM作为存储器的SoC可能无法支持那些需要调用函数的程序, 显然这并不实用. 为了支持写入操作, 我们需要添加RAM作为存储器, 并将程序的数据分配在RAM中

最简单的RAM就是我们之前提到的SRAM, 我们可以在SoC中集成SRAM存储器. SRAM能够使用与处理器制造相同的工艺进行生产, 同时读写延迟只有1周期, 因此速度很快. 但SRAM的存储密度较低, 需要占用一定的芯片面积, 因此从流片价格的角度来计算, 成本是十分昂贵的. 考虑到流片成本, 我们只在SoC中提供8KB的SRAM. 我们已经在ysyxSoC中添加了一个AXI4接口的SRAM控制器, 其地址空间是`0x0f00_0000~0x0f00_1fff`. 注意到在前文的介绍中, SRAM的地址空间是`0x0f00_0000~0x0fff_ffff`, 共16MB, 这只是说明ysyxSoC中给SRAM预留了16MB的地址空间, 但考虑到实际的成本, 只使用了其中的8KB, 剩余的地址空间是空闲的, NPC不应该访问这部分空闲的地址空间.有了这部分SRAM的空间, 我们就可以考虑将栈分配在SRAM空间, 从而支持一些AM程序的执行了

### 为ysyxSoC添加AM运行时环境
添加一个 `riscv32e-ysyxsoc` 的新AM, 并提供TRM的API:

- 添加 ysyxsoc 专用的链接脚本 `$AM_HOME/scripts/ysyxsoc_linker.ld`, 在其中分配堆栈，需要分配在可写的内存区间, 因此可以分配在SRAM中, 地址为0x0f000000~0x0f001fff, 栈从高地址向低地址生长，堆从低到高
- 在 `$AM_HOME/scripts/platform/ysyxsoc.mk` 中添加编译运行规则
- 在 `$AM_HOME/scripts/risc32e-ysyxsoc.mk` 中补充规则
- `main()`函数由AM上的程序提供, 但我们需要考虑整个运行时环境的入口, 即需要将程序链接到MROM的地址空间, 并保证TRM的第一条指令与NPC复位后的PC值一致, 需要修改  `$AM_HOME/scripts/platform/ysyxsoc.mk` 中的 `_pmem_start`
- 退出程序使用 `halt()` 提供 ebreak 指令
- `putch` 可通过ysyxSoC中的UART16550进行输出
- 由于NPC复位后从MROM开始执行, 而MROM不支持写入操作, 因此我们需要额外注意: 程序中不能包含对全局变量的写入操作；栈区需要分配在可写的SRAM中

添加后, 将cpu-tests中的dummy测试编译到riscv32e-ysyxsoc, 并在ysyxSoC的仿真环境中运行它

### 无法运行的测试 
在ysyxSoC中运行cpu-tests中的fib, 发现运行失败，报错对MROM进行了写操作，应该是对全局变量fib数组元素的写操作

### 重新添加DiffTest
tbc

### 让NPC抛出Access Fault异常
tbc

### 内存访问测试
可以执行dummy测试后, 我们认为NPC基本上能成功访问ysyxSoC的SRAM了. 我们知道, 访存是程序运行的基础. 为了对访存行为进行更充分的测试, 我们需要编写一个程序mem-test来测试更大范围的内存.

从范围上看, mem-test希望能测试所有可写内存区域. 但mem-test本身的运行需要栈区的支持, 而栈区需要分配在可写内存区域, 因此在测试时需要绕开栈区, 避免栈区内容被覆盖, 导致mem-test本身运行出错. 我们可以把栈区放在SRAM的末尾, 并把堆区的起始地址设置在SRAM的开始, 堆区的结束地址设置在栈区的起始地址(即栈顶的初值). 设置好堆区的范围之后, 就可以把堆区作为mem-test的测试范围.

从测试方式上看, 我们采用一种最直观的方式: 先往内存区间写入若干数据, 再读出并检查. 我们可以让写入的数据与内存的地址相关, 从而方便检查, 例如data = addr & len_mask. 以下示意图展示了通过8位, 16位, 32位, 64位的写入地址和地址之间的关系.

```
    SRAM_BASE                                    SRAM_BASE + 0x10
        |                                               |
        V                                               V
        +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
8-bit   |00|01|02|03|04|05|06|07|08|09|0a|0b|0c|0d|0e|0f|
        +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
16-bit  |00|00|02|00|04|00|06|00|08|00|0a|00|0c|00|0e|00|
        +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
32-bit  |00|00|00|0f|04|00|00|0f|08|00|00|0f|0c|00|00|0f|
        +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
64-bit  |00|00|00|0f|00|00|00|00|08|00|00|0f|00|00|00|00|
        +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
```

在am-kernels中编写一个新的程序 [mem-test](../../am-kernels/tests/mem-tests/mem_test.c), 完成上述内存测试功能. 如果检查数据时发现不一致, 就通过`halt()`结束mem-test的运行:

- 目前程序的全局变量分配在MROM中, 因此程序不能包含对全局变量的写入操作
- `printf()`的代码较复杂, 调用`printf()`可能会使程序大小超过MROM空间, 而且其中还包含不少访存操作, 甚至有可能包含对全局变量的写入, 因此目前不通过`printf()`打印信息, 不过trace和波形足够帮助排除bug
- 为了避免编译优化带来的影响, 使用 volatile 关键词

### 支持全局变量的写入操作
很多程序都会写入全局变量, 因此我们还需要寻找一个解决方案来支持全局变量的写入操作. 由于全局变量位于数据段中, 为了方便叙述, 下文用"数据段"来代替"全局变量". 一个直接的想法是, 既然MROM不支持写操作, 我们就把数据段分配在SRAM中. 但在系统启动时, SRAM中并不包含有效的数据, 因此只能把数据段放到MROM中, 才能在系统启动时访问. 为了解决这个问题, 我们可以在程序真正开始执行前, 将数据段从MROM加载到SRAM中, 并让接下来的代码访问加载到SRAM中的数据段, 通过SRAM的可写特性支持全局变量的写入操作

事实上, 真实的操作系统也需要把程序加载到存储器中运行, 其中还需要进行很多复杂的操作. 因此执行上述加载操作的代码也可以看成一个加载器, 只不过目前其功能还很简单, 它只负责将程序的数据段从MROM加载到SRAM. 但由于这个加载器的工作时刻是在系统启动时, 因此我们将其称为bootloader

主要实现三点:
- 得到数据段在MROM中的地址MA(mrom address)和在SRAM中的地址SA(sram address), 以及数据段的长度LEN
- 将数据段从MA复制到SA
- 让程序代码通过SA访问数据段

对于第2点, 只需要调用`memcpy()`即可实现. 对于MA, 我们可以在链接脚本的数据段开始前定义一个符号, 即可在运行时刻让bootloader获得该符号的地址; 而对于LEN, 在链接脚本的数据段结束后定义一个符号, 与上述符号相减即可. 一个需要考虑的问题是, 如何获得SA. 一方面, 由于SA是一个地址, 而程序中的地址需要在链接中的重定位阶段才能确定, 因此SA最早也要在链接阶段才能确定. 另一方面, 由于第3点要求后续代码需要通过SA访问数据段, 而运行时刻的bootloader很难修改相应指令中的访问地址, 因此SA必须在运行前确定. 综合考虑上述两点, 我们可以得出结论: SA只能在链接阶段确定, 我们需要在链接脚本中定义SA.

为此, 我们需要用到链接脚本中的两种符号地址. 一种是虚拟内存地址(virtual memory address, VMA), 它表示程序运行时对象所在的地址; 另一种是加载内存地址(load memory address, LMA), 它表示程序运行前对象所在的地址. 通常情况下, 这两种地址相同. 但在上述需求中, 这两种地址有所不同: 数据段存放在MROM中, 但需要让程序代码访问加载到SRAM中的数据段, 即MA是LMA, SA是VMA