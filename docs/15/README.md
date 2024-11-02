# SoC计算机系统
将NPC接入到ysyxSoC(ysyxSoC是可以在verilator上运行的SoC框架), SoC是System On Chip, 这意味着SoC不仅仅只包含一个处理器, 还有诸多的外围设备, 以及连接处理器和外围设备之间的总线. 在这里, 我们把存储器也看成一种广义的设备, 毕竟对于SoC来说, 存储器和其他狭义的设备没有区别, 都是一段可以访问的地址空间

## 获取ysyxSoC的代码并生成Verilog代码

获取ysyxSoC的代码:
```sh
git clone git@github.com:OSCPU/ysyxSoC.git
cd ysyxSoC
```

在 `ysyxSoC` 目录下根据 mill 的文档介绍安装 java 与 mill:

```sh
sudo apt install openjdk-8-jdk
curl -L https://github.com/com-lihaoyi/mill/releases/download/0.11.12/0.11.12 > mill && chmod +x mill
```

修改 `ysyxSoC/Makefile` 中的可执行文件为 `ysyxSoC` 目录下的 mill (`mill` 改为 `./mill`)

在 `ysyxSoC`目录下运行 `make dev-init` 命令, 拉取 `rocket-chip` 项目

在 `ysyxSoC/` 目录下运行 `make verilog`, 生成的Verilog文件位于 `ysyxSoC/build/ysyxSoCFull.v`
