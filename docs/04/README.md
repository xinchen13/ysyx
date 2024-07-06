# 搭建 verilator 仿真环境
Verilator 是一款开源的 Verilog 仿真工具, 在『一生一芯』项目中, 将会使用它来进行 RTL 功能仿真, 从而验证编写的 RTL 代码

本节搭建 Verilator 仿真环境, 并编写两个简单的数字电路模块来进行实验

## 框架代码 `npc` 目录初始化
框架代码默认提供了一个 `npc/` 目录, 这里的 npc 指 New Processor Core. 将来会在这个目录下设计处理器

为了设置后续用到的环境变量 `NPC_HOME`, 在主目录执行 `bash init.sh npc`, 初始化并可以看到 `npc/` 目录下的文件结构:

```sh
(base) xinchen@sakura:~/ysyx$ tree npc
npc
├── csrc
│   └── main.cpp
├── Makefile
└── vsrc
    └── example.v

2 directories, 3 files
```

## 认识 Verilator
- Verilator 是一种开源的 Verilog/SystemVerilog 仿真器，可用于编译代码以及代码在线检查，Verilator 能够读取 Verilog 或者 SystemVerilog 文件，并进行 lint checks (基于 lint 工具的语法检测)，并最终将其转换成 C++ 的源文件 `.cpp` 和 `.h`, 这个阶段的过程叫做 "to Varilate"，输出的文件叫做 "Verilated Model" 
- 为了能够完成仿真，Verilator 需要一个用户自行编写的 C++ wrapper，这个 wrapper 与传统的 Verilog Testbench 功能类似，主要是为了连接顶层模块，并给予相应的激励. 在 C++ 编译器的工作下，所有的之前生成的文件 (C++ wrapper 以及 Verilated Model) 以及库文件 (Verilator 提供的 runtime library 或者 SystemC 库文件) 会被一同合并成一个可执行文件
- 执行生成的可执行文件，就可以开始实际的仿真，此时称为 "simulation runtime", 最后如果在编译阶段将特定的编译选项打开，可执行文件也会生成波形和覆盖率等信息

## 安装 Verilator
在官网中找到安装 Verilator 的步骤, 然后按照从 git 安装的相应步骤进行操作 (为了统一版本, 选择版本 `5.008`)

```sh
# Prerequisites:
sudo apt-get install git help2man perl python3 make autoconf g++ flex bison ccache
sudo apt-get install libgoogle-perftools-dev numactl perl-doc
sudo apt-get install libfl2  # Ubuntu only (ignore if gives error)
sudo apt-get install libfl-dev  # Ubuntu only (ignore if gives error)
sudo apt-get install zlibc zlib1g zlib1g-dev  # Ubuntu only (ignore if gives error)

git clone https://github.com/verilator/verilator   # Only first time

# Every time you need to build:
unset VERILATOR_ROOT  # For bash
cd verilator
git pull         # Make sure git repository is up-to-date
git tag          # See what versions exist
git checkout v5.008  # Switch to specified release version v5.008

autoconf         # Create ./configure script
./configure      # Configure and create Makefile
make -j `nproc`  # Build Verilator itself (if error, try just 'make')
sudo make install
```

通过以下命令验证，安装成功

```sh
(base) xinchen@sakura:~/ysyx$ verilator --version
Verilator 5.008 2023-03-04 rev v5.008
```

## 运行 Verilator 示例
Verilator 手册中包含一个 C++ 的示例, 在手册中找到这个示例, 然后按照示例的步骤进行操作

创建 Verilog 文件 [our.v](./example/our.v) 和 C++ wrapper [sim_main.cpp](./example/sim_main.cpp)，之后使用 Verilator 生成模型与可执行文件: `verilator --cc --exe --build -j 0 -Wall sim_main.cpp our.v`

`--cc` 表示得到 c++ 输出; `--exe` 表示生成可执行文件，而不是库; `--build` 调用 make，也可以自己写编译规则; `-j 0` 使用尽可能多的 CPU Threads; `-Wall` 尽可能多的 warning. 之后运行得到的可执行文件，结果如下:

```sh
(base) xinchen@sakura:~/ysyx/docs/04/example$ ./obj_dir/Vour 
Hello World
- our.v:4: Verilog $finish
```

## 对双控开关模块进行仿真
手册中的实例甚至不算电路模块，尝试在 Verilator 中对双控开关模块进行仿真. 由于顶层模块名与手册中的示例有所不同, 还需要对 C++ 文件进行一些相应的修改. 此外, 这个项目没有指示仿真结束的语句, 为了退出仿真, 需要键入 `Ctrl+c`

创建 Verilog 文件 [top.v](./switch/top.v), 修改并完善 cpp wrapper [sim_main.cpp](./switch/sim_main.cpp), 因为 Verilog 模块名为 `top`, 所以头文件包含 "Vtop.h", 循环外的框架直接参考例程代码, 之后 Verilator 编译生成可执行文件, 仿真结果如下所示，实现了异或逻辑，由于计数器设置了终止条件, 因此仿真 8 次后退出. 先通过 `verilator --cc --exe --build -j 0 -Wall sim_main.cpp top.v` 编译，再运行仿真:

```sh
(base) xinchen@sakura:~/ysyx/docs/04/switch$ ./obj_dir/Vtop
a = 1, b = 0, f = 1
a = 1, b = 1, f = 0
a = 1, b = 1, f = 0
a = 0, b = 0, f = 0
a = 1, b = 1, f = 0
a = 0, b = 1, f = 1
a = 0, b = 1, f = 1
a = 1, b = 0, f = 1
```