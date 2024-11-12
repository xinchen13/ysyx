# SoC计算机系统
将NPC接入到ysyxSoC. 

SoC不仅仅只包含一个处理器, 还有诸多的外围设备, 以及连接处理器和外围设备之间的总线. 在这里, 我们把存储器也看成一种广义的设备, 毕竟对于SoC来说, 存储器和其他狭义的设备没有区别, 都是一段可以访问的地址空间

ysyxSoC文档: [ysyxSoC](./ysyxSoC.md)

## 获取ysyxSoC的代码并生成Verilog代码
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

## 接入ysyxSoC
- 依照 [ysyxSoC/spec/cpu-interface.md](./cpu-interface.md) 中的master总线, 将之前实现的AXI4-Lite协议扩展到完整的AXI4
- 调整NPC顶层接口, 使其与 [cpu-interface](./cpu-interface.md) 中的接口命名规范完全一致, 包括信号方向, 命名和数据位宽
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