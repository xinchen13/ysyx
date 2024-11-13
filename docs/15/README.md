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