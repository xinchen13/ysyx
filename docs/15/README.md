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
- 进入 ysyxSoC 文件夹
- `curl -L https://github.com/com-lihaoyi/mill/releases/download/0.11.12/0.11.12 > mill && chmod +x mill`
- 运行 `make verilog`


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
程序的存放: 使用一种非易失存储器(non-volatile memory)来存放最初的程序, 使其内容能在断电时保持, 并在上电时能让CPU马上从中取出指令. 一个最简单的解决方案就是ROM(Read-Only Memory), 每次从ROM中相同位置读出的内容都是相同的

ROM的实现有很多种, 总体上都是通过某种方式来将信息(在这里也是程序)存储在ROM中, 而且这种存储方式不会受到断电的影响, 从而具备非易失的属性. 如果考虑在ysyxSoC中的易用性, 最合适的就是mask ROM(掩膜ROM), 简称MROM, 其本质是将信息"硬编码"在门电路中, 因此对NPC来说访问方式非常直接

不过因为MROM的某些问题, 我们并不打算在流片的时候使用它. 但MROM作为ysyxSoC中的第一个简单的非易失存储器来存放程序, 对我们测试ysyxSoC的接入还是非常合适的. 我们已经在ysyxSoC中添加了一个AXI4接口的MROM控制器, 其地址空间是`0x2000_0000~0x2000_0fff`

### 测试MROM的访问
修改NPC:
- NPC的复位PC值改为 `32'h20000000`
- 修改`mrom_read()`函数，使其总是返回一条ebreak指令`0x100073u`
- 修改 `ysyxSoCFull.v` 中的 AXI4MROM 模块，时序逻辑部分的 reset 改为低电平有效
- NPC取到的第一条指令即是ebreak指令, 从而结束仿真

因为NEMU还没有添加MROM的支持, 而NPC此时需要从MROM中取指, 故此时DiffTest机制不能正确工作. 不过目前的测试程序规模还很小, 可以先关闭DiffTest功能, 后面再回过头来处理DiffTest的问题