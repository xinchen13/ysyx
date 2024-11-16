# ysyx

## useful links
- [lecture notes](https://ysyx.oscc.cc/docs/)
- [learning record](https://docs.qq.com/sheet/DZXVEQ0thWGZOaU9t?tab=j1z835)
- [notes](./docs/notes.md)
- [references](https://drive.google.com/drive/folders/1Erw4Mbr6GKMMP08dxjcXhSXgXAQgfCtz)

## projects
- [ysyx](https://github.com/xinchen13/ysyx.git)
- [RT-Thread compatible with AM](https://github.com/xinchen13/rt-thread-am.git)

## 『一生一芯』预学习
预学习阶段主要工作是搭建环境，熟悉工具使用以及复习编程、数电等基础

- [如何科学地提问](./docs/01/)
- [Linux系统安装和基本使用(pa0)](./docs/02/) 
- [复习C语言](./docs/03/) 
- [搭建Verilator仿真环境](./docs/04/) 
- [数字电路基础实验](./docs/05/) 
- [完成PA1(pa1)](./docs/06/)

## 基础阶段(Baseline)
搭建基础设施，设计处理器，运行红白机

- [支持RV32IM的NEMU(pa2s1)](./docs/07/)
- [用RTL实现最简单的处理器(npc-addi)](./docs/08/)
- [运行时环境和基础设施(pa2s2)](./docs/09/)
- [nemu的设备和输入输出(pa2s3)](./docs/10/)
- [支持RV32E的单周期NPC(npc-rv32e-sc)](./docs/11/)
- [npc的设备和输入输出(npc-io)](./docs/12/)
- [异常处理和RT-Thread(exception)](./docs/13/)
- [总线(bus)](./docs/14/)

## Tips
#### set environment variables
```sh
source tenv
```

#### clone this repository & update all the branches
```sh
git clone -o xinchen git@github.com:xinchen13/ysyx.git
cd ysyx
./github-up.sh
```

#### synchronize all the modifications to GitHub
```sh
./github-commit.sh "commit_message"
```